<!--
/**
 * VIDEOSOFTWARE.PRO
 * Copyright 2011 VideoSoftware.PRO
 * All Rights Reserved.
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 *  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *  See the GNU General Public License for more details.
 *  You should have received a copy of the GNU General Public License along with this program.
 *  If not, see <http://www.gnu.org/licenses/>.
 * 
 *  Author: Our small team and fast growing online community at videosoftware.pro
 */
-->
<?php

/**
 * Configuration file for RVC 5.0+
 * You may want to edit /jabbercam/language/lang_??.ini
 * Help: http://www.videosoftware.pro/forum/FORUM-Documentation-Quickstart-and-How-To
 */

//SYSTEM SETTINGS

/* Back-en location (exact location of functions.php on your domain | http://www.your_domain.com/[folder]/jabbercam/functions.php */
$WEB_SERVICE_URL = "http://www.WEB_SERVICE_URL/jabbercam/functions.php";		// http://www.your_domain.com/jabbercam/functions.php
$GOOGLE_APP_ID = "GOOGLE_MAPS_APP_ID";								            // required for Google maps (to remove, read forum)

/* Optional database configuration for Red5, used to install database tables (for Red5 database configuration read forum) */
$RED5_DB_HOST = "localhost";			//database host (server)
$RED5_DB_USER = "dbuser";				//database username
$RED5_DB_PASSWORD = "dbpassword";		//database password
$RED5_DB_DATABASE = "databasename";		//database name
/* Optional database configuration for Stratus, not needed if Red5 is used */
$DB_HOST = "localhost";					//database host (server)
$DB_USER = "dbuser";					//database username
$DB_PASSWORD = "dbpassword";			//database password
$DB_DATABASE = "databasename";			//database name

/* Flash media server settings (rtmfp or rtmp | values: Stratus or Red5) */
$SERVER_TYPE = 'Stratus';											// 'Red5 or 'Stratus'
/* if Stratus */
$DEVELOPER_KEY = "ADOBE_CIRRUS_KEY";								// your Adobe Cirrus (Stratus) developer key obtained from Adobe (read forum)
/* if Red5 */
$RED5_CONNECT_URL = 'rtmp://www.videosoftware.pro/JabberCamApp';	// use your own rtmp, this temporary resource may be down 
$RED5_CONNECT_URL_B1 = '';											// backup server #1
$RED5_CONNECT_URL_B2 = '';											// backup server #2
$RED5_CONNECT_MAIN_TIMEOUT = 30;									// minutes


// LOGIN PROCESS SETTINGS (turn on/off mandatory camera and username | values: true or false)
$CAMERA_REQUIRED = true;				// 'true' or 'false'
$LOGIN_SCREEN_ENABLE = true;			// 'true' or 'false' (you may use login.php instead RVC 5.1+)
$SOCIAL_BUTTONS_LOGIN_SCREEN = true;	// 'true' or 'false'


// CONNECTION SETTINGS
/* User connection timing */
$MINIMUM_CONNECTED_TIME = 2;			// the minimum time in seconds, two users must stay connected before they can press NEXT (global)
$TIME_TO_LIVE = 10; 					// set the delay, seconds (close the session if the server doesn't receive a response for XX seconds)
/* SpeedChat and SpeedDate connection timing settings */
$SPEEDCHAT_CONNECTED_TIME = 5;			// the default time for speedchat (if not set different by the client, using the Flash slider)
$SPEEDCHAT_MIMIMUM_CONNECTED_TIME = 3;	// the minimum time a user must stay connected before he can disconnect when using SpeedChat
$SPEEDDATE_CONNECTED_TIME = 30;			// the default time for speeddate (if not set different by the client, using the Flash slider)
$SPEEDDATE_MINIMUM_CONNECTED_TIME = 10;	// the minimum time a user must stay connected before he can disconnect when using SpeedDate
/* User filtering and ban*/
$FILTER_TIMEOUT = 30;					// set the filter button, minutes (do not connect to filtered user for XX minutes)
$NUM_REPORTS_TO_BAN = 3;				// set the report button (number of reports needed for a user to be banned)
$BAN_TIMEOUT = 180;						// set the report button, minutes (ban reported user for XX minutes)
/* Maintenance settings */
$REMOVE_SESSIONS_OLDER_THAN = '180';	// set the amount of time, minutes, sessions to be cleared by the ?task=cleanAllOlder function


