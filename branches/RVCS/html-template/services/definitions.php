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
define('METHOD_START', 1);
define('METHOD_DISCONNECT', (0xff >> 1) << 1);
define('METHOD_CONNECT_TO_PEER', ((0xff >> 2) << 2) | 1);
define('METHOD_DISCONNECT_FROM_PEER', 2);
define('METHOD_UPDATE',4);
define('METHOD_GET_NUM_USERS',8);
define('BLOCK_SIZE', 64);
define('INDEX_BLOCK_SIZE', PHP_INT_SIZE + 1);

include_once('config.php');
?>