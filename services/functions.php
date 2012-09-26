<?php
require_once('definitions.php');

if(isset($_GET['index']))
	$index = $_GET['index']; 
else
	$index = 2;
	
if(isset($_GET['method'])) {
	$method = $_GET['method'];
	switch($method) {
		case 'start':
			$method = METHOD_START;
			break;
		case 'disconnect':
			$method = METHOD_DISCONNECT;
			break;
		case 'connect':
			$method = METHOD_CONNECT_TO_PEER;
			break;
		case 'disconnectpeer':
			$method = METHOD_DISCONNECT_FROM_PEER;
			break;
		case 'getnumusers':
			$method = METHOD_GET_NUM_USERS;
			break;
		default:
			$method = METHOD_UPDATE;
	}
} else {
	$method = METHOD_START;
}
	
header('Content-Type: application/octet-stream');
header('Content-Transfer-Encoding: binary');
header('Cache-Control: no-cache');
header('Content-Length: 1');


if(file_exists('files/index') && $index < (int)(filesize('files/index')/INDEX_BLOCK_SIZE)) {
	$f = fopen('files/index','rb+');
	flock($f, LOCK_EX);
	
	if(fseek($f, $index*INDEX_BLOCK_SIZE, SEEK_SET) == 0) {
		$read = fread($f, INDEX_BLOCK_SIZE);
		fseek($f, -INDEX_BLOCK_SIZE, SEEK_CUR);
		$byte = unpack('Cinf/itm', $read);
		switch($method) {
			case METHOD_DISCONNECT:
			case METHOD_CONNECT_TO_PEER:
				$byte['inf'] = (int)($byte['inf'] & $method);
				break;
			case METHOD_START:
			case METHOD_DISCONNECT_FROM_PEER:
				$byte['inf'] = (int)($byte['inf'] | $method);
				break;
		}
		
		if(($method == METHOD_DISCONNECT && isset($_GET['peerindex'])) || 
			($method == METHOD_CONNECT_TO_PEER || $method == METHOD_DISCONNECT_FROM_PEER)) {
			if(isset($_GET['peerindex']))
				$peerindex = (int)$_GET['peerindex'];
			else
				$peerindex = ($index + 1) % (int)(filesize('files/index')/INDEX_BLOCK_SIZE);
			
			$curpos = ftell($f);
			fseek($f, $peerindex*INDEX_BLOCK_SIZE, SEEK_SET);
			$read = fread($f, INDEX_BLOCK_SIZE);
			fseek($f, -INDEX_BLOCK_SIZE, SEEK_CUR);
			$byte2 = unpack('Cinf/itm', $read);
			switch($method) {
				case METHOD_DISCONNECT:
				case METHOD_CONNECT_TO_PEER:
					$byte2['inf'] = (int)($byte2['inf'] & $method);
					break;
				case METHOD_DISCONNECT_FROM_PEER:
					$byte2['inf'] = (int)($byte2['inf'] | $method);
					break;
			}
			fwrite($f, pack('Ci', $byte2['inf'],time()));
			fseek($f, $curpos, SEEK_SET);
		}
		
		fwrite($f, pack('Ci',$byte['inf'],time()));
		
		if($method == METHOD_GET_NUM_USERS) {
			fseek($f, 0, SEEK_SET);
			$pos = 0;
			$peers_online = 0;
			while(($read=fread($f,100)) != false) {
				$i=0;
				while($i*INDEX_BLOCK_SIZE < strlen($read)) {
					$bytes = unpack('Cinf/itm',substr($read, $i*INDEX_BLOCK_SIZE, INDEX_BLOCK_SIZE));
					if($i+$pos != $index && ($bytes['inf'] & 3) == 3 && $bytes['tm']>=time()-TIME_TO_LIVE)
						$peers_online++;
					
					$i++;
				}
				
				$pos += intval(strlen($read)/INDEX_BLOCK_SIZE);
			}
		}
	}
	
	flock($f, LOCK_UN);
	fclose($f);
	
	if($method == METHOD_GET_NUM_USERS)
		echo pack('N',$peers_online);
	else
		echo pack('C', true);
	exit;
}
echo pack('C', false);
?>