// UI SETTINGS
/* Language settings */
$LANGUAGES = array("en"=>"English", "es"=>"Spanish", "cn"=>"Chinese", "de"=>"German", "it"=>"Italian", "fr"=>"French", "tr"=>"Turkish", "cz"=>"Czech", "ro"=>"Romanian", "hu"=>"Hungarian");
/* Timed video blur effect */
$BLUR_EFFECT = false;					// true or false (on|off)
$BLUR_EFFECT_INTENSITY = 30;			// initial intensity of video blur
$BLUR_EFFECT_DURATION = 5;				// seconds
/* Volume settings */
$SPEAKER_VOLUME = 0.5;					// [0-1]
$MICROPHONE_VOLUME = 0.3;				// [0-1]
/* Ad settings */
$AD_FOLDER = './media/video/blankscreen/';	// for video ads, directory where .swf videos are located
$ADS_FREQUENCY=60;							// for text ads (/jabbercam/media/text). Seconds, 0 for off


// FEATURE AND FILTER SETTINGS
/* Auto NEXT Settings */
$AUTONEXT_VALUES = array("man"=>0, "5"=>5, "10"=>10, "30"=>30, "1min"=>60);
/* Age filter settings */
$AGEFILTER_VALUES = array("Off", "16-25", "26-40", "41+");
/* Language (country) filter settings */
$LANG_FILTERS = array("en"=>"English", "es"=>"Spanish", "cn"=>"Chinese", "ru"=>"Russian", "de"=>"German", "it"=>"Italian", "fr"=>"French", "th"=>"Thai", "tr"=>"Turkish", "cz"=>"Czech", "bg"=>"Bulgarian", "ro"=>"Romanian", "hu"=>"Hungarian");
/* Custom filter #1 settings */
$CUSTOM_FILTER_1_ENABLE = true;			// 'true' or 'false'
$CUSTOM_FILTER_1_LABEL = "Location";	// any label (text)
$CUSTOM_FILTER_1 = array("paris"=>"Paris", "london"=>"London", "sanghai"=>"Sanghai", "rome"=>"Rome", "moscow"=>"Moscow", "tokyo"=>"Tokyo", "anyother"=>"Any Other");	// option list (text)
/* Custom filter #2 settings */
$CUSTOM_FILTER_2_ENABLE = true;			// 'true' or 'false'
$CUSTOM_FILTER_2_LABEL = "Looking for";	// any label (text) 
$CUSTOM_FILTER_2 = array("dating"=>"Dating", "friends"=>"Make Friends", "look"=>"Just Look", "talk"=>"Just Talk");	// option list (text)


/*
---------------------------------------------------------------------------------------------
*/

if($SERVER_TYPE == 'Red5') {
	$DB_HOST = $RED5_DB_HOST;
	$DB_USER = $RED5_DB_USER;
	$DB_PASSWORD = $RED5_DB_PASSWORD;
	$DB_DATABASE = $RED5_DB_DATABASE;
}

