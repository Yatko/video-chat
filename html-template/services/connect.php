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