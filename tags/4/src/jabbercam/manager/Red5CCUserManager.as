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
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import jabbercam.manager.events.IdManagerError;
	import jabbercam.manager.events.IdManagerEvent;
	import jabbercam.manager.events.Red5ManagerEvent;
	import jabbercam.utils.Proxy;
	
	import mx.utils.ObjectUtil;
	
	public class Red5CCUserManager extends AbstractCCUserManager
	{
		private var con : NetConnection;
		public var id : String;
		private var sex : String;
		private var age : String;
		
		public var banTime : int;
		
		public function Red5CCUserManager()
		{
			super();
		}
		
		override protected function doSetService(service:Object):void {
			this.con = service as NetConnection;
			this.con.client = this;
		}
		
		public function setId(id : String) : void {
			trace("getting id: "+id);
			this.id = id;
		}
		
		public function onPeerConnect(otherUserId : String) : void {
			trace("onPeerConnnect: "+otherUserId);
			var ev : Red5ManagerEvent = new Red5ManagerEvent(Red5ManagerEvent.PEER_CONNECT);
			ev.peerId = otherUserId;
			
			this.dispatchEvent(ev);
		}
		
		public function onPeerReconnect(otherUserId : String) : void {
			trace("onPeerReconnect: "+otherUserId);
		}
		
		public function partnerDisconnected() : void {
			trace("partnerDisconnected ");
		}
		
		public function onBanned(myId : String, banTime : int) : void {
			this.banTime = banTime;
			dispatchEvent(new IdManagerError("registerFailure", "banned", banTime));
		}
		
		public function onBlocked(myId : String) : void {
			dispatchEvent(new IdManagerError("registerFailure", "blocked"));
		}
		
		override protected function doConnectToPeer(otherUserId : String) : void {
			this.con.call("connectToUser", new Responder(connectResult, status), id, otherUserId);
		}
		
		public function connectResult(result : Boolean) : void {
			trace("connectResult: "+result);
		}
		
		override protected function doRegister(id:String, settings : Array = null, prefs : Array = null):void {
			this.con.call("register", new Responder(registerResult, status), id, settings, prefs);
		}
		
		private function registerResult(res : Object) : void {
			var ev : Event;
			if (res['result'] == true)
			{
				ev = new IdManagerEvent("registerSuccess");
				(ev as IdManagerEvent).country = res['country'];
				(ev as IdManagerEvent).ccode = res['ccode'];
			}
			else
			{
				ev = new IdManagerError("registerFailure", "HTTP update error");
			}
			
			dispatchEvent(ev);
		}
		
		private function status(status : Object) : void {
			trace("Red5CCUserManager::status ==> "+ObjectUtil.toString(status));
			var ev : IdManagerError = new IdManagerError("idManagerError", "HTTP response has no result");
 			dispatchEvent(ev);
		}
		
		override protected function doLookup(sex:String, age:int=0, lookupExcludeIds:Array=null):void {
			this.con.call("findUser", new Responder(lookupResult, lookupStatus), id);
		}
		
		private function lookupResult(id : String) : void {
			var ev:Event;
			if(id && id != "")
			ev = new IdManagerEvent("lookupSuccess", id, "b");
			else
			ev = new IdManagerError("idManagerError", "lookup has no result");
			dispatchEvent(ev);
		}
		
		override protected function doLookupByName(username : String) : void {
			this.con.call("findUserByName", new Responder(lookupResult, lookupStatus), id, username);
		}
		
		private function lookupStatus(status : Object) : void {
			var ev : IdManagerError = new IdManagerError("idManagerError", "lookup has no result");
			dispatchEvent(ev);
		}
		
		override protected function doSaveChat(sId:String, dId:String, msg:String):void {
			
		}
		
		override protected function doUnregister() : void {
			this.con.call("unregister", new Responder(unregisterResult, status), id);
		}
		
		private function unregisterResult(result : Boolean) : void {
			trace("unregister result: "+result);
		}
		
		override protected function doUpdateAge(id:String, age:int=0):void {
			this.con.call("updateSetting", new Responder(updateAgeResult, status), id, ["age", age]);
		}
		
		private function updateAgeResult(result : Boolean) : void {
			var ev : Event;
			if (result)
			{
				ev = new Event("updateAgeSuccess");
			} else
			{
				ev = new IdManagerError("updateAgeFailure", "HTTP update age error");
			}
			
			dispatchEvent(ev);
		}
		
		override protected function doUpdateSex(id:String, sex:String):void {
			this.con.call("updateSetting", new Responder(updateSexResult, status), id, ["sex", sex]);
		}
		
		private function updateSexResult(result : Boolean) : void {
			var ev : Event;
			if (result)
			{
				ev = new Event("updateSexSuccess");
			} else
			{
				ev = new IdManagerError("updateSexFailure", "HTTP update sex error");
			}
			
			dispatchEvent(ev);
		}
		
		override protected function doUsersOnline():void {
			this.con.call("numUsers", new Responder(usersOnlineResult, status));
		}
		
		private function usersOnlineResult(numUsers : int) : void {
			var ev:IdManagerEvent = new IdManagerEvent("usersOnlineSuccess", numUsers.toString(), "");
			dispatchEvent(ev);
		}
		
		override protected function doDisconnect() : void {
			this.con.call("disconnectFromUser", new Responder(disconnectResult, status), id);
		}
		
		private function disconnectResult(result : Boolean) : void {
			trace("disconnectResult: "+result);
		}
		
		override protected function doFilterOut(otherUserId:String):void {
			this.con.call("filterOutUser", new Responder(filterOutResult, status), id, otherUserId);
		}
		
		private function filterOutResult(result : int) : void {
			if(result) {
				var ev : IdManagerEvent = new IdManagerEvent(IdManagerEvent.FILTER_SUCCESS);
				ev.value = result;
				dispatchEvent(ev);
			}
		}
	
		override protected function doReport(otherUserId:String):void {
			this.con.call("reportUser", new Responder(reportResult, status), id, otherUserId);
		}
		
		private function reportResult(result : Object) : void {
			if(result && result.reportSuccess) {
				var ev : IdManagerEvent = new IdManagerEvent(IdManagerEvent.REPORT_SUCCESS);
				ev.value = result.banTime?result.reportToBan:result.reportCount;
				ev.reportTotal = result.reportToBan;
				dispatchEvent(ev);
				
//				if(result.banTime) {
//					var ev1 : IdManagerEvent = new IdManagerEvent(IdManagerEvent.PEER_BANNED);
//					ev1.value = result.banTime;
//					ev1.reportTotal = result.reportToBan;
//					
//					dispatchEvent(ev1);
//				}
				
			}
		}
		
		public function rebuildId() : void {
//			this.con.call("rebuildId", new Responder(rebuildIdResult, rebuildIdStatus), id);
		}
		
		private function rebuildIdResult(newId : String) : void {
			id = newId;
			trace("id rebuild success");
		}
		
		private function rebuildIdStatus(status : Object) : void {
			
		}
		
		public function reconnectToPeer() : void {
//			this.con.call("reconnectToPeer", new Responder(reconnectToPeerResult, status), id);
		}
		
		private function reconnectToPeerResult(result : Boolean) : void {
			trace("reconnectToPeerResult: "+result);
		}
		
		override protected function doUpdateSetting(id:String, settName:String, settValue:*):void {
			this.con.call("updateSetting", new Responder(Proxy.create(updateSettingResponder, settName, 
				settValue), status), id, [settName, settValue]);
		}
		
		private function updateSettingResponder(result : Boolean, settName : String, settValue : *) : void {
			if(result) {
				var ev : IdManagerEvent = new IdManagerEvent(IdManagerEvent.SETTING_UPDATE_SUCCESS, id, "");
				ev.name = settName;
				ev.value = settValue;
				
				dispatchEvent(ev);
			}
		}
		
		override protected function doUpdatePref(id : String, prefName : String, prefValue : *) : void {
			this.con.call("updatePref", new Responder(Proxy.create(updatePrefResponder, prefName, 
				prefValue), status), id, [prefName, prefValue]);
		}
		
		private function updatePrefResponder(result : Boolean, prefName : String, prefValue : *) : void {
			if(result) {
				var ev : IdManagerEvent = new IdManagerEvent(IdManagerEvent.PREFERENCE_UPDATE_SUCCESS, id, "");
				ev.name = prefName;
				ev.value = prefValue;
				
				dispatchEvent(ev);
			}
		}
		
		override protected function doCheckUsernameAvailability(username:String):void {
			this.con.call("checkUsernameAvailable", new Responder(Proxy.create(checkUsernameAvailabilityResponse, 
				username), status), username);
		}
		
		private function checkUsernameAvailabilityResponse(result : Boolean, username : String) : void {
			var ev : IdManagerEvent = new IdManagerEvent(IdManagerEvent.USERNAME_AVAILABLE_RESPONSE);
			ev.name = username;
			ev.value = result;
			dispatchEvent(ev);
		}
	}
}