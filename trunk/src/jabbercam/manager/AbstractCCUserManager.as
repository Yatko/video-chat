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
package jabbercam.manager
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
 	
 	[Event(name="settingUpdateSuccess", type="com.jabbercam.manager.events.IdManagerEvent")]
 	[Event(name="preferenceUpdateSuccess", type="com.jabbercam.manager.events.IdManagerEvent")]
 	[Event(name="filterSuccess", type="com.jabbercam.manager.events.IdManagerEvent")]
 	[Event(name="reportSuccess", type="com.jabbercam.manager.events.IdManagerEvent")]
 	[Event(name="peerBanned", type="com.jabbercam.manager.events.IdManagerEvent")]
 	public class AbstractCCUserManager extends EventDispatcher
 	{
 		/**
 		 * Dispatched when user id registartion succeeds.
 		 */
 		[Event(name="registerSuccess", type="Event")]
 		
 		/**
 		 * Dispatched when user id registration failed.
 		 */
 		[Event(name="registerFailure", type="IdManagerError")]
 		
 		/**
 		 * Dispatched when user lookup failed.
 		 */
 		[Event(name="lookupFailure", type="IdManagerError")]
 		 		
 		 /**
 		  * Dispatched when user lookup suceeded. The evnt containns both
 		  * the user name and id.  This event also dispatched when the user is not,
 		  * registered, in this case, the id in the event is empty. 
 		  */
 		[Event(name="lookupSuccess", type="IdManagerEvent")]
 		
 		/**
 		 * Error during user lookup.
 		 */
 		[Event(name="idManagerError", type="IdManagerError")]
 		
 		 /**
 		 * 
 		 */
 		[Event(name="updateSexSuccess", type="IdManagerEvent")]
 		
 		/**
 		 * 
 		 */
 		[Event(name="updateSexFailure", type="IdManagerError")]
 		 
 		[Event(name="updateAgeSuccess", type="IdManagerEvent")]
 		
 		[Event(name="updateAgeFailure", type="IdManagerError")]

 		/**
 		 * 
 		 */
 		[Event(name="usersOnlineSuccess", type="IdManagerEvent")]
 		 		
 		/**
 		 * Register a user ID with 
 		 * @param age int - valid values are [0, AgeIntervals.intervals.length-1]
 		 */
 		public function register(id:String, settings : Array = null, prefs : Array = null):void
 		{
 			doRegister(id, settings, prefs);
 		}
 		
 		/**
 		 * Save conversation
 		 */
 		public function saveChat(sId:String, dId:String, msg:String):void
 		{
 			doSaveChat(sId, dId, msg);
 		}
 		
 		/**
 		 * Update a user's sex
 		 */
 		public function updateSex(id:String, sex:String):void
 		{
 			doUpdateSex(id, sex);
 		}
 		
 		/**
 		 * Update the user's age 
 		 * @param id <code>String</code><p>The id of the current user</p> 
 		 * @param age <code>int</code><p>Valid values are <code>[0, AgeIntervals.intervals.length-1]</code></p>
 		 */
 		public function updateAge(id : String, age : int = 0) : void {
 			doUpdateAge(id, age);
 		}
 		
 		public function updateSetting(id : String, settName : String, settValue : *) : void {
 			doUpdateSetting(id, settName, settValue);
 		}
 		
 		public function updatePreference(id : String, prefName : String, prefValue : *) : void {
 			doUpdatePref(id, prefName, prefValue);
 		}
 		
 		/**
 		 * Get the number of users online
 		 */
 		public function usersOnline():void
 		{
 			doUsersOnline();
 		} 
 		
 		/**
 		 * Lookup remote user id.
 		 */
 		public function lookup(sex:String, age : int = 0, lookupExcludeIds : Array = null):void
 		{
 			doLookup(sex, age, lookupExcludeIds);
 		}
 		
 		public function lookupByName(username : String) : void {
 			doLookupByName(username);
 		}
 		
 		/**
 		 * Unregister from lookup service 
 		 */ 
 		 public function unregister():void
 		 {
 		 	doUnregister();
 		 }
 		 
 		 /**
 		  * Configure service information 
 		  */
 		 public function set service(service:Object):void
 		 {
 		 	doSetService(service);
 		 }
 		 
 		 public function filterOut(otherUserId : String) : void {
 		 	doFilterOut(otherUserId);
 		 }
 		 
 		 public function report(otherUserId : String) : void {
 		 	doReport(otherUserId);
 		 }
 		 
 		 public function close() : void {
 		 	doClose();
 		 }
		 
		 public function stop() : void {
			 doStop();
		 }
 		 
 		 public function markUser(otherUserId : String) : void {
 		 	doMark(otherUserId);
 		 }
 		 
 		 public function connectToPeer(otherUserId : String) : void {
 		 	doConnectToPeer(otherUserId);
 		 }
 		 
 		 public function disconnect() : void {
 		 	doDisconnect();
 		 }
 		 
 		 public function checkUsernameAvailability(username : String) : void {
 		 	doCheckUsernameAvailability(username);
 		 }
 		
 		 protected function doRegister(id:String, settings : Array = null, prefs : Array = null):void
 		 {
 		 	// MUST override, failure by default
 			var e:Event = new Event("registerFailure");
 			dispatchEvent(e);
 		 }
 		 
 		 protected function doSaveChat(sId:String, dId:String, msg:String):void
 		 {
 		 	// MUST override
 		 }
 		 
 		 protected function doUpdateSex(id:String, sex:String):void
 		 {
 		 	// MUST override, failure by default
 		 	var e:Event = new Event("updateSexFailure");
 		 	dispatchEvent(e);
 		 }
 		 
 		 protected function doUpdateAge(id : String, age : int = 0) : void {
// 		 	Stub
 		 }
 		 
 		 protected function doUsersOnline():void
 		 {
 		 	// MUST override, failure by default
 		 	var e:Event = new Event("usersOnlineFailure");
 		 	dispatchEvent(e);
 		 }
 		 
 		 protected function doLookup(sex:String, age : int = 0, lookupExcludeIds : Array = null):void
 		 {
 		 	// MUST override, failure by default
 			var e:Event = new Event("lookupFailure");
 			dispatchEvent(e);
 		 }
 		 
 		 protected function doLookupByName(username : String) : void {
 		 	
 		 }
 		 
 		 protected function doUnregister():void
 		 {
 		 	// MUST override
 		 }
 		 
 		 protected function doSetService(service:Object):void
 		 {
 		 	// MUST override
 		 }
 		 
 		 protected function doFilterOut(otherUserId : String) : void {
 		 	
 		 }
 		 
 		 protected function doReport(otherUserId : String) : void {
 		 	
 		 }
 		 
 		 protected function doClose() : void {
 		 	
 		 }
		 
		 protected function doStop() : void {
			 
		 }
 		 
 		 protected function doUpdateSetting(id : String, settName : String, settValue : *) : void {
 		 	
 		 }
 		 
 		 protected function doUpdatePref(id : String, prefName : String, prefValue : *) : void {
 		 	
 		 }
 		 
 		 protected function doMark(otherUserId : String) : void {
 		 	
 		 }
 		 
 		 protected function doConnectToPeer(otherUserId : String) : void {
 		 	
 		 }
 		 
 		 protected function doDisconnect() : void {
 		 	
 		 }
 		 
 		 protected function doCheckUsernameAvailability(username : String) : void {
 		 	
 		 }
 	}
}