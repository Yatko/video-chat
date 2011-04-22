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
<html><head><title>Jabbercam Admin</title>
<script type="text/javascript">
<!--
	function failedConnecting() {
		endTesting();
		document.getElementById('testStatus').innerHTML += '<br/>Red5 ERROR<br/>Stratus OFF<br/>';
	}

	function successConnecting(red5Server) {
		endTesting();
		document.getElementById('testStatus').innerHTML += '<br/>Red5 OK: '+red5Server+'<br/>Stratus OFF<br/>';
	}

	var testTimeout;
	function startTesting() {
		document.getElementById('testStatus').innerHTML = 'Testing: ';
		testing();
	}

	function testing() {
		document.getElementById('testStatus').innerHTML += '.';
		testTimeout = setTimeout('testing()', 1000);
	}

	function endTesting() {
		clearTimeout(testTimeout);
	}
-->
</script>
</head><body>

<?php 
$task = preg_replace('/^\s+|\s+$/', '', $_GET['task']);

require_once("config.php");
	
$conn = mysql_connect($DB_HOST, $DB_USER, $DB_PASSWORD) or die ('Error connecting to mysql!');
mysql_select_db($DB_DATABASE) or die ("Error selecting database $DB_DATABASE!");
	
if(preg_match('/^clean$/', $task)) {

	$result = mysql_query("DELETE sessions, filters, user_settings, user_prefs, chats FROM sessions ".
		"LEFT JOIN filters ON sessions.id=filters.id LEFT JOIN user_settings ON sessions.id=user_settings.id ".
		"LEFT JOIN user_prefs ON sessions.id=user_prefs.id LEFT JOIN chats ON sessions.id=chats.peer1 || ".
		"sessions.id=chats.peer2 ".
		"WHERE type=0 && created_at < DATE_SUB(NOW(),INTERVAL $TIME_TO_LIVE SECOND);");
	
	echo('Deleted '.mysql_affected_rows().' session(s)<br/>');
	
} else if(preg_match('/^cleanAll$/', $task)) {
		
	$result = mysql_query("TRUNCATE TABLE sessions");
	$result = mysql_query("TRUNCATE TABLE filters");
	$result = mysql_query("TRUNCATE TABLE user_settings");
	$result = mysql_query("TRUNCATE TABLE user_prefs");
	$result = mysql_query("TRUNCATE TABLE chats");
	
	echo('Cleared all sessions<br/>');
	
} else if(preg_match('/^cleanAllOlder$/', $task)) {

	$result = mysql_query("DELETE sessions, filters, user_settings, user_prefs, chats FROM sessions ".
		"LEFT JOIN filters ON sessions.id=filters.id LEFT JOIN user_settings ON sessions.id=user_settings.id ".
		"LEFT JOIN user_prefs ON sessions.id=user_prefs.id LEFT JOIN chats ON sessions.id=chats.peer1 || ".
		"sessions.id=chats.peer2 ".
		"WHERE created_at < DATE_SUB(NOW(),INTERVAL $REMOVE_SESSIONS_OLDER_THAN MINUTE);");
	
	echo('Deleted '.mysql_affected_rows().' session(s)<br/>');
	
} else if(preg_match('/^blockip$/', $task)) {

	$result = mysql_query("INSERT IGNORE INTO block VALUES(\"".urldecode($_GET['ip'])."\")");
	
	echo('Ip blocked<br/>');
	
} else if(preg_match('/^allowip$/', $task)) {

	$result = mysql_query("DELETE FROM block WHERE ip=\"".urldecode($_GET['ip'])."\"");
	
	echo ('Ip allowed<br/>');
	
} else if(preg_match('/^listblocked$/', $task)) {

	$result = mysql_query('SELECT * FROM block');
	
	if($result)
	while(($row = mysql_fetch_array($result)) != null) {
		echo $row[0].'<br/>';
	}
	
} else if(preg_match('/^install$/', $task)) {

	$result = mysql_query("SHOW TABLES");
	
	$install = true;
	if($result) {
	
		if(mysql_num_rows($result)) {
		
			$install = false;
		
			echo 'Tables already install!<br />';
			if(isset($_GET['overwrite'])) {
				if(preg_match('/yes/i', $_GET['overwrite'])) {
					echo "Overwriting because of overwrite is set to {$_GET['overwrite']}<br />";
					$install = true;
				}
			} else {
				echo 'Add &overwrite=yes to overwrite the tables!<br />';
			}
		}
	}
	
	if($install) {
	
	echo 'Installing......<br />';

	$drop_sessions = 'DROP TABLE IF EXISTS `sessions`;';
	$create_sessions=<<<EOT
	CREATE TABLE `sessions` (
	  `id` char(64) NOT NULL COMMENT 'user''s id',
	  `ip` varchar(15) NOT NULL,
	  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	  `marked` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'marked if a user tries to connect to this user but fails',
	  `type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0 for Stratus, 1 for Red5',
	  PRIMARY KEY (`id`),
	  KEY `ip` (`ip`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT;
	
	$drop_talks = 'DROP TABLE IF EXISTS `talks`;';
	
	$drop_bans = 'DROP TABLE IF EXISTS `bans`;';
	$create_bans=<<<EOT
	CREATE TABLE `bans` (
	  `ip` varchar(15) NOT NULL,
	  `report_count` int(2) NOT NULL DEFAULT '0',
	  `ban_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
	  PRIMARY KEY (`ip`),
	  KEY `ban_time` (`ban_time`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT;
	
	$drop_filters='DROP TABLE IF EXISTS `filters`;';
	$create_filters=<<<EOT
	CREATE TABLE `filters` (
	  `id` char(64) NOT NULL,
	  `ip` varchar(15) NOT NULL,
	  `filter_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `idip` (`id`,`ip`),
	  KEY `ip` (`ip`,`filter_time`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT;
	
	$drop_chats = 'DROP TABLE IF EXISTS `chats`';
	$create_chats =<<<EOT
	CREATE TABLE `chats` (
	  `peer1` char(64) NOT NULL,
	  `peer2` char(64) NOT NULL,
	  UNIQUE KEY `peer1` (`peer1`,`peer2`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='stores current chats';
EOT;
	
	$drop_user_prefs='DROP TABLE IF EXISTS `user_prefs`';
	$create_user_prefs =<<<EOT
	CREATE TABLE `user_prefs` (
	  `id` char(64) NOT NULL COMMENT 'user''s id foreign sessions.id',
	  `pref_name` varchar(6) NOT NULL COMMENT 'pref''s name',
	  `pref_value` varchar(10) NOT NULL COMMENT 'pref''s value',
	  UNIQUE KEY `prefid` (`id`,`pref_name`),
	  KEY `sortidx` (`id`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='stores user''s preferences';
EOT;
	
	$drop_user_settings = 'DROP TABLE IF EXISTS `user_settings`';
	$create_user_settings =<<<EOT
	CREATE TABLE `user_settings` (
	  `id` char(64) NOT NULL COMMENT 'user''s id foreign sessions.id',
	  `sett_name` varchar(6) NOT NULL COMMENT 'the setting''s name',
	  `sett_value` varchar(10) NOT NULL COMMENT 'setting''s value',
	  UNIQUE KEY `settid` (`id`,`sett_name`),
	  KEY `sortidx` (`id`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='stores user''s settings';
EOT;

	$drop_cc_country = 'DROP TABLE IF EXISTS `cc_country`';
	$create_cc_country =<<<EOT
	CREATE TABLE `cc_country` (
  	`ipfrom` double NOT NULL default '0',
  	`ipto` double NOT NULL default '0',
  	`code` char(3) NOT NULL default '',
  	`country` char(50) NOT NULL default '',
  	PRIMARY KEY  (`ipfrom`,`ipto`));
EOT;

	$drop_block = 'DROP TABLE IF EXISTS `block`';
	$create_block =<<<EOT
	CREATE TABLE `block` (
	`ip` varchar(15) NOT NULL,
  	PRIMARY KEY (`ip`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT;
	
	if(!mysql_query($drop_sessions))
	echo ("The user doesn't have DROP permissions! Trying to ignore this...<br />");
	else
	if(!mysql_query($drop_talks))
	die ("Something went wrong");
	
	mysql_query($drop_bans);
	
	mysql_query($drop_filters);
	
	mysql_query($drop_user_prefs);
	
	mysql_query($drop_user_settings);
	
	mysql_query($drop_chats);
	
	mysql_query($drop_cc_country);
	
	mysql_query($drop_block);
	
	if(!mysql_query($create_sessions))
	die ("Couldn't create table `sessions`");
	
	if(!mysql_query($create_bans))
	die ("Couldn't create table `bans`");
	
	if(!mysql_query($create_filters))
	die ("Couldn't create table `filters`");
	
	if(!mysql_query($create_chats))
	die ("Couldn't create table `chats`");
	
	if(!mysql_query($create_user_prefs))
	die ("Couldn't create table `user_prefs`");
	
	if(!mysql_query($create_user_settings))
	die ("Couldn't create table `user_settings`");
	
	if(!mysql_query($create_cc_country))
	die ("Couldn't create table `cc_country`");
	
	if(!mysql_query($create_block))
	die ("Couldn't create table `block`");
	
	echo 'Install complete!';

	}
	
} else if(preg_match('/^importIp$/', $task)) {
	if(!isset($_GET['action']) || $_GET['action'] == 'step1') {
	?>
	<h2>Select Import File</h2>

  <p>You will need to download a master IP to country list from one of the many providers. The <b>CSV</b> format GeoLite database by MaxMind (see <a href="http://www.maxmind.com/app/geoip_country">http://www.maxmind.com/app/geoip_country</a>) has been tested with this import script, but any other IP to country files should be compatible.</p>

<p>This file <b>must</b> be comma separated, with the columns in the following order:
<div style="text-align: center;" class="code">StartIP,EndIP,StartLong,EndLong,CountryCode,CountryName</div>
(note that the StartIP and EndIP columns are not used)</p>

<p><b>1.</b> Upload the CSV data file to the <b>ipdata</b> directory under the jabbercam directory</p>

<P><b>2.</b> Select the data file below and click next to continue the import (click <b>refresh</b> to see recently uploaded files)<br>

<form action="admin.php" method="GET">
<?php
  $dh = opendir("./ipdata");
  while (($file = readdir($dh)) !== FALSE){
    if ($file == "." || $file == ".." || substr($file,-3) == "php" || is_dir($file))
      continue;
    
     echo "<input type='radio' name='datafile' value='" . $file . "'> ";
     echo $file . "<br>";
  }
?>
	<input type="hidden" name="task" value="importIp"/>
	<input type="hidden" name="action" value="step2"/>
  <input type="submit" value="Next &gt;"/>
</form>

<?php
} elseif (isset($_GET['action']) && $_GET["action"] == "step2"){
  echo "<h2>Importing data</h2>";

  if (!isset($_GET['datafile']) || $_GET["datafile"] == "")
    die("Please <a href='admin.php?task=importIp'>go back</a> select a datafile");

  $fp = fopen('./ipdata/'.$_GET["datafile"], "r");

  while (!feof($fp)){
    $line = fgets($fp, 1024);
    if ($line == "")
      continue;

    $data = explode(",", $line);
    $country = str_replace("\"", "", $data[5]);
    $country = trim($country);

    mysql_query("INSERT INTO cc_country VALUES (" . trim($data[2],"\"") . ", " . trim($data[3],"\"") . ", "
	. "'" . trim($data[4],"\"") . "', '" . mysql_escape_string($country) . "')")
	or die("Could not complete import: " . mysql_error());
  }
?>

  <p><b>Import Complete</b>.</p>
<?php 
}
} else if(preg_match('/^test$/', $task)) {

	$tables = array('sessions', 'bans', 'block', 'filters', 'user_prefs', 'user_settings', 'chats', 'cc_country');
	
	$result = mysql_query('SHOW TABLES');
	
	if(!$result) {
		echo 'database ERROR<br>';
	} else {
		$tblcount = 0;
		while($row = mysql_fetch_array($result))
		if(in_array($row[0], $tables))
		$tblcount++;
		
		if($tblcount == count($tables)) 
			echo 'database tables OK<br>';
		else
			echo 'database tables ERROR<br>';
	}
	
	if(preg_match('/^Red5$/', $SERVER_TYPE)) {
?>
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" id="Red5Tester" width="0" height="0"	
	codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
		<param name="movie" value="Red5Tester.swf" />
		<param name="quality" value="low" />
		<param name="bgcolor" value="#ffffff" />
		<param name="allowScriptAccess" value="sameDomain" />
		<embed src="Red5Tester.swf" quality="low" bgcolor="#ffffff"
			width="0" height="0" id="Red5Tester"
			allowScriptAccess="sameDomain"
			type="application/x-shockwave-flash">
		</embed>
</object>
<div id="testStatus"></div>
<script type="text/javascript">
<!--
	startTesting();
-->
</script>
<?php 
	} else {
		echo 'Red5 OFF<br/>';
		if(preg_match('/^[0-9a-f_-]{37}$/', $DEVELOPER_KEY))
		echo 'Stratus OK<br/>';
		else 
		echo 'Stratus ERROR<br />';
	}

	if(file_exists('./functions.php')) 
		echo 'System folder OK<br />';
	else
		echo 'System folder ERROR<br />';
		
}

mysql_close($conn);
?>

</body>
</html>