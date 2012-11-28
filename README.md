Kassensturz
===========
This is a simple shell script using the SF1 website source to grab the latest Kassensturz video stream.

if you do not know Kassensturz, go to the following address:

http://www.kassensturz.sf.tv/

The script does automatically create a temp/ and a videos/ directory.
 * the "temp" directory contains the grabbed web pages containing the references to the rtmp video stream server.

 * the "videos" directory is the output folder containing the downloaded videos

*Notice*
the script is using wget and rtmp commands, the wget option permits to ignore already downloaded files. This feature allows you to stop and resume the download without having to go through the whole process again.

Before downloading the stream, the script also check if the file already exists in the "videos" directory.

during the download operation, it can be that a timeout occurs, do not worry the rtmp command automatically retries and resume the download.

enjoy the script!

-- 
Eric
