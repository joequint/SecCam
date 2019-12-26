FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y vsftpd

RUN apt-get install -y python3  python3-pip
#curl python3-distutils
RUN apt-get install -y libsm6 libxext6 libxrender-dev

RUN pip3 install --upgrade pip

RUN pip3 install opencv-python
RUN apt-get install -y ffmpeg

#RUN apt install -y ssmtp mpack

RUN apt install -y curl jq vim

COPY start_vsftpd.sh /bin/start_vsftpd.sh
COPY xfermon.sh /bin/xfermon.sh
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY xferdetect.py /bin/xferdetect.py
COPY yolov3* /bin/
COPY ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY revaliases /etc/ssmtp/revaliases 

EXPOSE 21 21000-21100
#VOLUME /ftp/ftp
#VOLUME /amazonphotos

ENTRYPOINT /bin/start_vsftpd.sh
