docker build -t vsftp_alpine .
REM Make sure to go into the windows docker desktop app and share the C drive. duh!
docker run -it -p 21:21 -p 21000-21100:21000-21100 --env-file rundocker.env -v c:/Users/joe_b/Pictures/AmazonPhotos:/amazonphotos vsftp_alpine /bin/sh 