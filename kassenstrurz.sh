#!/bin/sh
# this script does grab the faszination wissen...

http://www.srf.ch/player/tv/suche?query=kassensturz&sort=re&page=1
BASE_URL=http://www.srf.ch/player/tv
INDEX_URL="${BASE_URL}/suche?query=kassensturz&sort=re&page="

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

# index begining
IDX=1
while [ ${IDX} -le 8 ]
do
# grab the index url
# remove the exisiting index first
rm -f ${TEMP_DIR}/index
# get the first page...
wget ${WGET_OPTIONS} ${INDEX_URL}${IDX} -O ${TEMP_DIR}/index
# extract the last page from the index
#LAST_PAGE=`cat ${TEMP_DIR}/index| sed -e "s#.*>\([0-9]\+\)</a><a href=\"/suche.*page=2\">n.* Seite</a>.*#\1#g`
echo "Last page: ${LAST_PAGE}"

# pattern for episode
#<a class="result_title" href="/player/tv/kassensturz/video/kassensturz-vom-18-09-2012?id=6b2d4b96-9e7b-4ec0-9786-94ab8adf6430">Kassensturz vom 18.09.2012</a><div class="result_infos">

# extract the episodes from the index
cat ${TEMP_DIR}/index | grep -e ".* href=\"/player/tv/kassensturz/video/kassensturz-vom-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9].*\">Kassensturz vom .*</a>" | sed -e "s#.*href=\"/player/tv\(/kassensturz/video/kassensturz-vom-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9][^\"]*\)\".*#\1#g" > ${TEMP_DIR}/episode.txt

EPISODE_LIST=`cat ${TEMP_DIR}/episode.txt`
for episode in ${EPISODE_LIST}
do
	EPISODE_HASH=`echo ${episode} | sed -e "s#.*-\([^-]*\)#\1#g"`
	#EPISODE_NAME=`basename ${episode} | sed -e "s/.html//g"`
	echo "Getting link to episode: ${EPISODE_HASH} ..."
	wget ${WGET_OPTIONS} ${BASE_URL}/${episode} -O ${TEMP_DIR}/${EPISODE_HASH} --quiet
	EPISODE_DL=`cat ${TEMP_DIR}/${EPISODE_HASH} | sed -e "s#;#;\n#g" | grep "window.location.href=" | sed -e "s#.*setTimeout('window.location.href=[\][']\(http:.*m4v\?\).*#\1#g" | head -n 1`
	EPISODE_NAME_DATE=`echo ${EPISODE_DL} | sed -e "s#.*/\(kassensturz_.*m4v\).*#\1#"`
	echo "Try to downloading $EPISODE_NAME_DATE"
	if [ ! -f ${VIDEO_DIR}/${EPISODE_NAME_DATE} ]
	then
		echo "grabbing ${EPISODE_NAME_DATE} from url: ${EPISODE_DL}"
		wget ${WGET_OPTIONS} ${EPISODE_DL} -O ${VIDEO_DIR}/${EPISODE_NAME_DATE}
	fi
done
IDX=`expr ${IDX} + 1`
done # while
