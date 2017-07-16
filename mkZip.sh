#!/bin/sh
# A script to exchange from pdf to zip file scanned by the service 漫画スキャン王.
#Copyright (C) 2016 Ryo
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#GNU General Public License for more details.
#You should have received a copy of the GNU General Public License
#along with this program. If not, see [http://www.gnu.org/licenses/].

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

which 7za > /dev/null

if [ $? != 0 ]; then
	echo You need P7ZIP.
	echo http://p7zip.sourceforge.net/
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

ls ${TASK_DIR}/*.pdf | while read -r I
do
	echo START
	ORIGINAL_FILE_NAME=`echo ${I} | sed -e 's:..*/::'` 
	echo ${ORIGINAL_FILE_NAME}

	echo ${ORIGINAL_FILE_NAME} | grep '(画)\|(漫)\|(作)\|(原)\|＆' > /dev/null
	if [ $? != 0 ]; then
		DIR_NAME=`echo ${ORIGINAL_FILE_NAME} | sed -e 's/^\(..*\) \([^ ][^ ]*\)(著).pdf$/\[\2\] \1/' -e 's/^\(..*\) \([^ ][^ ]*巻\)$/\1/'`
		FILE_BASE=`echo ${ORIGINAL_FILE_NAME} | sed -e 's/^\(..*\) \([^ ][^ ]*\)(著).pdf$/\[\2\] \1/' -e 's/^\(..*\) \([^ ][^ ]*巻\)$/\1 第\2/'`
	else
		DIR_NAME=`echo ${ORIGINAL_FILE_NAME} | sed -e 's/^\(..*\) \([^ ][^ ]*\).pdf/\[\2\] \1/' -e 's/^\[\(..*\)＆\(..*\)([^\][^\]]*\] \(..*\)$/[\1x\2] \3/' -e 's/([^)][^)]*)/x/' -e 's/([^)][^)]*)//' -e 's/ [^ ][^ ]*巻//'`
		FILE_BASE=`echo ${ORIGINAL_FILE_NAME} | sed -e 's/^\(..*\) \([^ ][^ ]*\).pdf/\[\2\] \1/' -e 's/^\[\(..*\)＆\(..*\)([^\][^\]]*\] \(..*\)$/[\1x\2] \3/' -e 's/([^)][^)]*)/x/' -e 's/([^)][^)]*)//' -e 's/\(..*\) \([^ ][^ ]*巻\)/\1 第\2/'`
	fi

	echo ${DIR_NAME}/${FILE_BASE}

	if [ ! -d ${WORK_DIR}/${DIR_NAME}/${FILE_BASE} ]; then
		mkdir -p ${WORK_DIR}/${DIR_NAME}/${FILE_BASE} 
	fi

	mv ${I} ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}/${FILE_BASE}.pdf

	cd ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}

	pdfimages -j ${FILE_BASE}.pdf ${FILE_BASE}

	if [ ! -d color ]; then
		mkdir color
	fi

	for J in `identify *.jpg | grep RGB`
	do
		FILE_NAME=`echo $J | sed -e 's/^\(..*.jpg\) ..*$/\1/'`
		mv ${FILE_NAME} color/
	done

	mogrify -level 20%,80% *.jpg > /dev/null

	mv color/* .
	rm -rf color

	echo zipping ${FILE_BASE}.zip
	7za a ${FILE_BASE}.zip *.jpg > /dev/null

	cd - > /dev/null

	if [ ! -d ${ZIP_DIR}/${DIR_NAME} ]; then
		mkdir ${ZIP_DIR}/${DIR_NAME}
	fi

	mv ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}/${FILE_BASE}.zip ${ZIP_DIR}/${DIR_NAME}/

	mv ${WORK_DIR}/${DIR_NAME}/${FILE_BASE}/${FILE_BASE}.pdf ${DONE_DIR}/${ORIGINAL_FILE_NAME}

	echo DONE
done

echo Please manually delete the working directory by the following:
echo rm -rf ${WORK_DIR}