if(isset($_GET['setts'])) {
	header('Content-type: text/xml');
	echo '<?xml version="1.0" encoding="utf-8"?><settings><serverType>'.$SERVER_TYPE.'</serverType>';
	
	if($SERVER_TYPE != 'Red5') {
		echo '<webServiceUrl>'.$WEB_SERVICE_URL.'</webServiceUrl>'.
		'<developerKey>'.$DEVELOPER_KEY.'</developerKey>';
	} else {
		echo '<red5ConnectUrl>'.$RED5_CONNECT_URL.'</red5ConnectUrl>';
		
		if(isset($RED5_CONNECT_URL_B1))
		echo '<red5ConnectUrlB1>'.$RED5_CONNECT_URL_B1.'</red5ConnectUrlB1>';
		
		if(isset($RED5_CONNECT_URL_B2))
		echo '<red5ConnectUrlB'.(isset($RED5_CONNECT_URL_B1)?'2':'1').'>'.$RED5_CONNECT_URL_B2.
			'</red5ConnectUrlB'.(isset($RED5_CONNECT_URL_B1)?'2':'1').'>';
		
		if(isset($RED5_CONNECT_MAIN_TIMEOUT) && (isset($RED5_CONNECT_URL_B1) || isset($RED5_CONNECT_URL_B2)))
		echo '<red5ConnectMainTimeout>'.$RED5_CONNECT_MAIN_TIMEOUT.'</red5ConnectMainTimeout>';
	}
	
	echo '<languages>';
	foreach ($LANGUAGES as $code=>$lang) {
		echo "<lang><label><![CDATA[$lang]]></label><code>$code</code></lang>";
	}
	echo '</languages>';
	
	echo '<langFilters>';
	foreach($LANG_FILTERS as $code=>$lang) {
		echo "<filter><label><![CDATA[$lang]]></label><code>$code</code></filter>";
	}
	echo '</langFilters>';
	
	echo '<timeToLive>'.$TIME_TO_LIVE.'</timeToLive>';
	
	echo '<minimumConnectedTime>'.$MINIMUM_CONNECTED_TIME.'</minimumConnectedTime>';
	echo '<speedChatConnectedTime>'.$SPEEDCHAT_CONNECTED_TIME.'</speedChatConnectedTime>';
	echo '<speedChatMinimumConnectedTime>'.$SPEEDCHAT_MIMIMUM_CONNECTED_TIME.'</speedChatMinimumConnectedTime>';
	echo '<speedDateConnectedTime>'.$SPEEDDATE_CONNECTED_TIME.'</speedDateConnectedTime>';
	echo '<speedDateMinimumConnectedTime>'.$SPEEDDATE_MINIMUM_CONNECTED_TIME.'</speedDateMinimumConnectedTime>';
	
	echo '<ageFilterValues>';
	foreach($AGEFILTER_VALUES as $filter) {
		echo "<filter><![CDATA[$filter]]></filter>";
	}
	echo '</ageFilterValues>';
	
	echo '<autoNextValues>';
	foreach($AUTONEXT_VALUES as $label=>$value) {
		echo "<autoNext><label><![CDATA[$label]]></label><autoValue><![CDATA[$value]]></autoValue></autoNext>";
	}
	echo '</autoNextValues>';
	
	if(is_dir($AD_FOLDER) === TRUE) {
		echo '<ads>';
		$dir = opendir($AD_FOLDER);
		
		if($dir) {
			while(($filename = readdir($dir)) != FALSE) {
				if(is_file($AD_FOLDER.$filename) && preg_match('/^.+\.(?:jpg|png|gif|jpeg|swf)$/', $filename))
				echo "<ad>{$AD_FOLDER}{$filename}</ad>";
			}
			
			closedir($dir);
		}
		
		echo '</ads>';
	}
	
	if($CUSTOM_FILTER_1_ENABLE) {
		echo '<customFilter1 label="'.$CUSTOM_FILTER_1_LABEL.'">';
		foreach($CUSTOM_FILTER_1 as $key=>$value) {
			echo "<filter><filterValue>$key</filterValue><label>$value</label></filter>";
		}
		echo '</customFilter1>';
	}
	
	if($CUSTOM_FILTER_2_ENABLE) {
		echo '<customFilter2 label="'.$CUSTOM_FILTER_2_LABEL.'">';
		foreach($CUSTOM_FILTER_2 as $key=>$value) {
			echo "<filter><filterValue>$key</filterValue><label>$value</label></filter>";
		}
		echo '</customFilter2>';
	}
	
	echo '<loginScreenEnable>'.($LOGIN_SCREEN_ENABLE?'true':'false').'</loginScreenEnable>';
	echo '<cameraRequired>'.($CAMERA_REQUIRED?'true':'false').'</cameraRequired>';
	
	echo '<speakerVolume>'.$SPEAKER_VOLUME.'</speakerVolume>';
	echo '<microphoneVolume>'.$MICROPHONE_VOLUME.'</microphoneVolume>';
	
	echo '<blurEffect>'.($BLUR_EFFECT?'true':'false').'</blurEffect>';
	echo '<blurEffectIntensity>'.$BLUR_EFFECT_INTENSITY.'</blurEffectIntensity>';
	echo '<blurEffectDuration>'.$BLUR_EFFECT_DURATION.'</blurEffectDuration>';
	
	echo '<googleAppId>'.$GOOGLE_APP_ID.'</googleAppId>';
	
	echo '<socialButtonsLoginScreen>'.($SOCIAL_BUTTONS_LOGIN_SCREEN?'true':'false').'</socialButtonsLoginScreen>';
	
	echo '<adsFrequency>'.$ADS_FREQUENCY.'</adsFrequency>';
	
	echo '</settings>';
}
?>