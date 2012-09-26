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

package com.jabbercam.crc.events
{
	import flash.events.Event;
	
	public class ManagerEvent extends Event
	{
		public static const CONNECT_SUCCESS : String = "connectSuccess";
		public static const CONNECT_FAILED : String = "connectFailed";
		public static const START_SUCCESS : String = "startSuccess";
		public static const START_FAILED : String = "startFailed";
		public static const STOP_SUCCESS : String = "stopSuccess";
		public static const STOP_FAILED : String = "stopFailed";
		public static const FIND_PEERS_RESPONSE : String = "findPeersResponse";
		public static const CONNECT_TO_PEER_RESPONSE : String = "connectToPeerResponse";
		public static const DISCONNECT_FROM_PEER_RESPONSE : String = "disconnectFromPeer";
		public static const NUM_USERS_REPONSE : String = "numUsersReponse";
		
		public var response : Object;
		
		public function ManagerEvent(type:String, response : Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.response = response;
		}
		
		override public function clone():Event {
			return new ManagerEvent(type, response, bubbles, cancelable);
		}
	}
}