#!/bin/sh
# this script does grab the faszination wissen...

BASE_URL=http://www.videoportal.sf.tv
INDEX_URL="${BASE_URL}/suche?query=kassensturz;sort=re&page="

TEMP_DIR=./temp
VIDEO_DIR=./videos

WGET_OPTIONS="-nc --random-wait --no-cache --timeout=120"

# create temp directories
if [ ! -f ${TEMP_DIR} ]
then
	mkdir -p ${TEMP_DIR}
fi

if [ ! -f ${VIDEO_DIR} ]
then
	mkdir -p ${VIDEO_DIR}
fi


# grab the index url
# remove the exisiting index first
rm -f ${TEMP_DIR}/index
# get the first page...
wget ${WGET_OPTIONS} ${INDEX_URL}2 -O ${TEMP_DIR}/index
# extract the last page from the index
#LAST_PAGE=`cat ${TEMP_DIR}/index| sed -e "s#.*>\([0-9]\+\)</a><a href=\"/suche.*page=2\">n.* Seite</a>.*#\1#g`
echo "Last page: ${LAST_PAGE}"


# extract the episodes from the index
cat ${TEMP_DIR}/index| sed -e "s#</h3><p class=#\n</h3><p class=#g" | grep -e ".* href=\"/video[^\"]*[0-9]\">Kassensturz vom .*</a>" | sed -e "s#.*href=\"\(/video.*[0-9]\)\".*#\1#g" > ${TEMP_DIR}/episode.txt

EPISODE_LIST=`cat ${TEMP_DIR}/episode.txt`
for episode in ${EPISODE_LIST}
do
	EPISODE_HASH=`echo ${episode} | sed -e "s#.*-\([^-]*\)#\1#g"`
	#EPISODE_NAME=`basename ${episode} | sed -e "s/.html//g"`
	echo "Getting episode: ${EPISODE_HASH} ..."
	wget ${WGET_OPTIONS} ${BASE_URL}/${episode} -O ${TEMP_DIR}/${EPISODE_HASH} --quiet
	EPISODE_DL=`cat ${TEMP_DIR}/${EPISODE_HASH} | sed -e "s#;#;\n#g" | grep "window.location.href=" | sed -e "s#.*setTimeout('window.location.href=[\][']\(http:.*m4v\?\).*#\1#g" | head -n 1`
	if [ ! -f ${VIDEO_DIR}/${EPISODE_HASH}.m4v ]
	then
		echo "grabbing ${EPISODE_HASH}.m4v from url: ${EPISODE_DL}"
		wget ${WGET_OPTIONS} ${EPISODE_DL} -O ${VIDEO_DIR}/${EPISODE_HASH}.m4v
	fi
done

