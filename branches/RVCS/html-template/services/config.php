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
 *  Author: our fast growing online community at videosoftware.pro
 */
-->

<?php
$WEB_SERVICE_URL = 'http://www.YOUR-URL/rvcs/services/connect.php';
$DEVELOPER_KEY = 'ADOBE-CIRRUS-DEVELOPER-KEY';
$CAMERA_REQUIRED = true;
$SPEAKER_VOLUME = 70;
$MICROPHONE_VOLUME = 50;
$MINIMUM_CONNECTED_TIME = 5;  //off
$TIME_TO_LIVE = 45; //off

$CONNECTION_TIMEOUT = 3; // seconds

define('TIME_TO_LIVE', $TIME_TO_LIVE);

if(isset($_GET['setts'])) {
	header('Content-Type: application/octet-stream');
	header('Content-Transfer-Encoding: binary');
	header('Cache-Control: public');
	$data = pack('na'.strlen($WEB_SERVICE_URL).'na'.strlen($DEVELOPER_KEY).'Cn5',
		strlen($WEB_SERVICE_URL),$WEB_SERVICE_URL,strlen($DEVELOPER_KEY),$DEVELOPER_KEY,$CAMERA_REQUIRED,
		$SPEAKER_VOLUME,$MICROPHONE_VOLUME,$MINIMUM_CONNECTED_TIME,$TIME_TO_LIVE,$CONNECTION_TIMEOUT);
	header('Content-Length: '.strlen($data));
	
	echo $data;
}
?>