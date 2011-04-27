<!--
/**
 * VIDEOSOFTWARE.PRO
 * Copyright 2010 VideoSoftware.PRO
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
 * Main configuration file for CRC 4+
 * You may want to edit /jabbercam/language/lang_??.xml too
 * Help: http://www.videosoftware.pro/forum/FORUM-Documentation-Quickstart-and-How-To
 */


// Database configuration for Red5, used to install database tables (for Red5 database configuration read INSTALL.txt)
$RED5_DB_HOST = "localhost";		//database host (server)
$RED5_DB_USER = "dbuser";			//database username
$RED5_DB_PASSWORD = "dbpassword";	//database password
$RED5_DB_DATABASE = "databasename";	//database name

// Database configuration for Stratus
$DB_HOST = "localhost";				//database host (server)
$DB_USER = "dbuser";				//database username
$DB_PASSWORD = "dbpassword";		//database password
$DB_DATABASE = "databasename";		//database name

// Back-en location (exact location of functions.php on your domain | http://www.your-domain.com/[folder]/jabbercam/functions.php
$WEB_SERVICE_URL = "WEB_SERVICE_URL/jabbercam/functions.php";	// http://www.your-domain.com/jabbercam/functions.php

// Flash media server settings (rtmfp or rtmp | values: Stratus or Red5)
$SERVER_TYPE = 'Red5';				// 'Red5 or 'Stratus'

if($SERVER_TYPE == 'Red5') {
	$DB_HOST = $RED5_DB_HOST;
	$DB_USER = $RED5_DB_USER;
	$DB_PASSWORD = $RED5_DB_PASSWORD;
	$DB_DATABASE = $RED5_DB_DATABASE;
}

// Red5
$RED5_CONNECT_URL = 'rtmp://www.jabbercam.com/JabberCamApp';	// leave this free, temporary resource or use your own
$RED5_CONNECT_URL_B1 = '';
$RED5_CONNECT_URL_B2 = '';
$RED5_CONNECT_MAIN_TIMEOUT = 30;								// minutes

// Stratus
$DEVELOPER_KEY = "ADOBE_DEVELOPER_KEY";							// your Adobe Stratus developer key obtained from Adobe (read INSTALL.txt)


// Login process settings (turn on/off mandatory username and camera | values: true or false)
$LOGIN_SCREEN_ENABLE = true;		// 'true' or 'false'
$CAMERA_REQUIRED = true;			// 'true' or 'false'


// User connection timing and user filtering
$MINIMUM_CONNECTED_TIME = 1;	// the minimum time in seconds, two users must stay connected before they can press NEXT (global)
$TIME_TO_LIVE = 50; 			// set the delay, seconds (close the session if the server doesn't receive a response for XX seconds)

$FILTER_TIMEOUT = 15;			// set the filter button, minutes (do not connect to filtered user for XX minutes)
$BAN_TIMEOUT = 45;				// set the report button, minutes (ban reported user for XX minutes)
$NUM_REPORTS_TO_BAN = 5;		// set the report button (number of reports needed for a user to be banned)

// SpeedChat and SpeedDate connection timing settings 
$SPEEDCHAT_CONNECTED_TIME = 5;			// the default time for speedchat (if not set different by the client, using the Flash slider)
$SPEEDCHAT_MIMIMUM_CONNECTED_TIME = 3;	// the minimum time a user must stay connected before he can disconnect when using SpeedChat
$SPEEDDATE_CONNECTED_TIME = 30;			// the default time for speeddate (if not set different by the client, using the Flash slider)
$SPEEDDATE_MINIMUM_CONNECTED_TIME = 10;	// the minimum time a user must stay connected before he can disconnect when using SpeedDate


// Maintenance settings
$REMOVE_SESSIONS_OLDER_THAN = '180';	// set the amount of time, minutes, sessions to be cleared by the ?task=cleanAllOlder function


// Feature and filter settings
$LANGUAGES = array("en"=>"English", "es"=>"Spanish", "cn"=>"Chinese", "de"=>"German", "it"=>"Italian", "fr"=>"French", "tr"=>"Turkish", "cz"=>"Czech", "ro"=>"Romanian", "hu"=>"Hungarian");
$AD_FOLDER = './media/video/blankscreen/'; // set the directory where video ads (.swf videos) are placed

$AUTONEXT_VALUES = array("man"=>0, "5"=>5, "10"=>10, "30"=>30, "1min"=>60);
$AGEFILTER_VALUES = array("Off", "16-25", "26-40", "41+");
$LANG_FILTERS = array("en"=>"English", "es"=>"Spanish", "cn"=>"Chinese", "ru"=>"Russian", "de"=>"German", "it"=>"Italian", "fr"=>"French", "th"=>"Thai", "tr"=>"Turkish", "cz"=>"Czech", "bg"=>"Bulgarian", "ro"=>"Romanian", "hu"=>"Hungarian");

$CUSTOM_FILTER_1_ENABLE = true;			// 'true' or 'false'
$CUSTOM_FILTER_1_LABEL = "Location";	// any label (text)
$CUSTOM_FILTER_1 = array("paris"=>"Paris", "london"=>"London", "sanghai"=>"Sanghai", "rome"=>"Rome", "moscow"=>"Moscow", "tokyo"=>"Tokyo", "anyother"=>"Any Other"); // option list (text)

$CUSTOM_FILTER_2_ENABLE = true;			// 'true' or 'false'
$CUSTOM_FILTER_2_LABEL = "Looking for";	// any label (text) 
$CUSTOM_FILTER_2 = array("dating"=>"Dating", "friends"=>"Make Friends", "look"=>"Just Look", "talk"=>"Just Talk");  // option list (text)

/*
---------------------------------------------------------------------------------------------
*/

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
	
	echo '</settings>';
}
?>