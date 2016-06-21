#!/bin/sh

TASK_DIR="pdf"
WORK_DIR="jpg"
ZIP_DIR="zip"
DONE_DIR="done"

which mogrify > /dev/null

if [ $? != 0 ]; then
	echo You need ImageMagick.
	echo http://www.imagemagick.org/
	exit 1
fi

which pdfimages > /dev/null

if [ $? != 0 ]; then
	echo You need Poppler.
	echo https://poppler.freedesktop.org/
	exit 1
fi

if [ ! -d ${WORK_DIR} ]; then
	mkdir ${WORK_DIR} 
fi

if [ ! -d ${ZIP_DIR} ]; then
	mkdir ${ZIP_DIR} 
fi

if [ ! -d ${DONE_DIR} ]; then
	mkdir ${DONE_DIR} 
fi


IFS='
'

for I in `ls ${TASK_DIR}/*.pdf`
do
	echo START
	ORIGINAL_FILE_NAME=`echo ${I} | sed -e 's:..*/::'` 
	echo ORIGINAL_FILE_NAME ${ORIGINAL_FILE_NAME}
	DIR_NAME=`echo ${I} | sed -e 's:..*/::' -e 's/\(..*\) \([^ ][^ ]*\)(著).pdf$/\[\2\]\1/' -e 's/ ..*//' -e 's/\]/\] /'`
	echo DIR_NAME ${DIR_NAME}
	FILE_BASE=`echo ${I} | sed -e 's:..*/::' -e 's/\(..*\) \([^ ][^ ]*\)(著).pdf$/\[\2\]\1/' -e 's/ / 第/' -e 's/\]/\] /'`
	echo FILE_BASE ${FILE_BASE}

	if [ ! -d ${WORK_DIR}/${DIR_NAME}/${FILE_BASE} ]; then
		mkdir -p ${WORK_DIR}/${DIR_NAME}/${FILE_BASE} 
	fi

	mv ${I} ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}/${FILE_BASE}.pdf

	cd ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}

	pdfimages -j ${FILE_BASE}.pdf ${FILE_BASE}

	rm -f ${FILE_BASE}.pdf

	if [ ! -d color ]; then
		mkdir color
	fi

	for J in `identify *.jpg | grep RGB`
	do
		FILE_NAME=`echo $J | sed -e 's/^\(..*.jpg\) ..*$/\1/'`
		mv ${FILE_NAME} color/
	done

	mogrify -level 20%,80% *.jpg

	mv color/* .
	rm -rf color

	zip ${FILE_BASE}.zip *.jpg > /dev/null

	cd - > /dev/null

	if [ ! -d ${ZIP_DIR}/${DIR_NAME} ]; then
		mkdir ${ZIP_DIR}/${DIR_NAME}
	fi

	chown :public ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}/${FILE_BASE}.zip 
	chmod 664 ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}/${FILE_BASE}.zip 
	mv ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}/${FILE_BASE}.zip ${ZIP_DIR}/${DIR_NAME}/

	mv ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}/${FILE_BASE}.pdf ${DONE_DIR}/${FILE_NAME}
	
	rm -rf ${WORK_DIR}/${DIR_NAME}/${FILE_BASE} 

	echo DONE
done