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

// ActionScript file

package com.jabbercam.crc
{
	public class Status
	{
		public static const INVALID : int = 0;
		public static const READY : int = 1;
		public static const CALLING : int = 2;
		public static const CONNECTED : int = 4 | READY;
		public static const STARTED : int = 8 | CONNECTED;
		public static const CONNECTED_TO_PEER : int = 16 | STARTED;
	}
}