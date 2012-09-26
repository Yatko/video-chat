<?php
$WEB_SERVICE_URL = 'http://localhost/yatko.dev/PRJ/RVCS/services/connect.php';
$DEVELOPER_KEY = '';
$CAMERA_REQUIRED = false;
$SPEAKER_VOLUME = 70;
$MICROPHONE_VOLUME = 50;
$MINIMUM_CONNECTED_TIME = 5;
$TIME_TO_LIVE = 45;

$CONNECTION_TIMEOUT = 7; // seconds

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