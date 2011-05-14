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
package jabbercam.manager.events
{
	import flash.events.Event;

	public class IdManagerEvent extends Event
	{
		public static const USER_MARK_RESPONSE : String = "userMarkResponse";
		public static const SETTING_UPDATE_SUCCESS : String = "settingUpdateSuccess";
		public static const PREFERENCE_UPDATE_SUCCESS : String = "preferenceUpdateSuccess";
		public static const FILTER_SUCCESS : String = "filterSuccess";
		public static const REPORT_SUCCESS : String = "reportSuccess";
		public static const PEER_BANNED : String = "peerBanned";
		public static const REGISTER_SUCCESS : String = "registerSuccess";
		public static const USERNAME_AVAILABLE_RESPONSE : String = "usernameAvailableResponse";
		public static const DISCONNECT_RESPONSE : String = "disconnectResponse";
		
		public var id:String;
		public var sex:String;
		
		public var name : String;
		public var value : *;
		
		public var reportTotal : int;
		
		public var ccode : String;
		public var country : String;
		
		public function IdManagerEvent(type:String, id:String = "", sex:String = "", bubbles : Boolean = false,
			cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.id = id;
			this.sex = sex;
		}
		
		override public function clone():Event
		{
			return new IdManagerEvent(type, id, sex);
		}
	}
}