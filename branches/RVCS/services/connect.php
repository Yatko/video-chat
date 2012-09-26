<?php
require_once('definitions.php');

if(isset($_GET['id']))
	$id = $_GET['id'];
else
	$id = '1234567890123456789012345678901234567890123456789012345678901234';

if(!file_exists('files'))
mkdir('files');

$index = file_exists('files/peers')?(int)(filesize('files/peers')/BLOCK_SIZE):0;

$f = fopen('files/peers','ab');
if(flock($f, LOCK_EX)) {
	$ind = fopen('files/index','ab');
	flock($ind, LOCK_EX);
	fwrite($f, pack('a'.BLOCK_SIZE,$id));
	flock($f, LOCK_UN);
	fclose($f);
	
	$data=2;
	fwrite($ind,pack('Ci',$data,time()));
	flock($ind, LOCK_UN);
	fclose($ind);
}

header('Content-Type: application/octet-stream');
header('Content-Transfer-Encoding: binary');
header('Cache-Control: no-cache');
header('Content-Length: '.PHP_INT_SIZE);
echo pack('N',$index);
?>