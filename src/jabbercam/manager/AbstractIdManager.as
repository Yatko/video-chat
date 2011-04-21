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
 	
 	public class AbstractIdManager extends EventDispatcher
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
 		 * Register a user ID with 
 		 */
 		public function register(user:String, id:String):void
 		{
 			doRegister(user, id);
 		}
 		
 		/**
 		 * Lookup remote user id.
 		 */
 		public function lookup(user:String):void
 		{
 			doLookup(user);
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
 		
 		 protected function doRegister(user:String, id:String):void
 		 {
 		 	// MUST override, failure by default
 			var e:Event = new Event("registerFailure");
 			dispatchEvent(e);
 		 }
 		 
 		 protected function doLookup(user:String):void
 		 {
 		 	// MUST override, failure by default
 			var e:Event = new Event("lookupFailure");
 			dispatchEvent(e);
 		 }
 		 
 		 protected function doUnregister():void
 		 {
 		 	// MUST override
 		 }
 		 
 		 protected function doSetService(service:Object):void
 		 {
 		 	// MUST override
 		 }
 	}
 }
