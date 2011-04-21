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
	header('Content-type: text/xml');
	echo('<?xml version="1.0" encoding="utf-8"?><result>');
	
	$task = preg_replace('/^\s+|\s+$/', '', $_GET['task']);
	
	require_once("config.php");
	
	/**
	 * @param $ip String
	 * @return mixed row with country and code if ip is found in db, false otherwise
	 */
	function getCountry ( $ip ) {
	$debug = false;
	if($debug)echo $ip.'\n';
	  $ip = sprintf("%u", ip2long($ip));
	if($debug)echo $ip.'\n';
	  $query = "SELECT country,code FROM cc_country "
		. "WHERE ipfrom <= '$ip' and ipto >='$ip' LIMIT 1";
	  
	  $res = mysql_query($query);
	  if(!$res)
	  return false;
	  if($debug)echo 'result is valid\n';
	  if ($row = mysql_fetch_array($res)){
	    if($debug)echo 'returning row '.$row['code'].' '.$row['country'].'\n';
	    return $row;
	  } else
	    return false;
	}
	
	$conn = mysql_connect($DB_HOST, $DB_USER, $DB_PASSWORD) or die ('Error connecting to mysql');
	mysql_select_db($DB_DATABASE);
	
	if($task != NULL && $task != '') {
		if(preg_match('/^filterOutIp$/', $task)) {
			
			$id = $_GET['id'];
			$otherId = $_GET['otherId'];
			
			$q = "INSERT INTO filters VALUES ('$id', (SELECT ip FROM sessions WHERE id='$otherId' LIMIT 1), ".
				"DEFAULT) ON DUPLICATE KEY UPDATE filter_time=CURRENT_TIMESTAMP";
			$result = mysql_query($q);
			echo '<filterOutIp filterTime="'.$FILTER_TIMEOUT.'">'.($result?'true':'false').'</filterOutIp>';
			
			
		} else if(preg_match('/^reportUser$/', $task)) {
		
			$id = $_GET['id'];
			$otherId = $_GET['otherId'];
			$q = "INSERT INTO bans VALUES ((SELECT ip FROM sessions WHERE id='$otherId' LIMIT 1), 1, DEFAULT) ".
				"ON DUPLICATE KEY UPDATE report_count=report_count+1";
			$result = mysql_query($q);
			$q = "SELECT report_count FROM bans WHERE ip=(SELECT ip FROM sessions WHERE id='$otherId' LIMIT 1) ".
				"LIMIT 1";
			$result = mysql_query($q);
			$res = mysql_fetch_array($result);
			
			if($res[0] >= $NUM_REPORTS_TO_BAN) {
			
				$q = "UPDATE bans SET report_count=0, ban_time=CURRENT_TIMESTAMP WHERE ip=(SELECT ip FROM ".
					"sessions WHERE id='$otherId' LIMIT 1) LIMIT 1";
				mysql_query($q);
				
				$q = "DELETE sessions, filters, user_settings, user_prefs, chats FROM sessions ".
				"LEFT JOIN filters ON sessions.id=filters.id LEFT JOIN user_settings ON sessions.id=user_settings.id ".
				"LEFT JOIN user_prefs ON sessions.id=user_prefs.id LEFT JOIN chats ON sessions.id=chats.peer1 || ".
				"sessions.id=chats.peer2 ".
				"WHERE sessions.id='$otherId'";
				
				mysql_query($q);
				
				echo '<reportUser reportToBan="'.$NUM_REPORTS_TO_BAN.'" banTime="'.$BAN_TIMEOUT.
					'">banned</reportUser>';
				
			} else {
			
				$q = "INSERT INTO filters VALUES ('$id', (SELECT ip FROM sessions WHERE id='$otherId' ".
					"LIMIT 1), DEFAULT) ON DUPLICATE KEY UPDATE filter_time=CURRENT_TIMESTAMP";
				mysql_query($q);
				
				echo '<reportUser reportCount="'.$res[0].'" reportToBan="'.$NUM_REPORTS_TO_BAN.
					'">true</reportUser>';
			}
			
		} else if(preg_match('/^unregister$/', $task)) {
				
			$id = $_GET['id'];
			
			$q = "DELETE sessions, filters, user_settings, user_prefs, chats FROM sessions ".
				"LEFT JOIN filters ON sessions.id=filters.id LEFT JOIN user_settings ON sessions.id=user_settings.id ".
				"LEFT JOIN user_prefs ON sessions.id=user_prefs.id LEFT JOIN chats ON sessions.id=chats.peer1 || ".
				"sessions.id=chats.peer2 ".
				"WHERE sessions.id='$id'";
			
			$result = mysql_query($q);
			
			echo '<unregister>'.($result?'true':'false').'</unregister>';
				
		} else if(preg_match('/^disconnect$/', $task)) {
				
			$id = $_GET['id'];
			
			$result = mysql_query("DELETE FROM chats WHERE peer1='$id' || peer2='$id'");
			
			echo '<disconnect>'.($result?'true':'false').'</disconnect>';	
		} else if(preg_match('/^checkuseravailable$/', $task)) {
		
			$q = "SELECT false available FROM user_settings u, sessions s WHERE u.sett_name='uname' && ".
				"u.sett_value='{$_GET['username']}' && s.id=u.id && DATE_SUB(NOW(), INTERVAL $TIME_TO_LIVE SECOND)<s.created_at ".
				"LIMIT 1";
			
			$result = mysql_query($q);
			
			$res = mysql_fetch_array($result);
			
			echo "<checkuseravailable username=\"{$_GET['username']}\">".($res && !$res['available']?"false":"true").
				"</checkuseravailable>";
		
		} else {
			
			$result = mysql_query("SELECT true blocked FROM block WHERE ip='{$_SERVER['REMOTE_ADDR']}' LIMIT 1");
			
			$res = mysql_fetch_array($result);
			
			if($res && $res['blocked']) {
				echo "<ipblocked>true</ipblocked>";
				echo "</result>";
				mysql_close($conn);
				exit(0);
			}
			
			$result = mysql_query("SELECT (IF(DATE_SUB(NOW(), INTERVAL $BAN_TIMEOUT MINUTE)>ban_time, false, ".
				"true)) banned, ($BAN_TIMEOUT-MINUTE(TIMEDIFF(NOW(), ban_time))) ban_time_left FROM bans WHERE ip='".
				"{$_SERVER['REMOTE_ADDR']}' LIMIT 1");
		
			$res = mysql_fetch_array($result);
			
			if($res && $res['banned']) {
				echo "<banned banTime=\"{$res['ban_time_left']}\">true</banned>";
			} else {
			
				if(preg_match('/^register$/', $task)) {
					
					$id = $_GET['id'];
					
					$result = mysql_query("INSERT INTO sessions (id, ip, created_at, marked, type) ".
						"VALUES('$id', '{$_SERVER['REMOTE_ADDR']}', DEFAULT, 0, 0)");
					
					$country = getCountry($_SERVER['REMOTE_ADDR']);
					$countryCode = $country?strtolower($country['code']):false;
					$country = $country?$country['country']:false;
					if($result) {
						
						
						$q = "INSERT INTO user_settings (id, sett_name, sett_value) VALUES ";
						
						$haveSettings = $countryCode?true:false;
						if($haveSettings)
						$q .= "('$id', 'ccode', '$countryCode'),";
						
						if(isset($_GET['settings'])) {
							$settings = preg_replace('/^\s+|\s+$/', '', $_GET['settings']);
							$settArr = explode(',', $settings);
							
							if(count($settArr)>1) {
								$haveSettings = true;
								for($i = 0; $i < count($settArr); $i+=2) {
									$q .= "('$id', '$settArr[$i]', '{$settArr[$i + 1]}'),";
								}
								
							}
						}
						
						$q = substr($q, 0, -1);
						if($haveSettings)
						mysql_query($q);
						
						if(isset($_GET['prefs'])) {
							$prefs = preg_replace('/^\s+|\s+$/', '', urldecode($_GET['prefs']));
							$prefsArr = explode(',', $prefs);
							
							if(count($prefsArr)>1) {
								$q = "INSERT INTO user_prefs (id, pref_name, pref_value) VALUES ";
								
								for($i = 0; $i < count($prefsArr); $i+=2) {
									$q .= "('$id', '$prefsArr[$i]', '{$prefsArr[$i + 1]}')";
									
									if($i < count($prefsArr)-2)
									$q .= ',';
								}
								
								mysql_query($q);
							}
						}
					}
				
					echo '<register ccode="'.$countryCode.'" country="'.$country.'">'.($result?'true':'false').'</register>';
					
				} else if(preg_match('/^update$/', $task)) {
				
					$id = $_GET['id'];
					$result = mysql_query("UPDATE sessions SET created_at=CURRENT_TIMESTAMP, marked=0 WHERE ".
						"id='$id' LIMIT 1");
					
					echo '<update>'.($result?'true':'false').'</update>';
				
				} else if(preg_match('/^updateSetting$/', $task)) {
				
					$id = $_GET['id'];
					$name = $_GET['name'];
					$value = $_GET['value'];
					
					$result = mysql_query("INSERT INTO user_settings (id, sett_name, sett_value) VALUES ".
						"('$id', '$name', '$value') ON DUPLICATE KEY UPDATE ".
						"sett_value='$value'");
					
					echo "<updateSetting settName=\"$name\" settValue=\"$value\">".($result?'true':'false').
						'</updateSetting>';
				
				} else if(preg_match('/^updatePreference$/', $task)) {
				
					$id = $_GET['id'];
					$name = $_GET['name'];
					$value = $_GET['value'];
					
					$result = mysql_query("INSERT INTO user_prefs (id, pref_name, pref_value) VALUES ".
						"('$id', '$name', '$value') ON DUPLICATE KEY UPDATE ".
						"pref_value='$value'");
					
					echo "<updatePreference prefName=\"$name\" prefValue=\"$value\">".($result?'true':'false').
						'</updatePreference>';
				
				} else if(preg_match('/^findUser$/', $task)) {
				
					$id = $_GET['id'];
					$excludeString = '';
					if(isset($_GET['excludeIds'])) {
						$excludeIds = explode(',', $_GET['excludeIds']);
						
						foreach($excludeIds as $excludeId)
						if($excludeId != '')
						$excludeString .= "&& s.id!=\"$excludeId\" ";
					}
					
					$q = "SELECT * FROM sessions s WHERE s.type=0 && s.id!=\"$id\" && s.marked=0 ". 
						"&& s.created_at > DATE_SUB(NOW(),INTERVAL $TIME_TO_LIVE SECOND) $excludeString && " .
						"(SELECT ip FROM sessions WHERE id=\"$id\" LIMIT 1) NOT IN (SELECT ip FROM filters " .
							"WHERE id=s.id && DATE_SUB(NOW(), INTERVAL $FILTER_TIMEOUT MINUTE)<filter_time) && " .
						"(SELECT ip FROM sessions WHERE s.id=id LIMIT 1) NOT IN (SELECT ip FROM filters WHERE id=\"".
							"$id\" && DATE_SUB(NOW(), INTERVAL $FILTER_TIMEOUT MINUTE)<filter_time) && ".
						"(SELECT COUNT(*) FROM chats WHERE peer1=s.id || peer2=s.id)=0 && " .
						"(SELECT COUNT(*) FROM user_prefs up WHERE up.id=\"$id\" && (up.pref_value=\"0\" || up.pref_value=" .
							"(IF((SELECT sett_value FROM user_settings WHERE id=s.id && sett_name=up.pref_name LIMIT 1) IS NULL," .
							"up.pref_value, (SELECT sett_value FROM user_settings WHERE id=s.id && sett_name=up.pref_name LIMIT 1)))))=".
							"(SELECT COUNT(*) FROM user_prefs WHERE id=\"$id\") && ".
						"(SELECT COUNT(*) FROM user_prefs up WHERE up.id=s.id && (up.pref_value=\"0\" || up.pref_value=" .
							"(IF((SELECT sett_value FROM user_settings WHERE id=\"$id\" && sett_name=up.pref_name LIMIT 1) IS NULL," .
							"up.pref_value, (SELECT sett_value FROM user_settings WHERE id=\"$id\" && sett_name=up.pref_name LIMIT 1)))))=".
							"(SELECT COUNT(*) FROM user_prefs WHERE id=s.id) " .
						"ORDER BY RAND() LIMIT 1";
					
					$result = mysql_query($q);
					echo mysql_error();
					if ($result) {
					
						$row = mysql_fetch_array($result);
						if(!$row)
						echo '<findUser></findUser>';
						else {
							echo '<findUser>'.$row['id'].'</findUser>';
						}
						
					} else {
					
						echo('<findUser>false</findUser>');
					}
					
				} else if(preg_match('/^findUserByName$/', $task)) {
				
					$id = $_GET['id'];
					
					$q = "SELECT * FROM sessions s WHERE s.type=0 && s.id!=\"$id\" && s.marked=0 ". 
						"&& s.created_at > DATE_SUB(NOW(),INTERVAL $TIME_TO_LIVE SECOND) && s.id=".
						"(SELECT id FROM user_settings WHERE sett_name='uname' && sett_value='{$_GET['username']}' ".
						"LIMIT 1) LIMIT 1";
					
					$result = mysql_query($q);
					echo mysql_error();
					if ($result) {
					
						$row = mysql_fetch_array($result);
						if(!$row)
						echo '<findUser></findUser>';
						else {
							echo '<findUser>'.$row['id'].'</findUser>';
						}
						
					} else {
					
						echo('<findUser>false</findUser>');
					}
				
				} else if(preg_match('/^count$/', $task)) {
				
					$result = mysql_query("select count(*) num FROM sessions WHERE created_at > ".
						"DATE_SUB(NOW(),INTERVAL $TIME_TO_LIVE SECOND) && marked=0 && type=0");
					$result = mysql_fetch_assoc( $result );
					echo('<count>'.$result['num'].'</count>');
				
				} else if(preg_match('/^mark$/', $task)) {
					
					$id = $_GET['id'];
					
					$result = mysql_query("UPDATE sessions SET marked=1 WHERE id='$id' LIMIT 1");
					
					echo '<mark>'.($result?'true':'false').'</mark>';
				
				} else if(preg_match('/^connectToPeer$/', $task)) {
				
					$id = $_GET['id'];
					$otherId = $_GET['otherId'];
					
					$result = mysql_query("SELECT 1 connected FROM chats WHERE peer1='$id' || peer1='$otherId' || ".
						"peer2='$id' || peer2='$otherId' LIMIT 1");
					
					$connected = false;
					if($result) {
						$res = mysql_fetch_array($result);
						if($res)
						$connected = $res[0];
					}
					
					if(!$connected)
					$result = mysql_query("INSERT IGNORE INTO chats (peer1, peer2) VALUES ('$id', '$otherId')");
					
					echo '<connectToPeer>'.($connected?'false':'true').'</connectToPeer>';
					
				}
				
			}
		}
	} 
	
	mysql_close($conn);
	
	echo('</result>');
?>