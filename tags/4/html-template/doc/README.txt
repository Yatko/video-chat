IMPORTANT, PLESE READ AND CONSIDER BEFORE START!
1. Follow us on Twitter, it is the place we announce new releases and hotfixes: http://twitter.com/JabberCam
2. For any questions, problems, development and discussion, please access http://bit.ly/JabberCamForum and post your question there
3. If you made any change and you think it is worth of publishing, please do so. Active developers are welcome to join our team.

HOW TO START?
1. Download the latest release from http://code.google.com/p/video-chat/
2. Fire up Adobe Flash Builder 4 (or above) and import the project
2.1 Let's assume, you saved the files under /Users/Default/Documents/RVC/4.0/ (your path may be different),
	in this folder you should have several files and directories (/src, /assets, / html-template, /libs, /Red5_serverapp)
2.2 In Adobe Flash Builder (referred as FB) go to "File" >> "Import Flex Project (FXP)" and on the new window check "Project Folder"
	browse for the above path than press "Finish" when it becomes available.
*More info here: http://www.videosoftware.pro/forum/THREAD-%09-Installing-and-editing-RVC-5-PART2-step-by-step-description

Installing the compiled application:
http://www.videosoftware.pro/forum/THREAD-Installing-JabberCam-RVC-4

ENABLING Red5 (Swithing to own Flash Media Server)
- change $SERVER_TYPE to Red5 ($SERVER_TYPE = 'Red5'; // 'Red5' | 'Stratus')
- Upload config.php to your serverand Enjoy! (you are using our resources, if your connection will be limited or filtered, you will be notified)
 
ENABLING Red5 IN CASE YOU HAVE YOUR OWN RED5 SERVER:  
* Red5 support is not included, in order to use Red5, you must be familiar with the description below
  You must have a hosting service ready to host Red5 applications (Red5 hosting) or you must install Red5 on your Server/VPS.
  Ask help from your web-host administrator with creating the rtmp link (adding JabberCamApp to Red5)
  
- Download the MySQL jdbc driver from http://dev.mysql.com/downloads/connector/j/ (mysql-connector-java-x.x.x-bin) and place it under /Red5_serverapp/deploy_app/JabberCamApp/WEB-INF/lib/
- Edit /Red5_serverapp/deploy_app/JabberCamApp/WEB-INF/red5-web.properties
- Deploy the applet (/Red5_serverapp/deploy_app/JabberCamApp) to your webapp (or similar) folder and restart Red5
- Edit /jabbercam/config.php and insert your RTMP link ($RED5_CONNECT_URL = 'rtmp://localhost/JabberCamApp';)
- Change $SERVER_TYPE to Red5 ($SERVER_TYPE = 'Red5'; // 'Red5' | 'Stratus')
- Upload config.php to your serverand Enjoy!
* please DO NOT contact us with Red5 support requests! If Red5 is configured properly, you don't need anyhing else, but the above.
Installing Red5 (and understanding the configuration) might be difficult, please consult with your web hosting support.
* read our description and forum about installing Red5 and common issues, troubleshooting:

http://www.videosoftware.pro/forum/FORUM-Red5-Installation-and-Configuration

CREATING/CHANGING LANGUAGE FILES:
- Make a copy of /jabbercam/language/lang_en.xml and rename it to the language you wish to use ex. lang_be.xml
- Make the corresponding changes in /jabbercam/config.php

ERROR HANDLING:
- Run http://www.your-domain.com/jabbercam/admin.php?task=test
- Please read the installation section of our forum: http://www.videosoftware.pro/forum/FORUM-Documentation-Quickstart-and-How-To
- For any questions, problems, development and discussion, please access http://bit.ly/JabberCamForum and post your question there

MAINTENANCE:
- Run http://www.your-domain.com/jabbercam/admin.php?task=clean on a regular basis ex. daily (create a cron job)

COMMON PROBLEMS:
- Make sure you edit /jabbercam/config.php and be aware of the functions.php location
- Make sure, you created the databases for the program and run /jabbercam/admin.php?task=install or inserted the tables jabercam.sql (drop the old databesa first)
- Make sure you edit the JabberCam.mxml file correctly, if you changed the JabberCam.mxml figure out where did you mess it up
- You need to have basic php xml and programming knowledge to install and you need a pro to modify the code!
- Regularly clear your database using http://www.your-domain.com/jabbercam/functions.php?task=clean (create a cron job).

COMMON ERRORS:
http://www.videosoftware.pro/forum/THREAD-RVC-Error-Messages

THE CODE YOU GOT:
- The code is a working prototype, not a 100% bug-free tested production ready software! You might want to modify it after your needs.
- This project was started in February 2010. During early development (first weeks), we used a purchased (including the rights to distribute) chatroulette clone source code.
	A sorce code package that might be based on the sample surce codes relesed by Adobe to present the new features of Stratus (later Cirrus). If you find any references to
	either Chatroulette or Adobe, this is the reason, this project is not related to, endorsed by or affiliated with chatroulette.com, Adobe nor anyone else.
	We appreciate the great samples relesaed by Adobe that helped us to understand the new functions delivered by Stratus!
	

IMAGES:
The images used as JabberCam backgrounds are courtesy of http://www.photos8.com/ - THANK YOU!

SUPPORT:
Please post your questions to our forum: http://bit.ly/JabberCamForum

NO support is included! Please do not call or request any type of support! However, if you have problems, please post your question to the forum (http://bit.ly/JabberCamForum) and we will try to answer your question as soon as possible.

Thank you :)
RVC & JabberCam Team