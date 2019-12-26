#!/bin/bash
ftproot=/ftp/jq
backoffseconds_default=30

function mvp ()
{
   dir="$2"
   tmp="$2"; tmp="${tmp: -1}"
   [ "$tmp" != "/" ] && dir="$(dirname "$2")"
   [ -a "$dir" ] || mkdir -p "$dir" &&
   mv "$@"
}

#initialize the security cam hysteris epoch time
mkdir -p /var/securitycam

echo $backoffseconds_default > /var/securitycam/backoffseconds
echo print backoffseconds
cat /var/securitycam/backoffseconds
expr `date +%s` - $backoffseconds_default > /var/securitycam/lastevent
echo NEW EVENT MARKER: `cat /var/securitycam/lastevent`

#set -x
touch /var/log/xferlog
#This sort of event-triggered approach will be faster, more reliable, and less load than a polling approach with traditional cron, and more portable and easier to debug than something using inotify.
tail -F /var/log/xferlog | while read line; do
#  echo "New File: " "$line"
  if echo "$line" | cut -d ' ' -f 12 | grep -q 'i'; then
    basefilename=`(echo "$line" | cut -d ' ' -f 9)`
    filename=$ftproot$basefilename

#    echo "Filename: " $filename
    if [ -s "$filename" ]; then
      # do something with $filename
          camera=`echo $filename | cut -d '/' -f 4`
          echo `date +"%Y-%m-%dT%H:%M:%SZ"` "NEW FILE: " $filename
	  if echo $basefilename | grep -q '.264$'; then
		  basefilenameregex=`(echo "$basefilename" | sed -e 's/record\///')`
#	     echo "basefilenameregex: " $basefilenameregex
             ffmpeg -framerate 24  -i $filename -c copy $filename.mp4
	     mvp $filename.mp4 $videodir$basefilenameregex.mp4
	  fi
	  if echo $basefilename | grep -q '.jpg$'; then
          python3 xferdetect.py $filename
          if grep -q -e 'person' $filename.yolo.objects;
		  basefilenameregex=`(echo "$basefilename" | sed -e 's/images\///')`
#	     echo "basefilename: " $basefilename
#	     echo "basefilenameregex: " $basefilenameregex
              mvp $filename $photodir$basefilenameregex
              then
                  echo `date +"%Y-%m-%dT%H:%M:%SZ"` "-" $camera "-PERSON DETECTED!"
                  currentepoch=`date +%s`
                  priorepoch=`cat /var/securitycam/lastevent`
                  elapsedseconds=`expr $currentepoch - $priorepoch`
                  echo "elapsedseconds " $elapsedseconds " = currentepoch[" $currentepoch "] - priorepoch [" $priorepoch "]"
                  if [ "$elapsedseconds" -gt 0 ];
                            then
                                echo `date +"%Y-%m-%dT%H:%M:%SZ"` "-" $camera "-Mark New LastEvent"
				                yolophoto=$filename.yolo.jpg
				                ls $filename.yolo.jpg
                                backoffseconds=`cat /var/securitycam/backoffseconds`
                                if [ "$elapsedseconds" -lt "$backoffseconds" ];
                                    then 
                                        echo Double Backoff Seconds timer `cat /var/securitycam/backoffseconds`
                                        expr `cat /var/securitycam/backoffseconds` \* 2 > /var/securitycam/backoffseconds
                                    else
                                        echo Reset Backoff Seconds timer to default
                                        echo $backoffseconds_default > /var/securitycam/backoffseconds
                                fi
                                #Set the backoff timer to a future time based on backoffseconds like a TTL
                                expr `date +%s` + `cat /var/securitycam/backoffseconds` > /var/securitycam/lastevent
                                echo NEW EVENT MARKER: `cat /var/securitycam/lastevent`
                              #  curl -s --form-string "token=$pushtoken" \
                              #          --form-string "user=$pushuser" \
                              #          --form-string "title=PERSON DETECTED $camera" \
                              #          --form-string "message=`cat $filename.yolo.objects`" \
                              #          -F "attachment=@$yolophoto" \
                              #              https://api.pushover.net/1/messages.json   
                            else
                                echo `date +"%Y-%m-%dT%H:%M:%SZ"` "-" $camera "-IGNORING EVENT - WAITING TILL FOR BACKOFF SECS " $elapsedseconds
                            fi
              else
                  echo `date +"%Y-%m-%dT%H:%M:%SZ"`i "-" $camera  "-IGNORE MOTION DETECTED" `cat $filename.yolo.objects`
          fi
  fi
    fi
  fi
done
