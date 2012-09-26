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
	$f = fopen('files/index','rb+');
	flock($f, LOCK_SH);
	$fp = fopen('files/peers','rb');
	flock($fp, LOCK_SH);
	
	$maxpeers = min((int)(filesize('files/index')/INDEX_BLOCK_SIZE)-1,$maxpeers);
	$peers = array();
	
	$peers_available = array();
	$pos = 0;
	while(($read=fread($f,100)) != false) {
		$i=0;
		while($i*INDEX_BLOCK_SIZE < strlen($read)) {
			$bytes = unpack('Cinf/itm',substr($read, $i*INDEX_BLOCK_SIZE, INDEX_BLOCK_SIZE));
			if($i+$pos == $index) {
				$pt = ftell($f);
				fseek($f, ($i+$pos) * INDEX_BLOCK_SIZE, SEEK_SET);
				fwrite($f, pack('Ci', $bytes['inf'], time()));
				fseek($f, $pt, SEEK_SET);
			} else if(($bytes['inf'] & 3) == 3 && $bytes['tm']>=time()-TIME_TO_LIVE)
				$peers_available[]=$pos+$i;
			$i++;
			
		}
		
		$pos += intval(strlen($read)/INDEX_BLOCK_SIZE);
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
		$real_peers[$peer]=implode('', $id);
	}
	
	flock($fp, LOCK_UN);
	fclose($fp);
	flock($f, LOCK_UN);
	fclose($f);
}

$contentsize = count($real_peers)>0?count($real_peers)*(BLOCK_SIZE+4):1;
header('Content-Length: '.$contentsize);
foreach($real_peers as $key=>$peer)
	echo pack('Na'.BLOCK_SIZE, $key, $peer);

if($contentsize == 1)
	echo pack('C', FALSE);
?>