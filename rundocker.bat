docker build -t vsftp_ubuntu .
REM Make sure to go into the windows docker desktop app and share the C drive. duh!
docker run -it -p 21:21 -p 21000-21100:21000-21100 --env-file rundocker.env -v c:/tmp/AmazonPhotos:/amazonphotos vsftp_ubuntu