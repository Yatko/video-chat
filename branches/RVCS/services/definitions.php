<?php
define('METHOD_START', 1);
define('METHOD_DISCONNECT', (0xff >> 1) << 1);
define('METHOD_CONNECT_TO_PEER', ((0xff >> 2) << 2) | 1);
define('METHOD_DISCONNECT_FROM_PEER', 2);
define('METHOD_UPDATE',4);
define('BLOCK_SIZE', 64);
define('INDEX_BLOCK_SIZE', PHP_INT_SIZE + 1);

include_once('config.php');
?>