<?php
require_once('definitions.php');

if(isset($_GET['index']))
	$index = (int)$_GET['index'];
else
	$index = 0;
	
if(isset($_GET['maxpeers']))
	$maxpeers = (int)$_GET['maxpeers'];
else
	$maxpeers = 5;
	
header('Content-Type: application/octet-stream');
header('Content-Transfer-Encoding: binary');
header('Cache-Control: no-cache');

$real_peers = array();

if(file_exists('files/index')) {
	$f = fopen('files/index','rb');
	flock($f, LOCK_SH);
	$fp = fopen('files/peers','rb');
	flock($f, LOCK_SH);
	
	$maxpeers = min((int)(filesize('files/index')/INDEX_BLOCK_SIZE)-1,$maxpeers);
	$peers = array();
	
	$peers_available = array();
	$pos = 0;
	while(($read=fread($f,100)) != false) {
		$i=0;
		while($i*INDEX_BLOCK_SIZE < strlen($read)) {
			$bytes = unpack('Cinf/itm',substr($read, $i*INDEX_BLOCK_SIZE, INDEX_BLOCK_SIZE));
			if(($bytes['inf'] & 3) == 3 && $i+$pos != $index && $bytes['tm']>=time()-TIME_TO_LIVE)
				$peers_available[]=$pos+$i;
			$i++;
			
		}
		$pos += strlen($read);
	}
	
	if(count($peers_available) > $maxpeers) {
		while(count($peers) < $maxpeers) {
			$rand = rand(0, count($peers_available));
			$peers[] = $peers_available[$rand];
			array_splice($peers_available, $rand, 1);
		}
	} else {
		$peers = $peers_available;
	}
	
	foreach($peers as $peer) {
		fseek($fp, $peer * BLOCK_SIZE, SEEK_SET);
		$read = fread($fp, BLOCK_SIZE);
		$id = unpack('a'.BLOCK_SIZE, $read);
		$real_peers[]=implode('', $id);
	}
	
	flock($f, LOCK_UN);
	fclose($f);
	flock($fp, LOCK_UN);
	fclose($fp);
}

$contentsize = count($real_peers)>0?count($real_peers)*BLOCK_SIZE:1;
header('Content-Length: '.$contentsize);
foreach($real_peers as $peer)
	echo pack('a'.BLOCK_SIZE, $peer);

if($contentsize == 1)
	echo pack('C', FALSE);
?>