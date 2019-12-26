# Security Camera Person Detect Push Notification
All in one docker container that will recieve FTP photo and video pushes from a WiFi (or just IP enabled) security camera then perform OpenCV YOLOv3 object recognition to generate image metadata to send push notifications (using pushover.net) if a person is found recently in the camera field. 

## Motivation
Ring, Nest, Amazon Cloud Cam, ARLO are all expensive for either the hardware or monthly service especially if you have more than a few cameras.  I personally still have a ring camera but that is more for backup to all that I am showing here. Additionally, I needed exponential backoff for the entire camera vision so I don't get spammed when my kids are playing basketball or I'm mowing the yard.  Lastly, I have alot of wildlife that roams my property and I don't need to get notified when a dear, turkey, or coyote are lurking about. 

## Architecture
![Archictecture Diagram](https://github.com/joequint/SecCam/blob/master/SecurityCam.png "Archictecture")


## Prerequisites/setup
* Create a local directory c:/tmp/AmazonPhotos (or see configuration)
* Download and install [Amazon Photos](https://www.amazon.com/Amazon-Photos/b?ie=UTF8&node=13234696011 "Amazon Photos's Homepage") or Google Drive or One Drive or DropBox, or preferred cloud sync tool. **_Sync it to the local directory above._**
* Signup for https://pushover.net/ (I'm not affiliated with the product but it is what I used for push notifications.)
* From the pushover.net main dashboard copy the "YOUR USER KEY" and edit the rundocker.env file and paste it into RIGHT side of the pushuser=
* From the pushover.net main dashboard select [Create an Application/API Token](https://pushover.net/apps/build) copy the "API Token/Key" and edit the rundocker.env file and paste it into RIGHT side of the pushtoken=
* Openup firewall ports on your local system by adding the inbound ports in windows firewall service 21, 21000-21100.  See file [WindowsFirewall_AllowPorts.PNG](./WindowsFirewall_AllowPorts.PNG)
* Allow Docker to share drive C by going into the Advanced Settings of Docker
* Security Cam Setup: TODO
  

## Usage
```
rundocker.bat
```

## Configuration

Environment variables:
- `pushtoken` - pushover.net API Token/Key
- `pushuser` - pushover.net User Key (From main dashboard)
- `pushoverurl` - pushover.net API URL (Do not change unless they change it)
- `sound` - app notification sound. To change consult [pushover.net sounds reference](https://pushover.net/api#sounds) 
- `ftpUSERS` - user and password seperated by pipe that the camera will use to FTP the files
- `photodir` - base directory that motion detected photos will be stored. CAUTION: If you change then you need to update rundocker.bat docker run command
- `videodir` - base directory that motion detected videos will be stored. CAUTION: If you change then you need to update rundocker.bat docker run command

Docker variables (set by rundocker.bat):
- "-p 21:21 -p 21000-21100:21000-21100"  - maps ports 21 (FTP) and 21000-21100 (Passive FTP) minamal to maximal port number may be used for passive connections 
- "-v c:/tmp/AmazonPhotos:/amazonphotos" - local system folder where all of the photos and videos will land. This will be mirrored to the cloud provider.


## Troubeshooting/TIPS
- Make sure that you have shared C: from Docker else volumes won't work!
- Docker container won't build properly , try resetting docker or remove ubuntu base image.  OpenCV relies on an up to date version else it won't find all the dependencies
