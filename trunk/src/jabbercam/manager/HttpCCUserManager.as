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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import jabbercam.manager.events.IdManagerError;
	import jabbercam.manager.events.IdManagerEvent;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
			
	[Event(name="userMarkResponse", type="com.jabbercam.manager.events.IdManagerEvent")]
 	public class HttpCCUserManager extends AbstractCCUserManager
 	{	
 		private var mHttpService:HTTPService = null;
 		private var mHttpTalksService:HTTPService = null;
 		
 	 	private var mWebServiceUrl:String = "";
		
		private var mConnectionTimer:Timer;
		private var mSex:String;
		private var _age : int;
		private var mId:String;
		private var mFilterSex:String;
		private var mActiveRequest:String;
		
		override protected function doSetService(service:Object):void
		{
			mWebServiceUrl = service as String;
		}
 		
 		override protected function doRegister(id:String, settings : Array = null, prefs : Array = null):void
 		{
 			if (mWebServiceUrl.length == 0)
 			{
				var e:Event = new IdManagerError("registerFailure", "Empty web service URL, user, or id");
 				dispatchEvent(e);			
 			}
 			
 			mId = id;
 			if(settings) {
 				if(settings.length > 1)
	 			mSex = settings[1];
	 			if(settings.length > 3)
	 			_age = settings[3];
 			}
 			
 			// register the id to http service
            mHttpService = new HTTPService();
            mHttpService.url = mWebServiceUrl;
            mHttpService.addEventListener("result", httpResult);
            mHttpService.addEventListener("fault", httpFault);
            
            mHttpTalksService = new HTTPService();
            mHttpTalksService.url = mWebServiceUrl;
            mHttpTalksService.addEventListener("result", httpTalksResult);
            mHttpTalksService.addEventListener("fault", httpTalksFault);
                
            if(mId != "") {
	            var request:Object = new Object();
	            if(settings)
	            request.settings = settings.join(",");
	            if(prefs)
	            request.prefs = prefs.join(",");
	            request.id = mId;
	            request.task = "register";
	            mHttpService.cancel();
	            mActiveRequest = "register";
	            mHttpService.send(request);
	                
	            // refresh registration with web service in every 20 seconds
				mConnectionTimer = new Timer(1000 * 20 * 1);
				mConnectionTimer.addEventListener(TimerEvent.TIMER, onConnectionTimer);
	            mConnectionTimer.start();
            }
 		}
 		
 		override protected function doSaveChat(sId:String, dId:String, msg:String):void
 		{
 			if (mHttpTalksService)
 			{
 				var request:Object = new Object();
 				request.sId = sId;
 				request.dId = dId;
 				request.msg = escape(msg);
 				var now:Date = new Date();
				request.time = now.getTime();
				mHttpTalksService.send(request);
 			}
 		}
 		
 		override protected function doUpdateSex(id:String, sex:String):void
 		{
  			if (mHttpService)
 			{
 				doUpdateSetting(id, "sex", sex);
				mSex = sex;
				mActiveRequest = "updateSex";
 			}
 			else
 			{
 				var e:Event = new IdManagerError("updateSexFailure", "HTTP service not created");
 				dispatchEvent(e);
 			}
 		}
 		
 		override protected function doUpdateAge(id:String, age : int = 0):void
 		{
  			if (mHttpService)
 			{
 				doUpdateSetting(id, "age", age);
				_age=age;
				mActiveRequest = "updateAge";
 			}
 			else
 			{
 				var e:Event = new IdManagerError("updateAgeFailure", "HTTP service not created");
 				dispatchEvent(e);
 			}
 		}
 		
 		override protected function doUsersOnline():void
 		{
 			if (mHttpService) 
 			{
 				var request:Object = new Object();
 				request.task = "count";
 				var now:Date = new Date();
 				request.time = now.getTime();
// 				mHttpService.cancel();
 				mActiveRequest = "usersOnline";
 				mHttpService.send(request);
 			} else {
 				var e:Event = new IdManagerError("usersOnlineFailure", "HTTP service not created");
 				dispatchEvent(e);
 			}
 		}
 		
 		override protected function doLookup(sex:String, age : int = 0, lookupExcludeIds : Array = null):void
 		{
 			if (mHttpService)
 			{
 				var request:Object = new Object();
				request.id = mId;
				request.task = "findUser";
//				request.excludeIds = lookupExcludeIds?lookupExcludeIds.join(","):"";
				mFilterSex = sex;
				// when making repeated calls to the same user, it seemed that
				// we recived cached result. So add time, to it to make it unique.
				var now:Date = new Date();
				request.time = now.getTime();
				mHttpService.cancel();
				mActiveRequest = "lookup";
				mHttpService.send(request);
 			}
 			else
 			{
 				var e:Event = new IdManagerError("lookupFailure", "HTTP service not created");
 				dispatchEvent(e);
 			}
 		}
 		
 		override protected function doLookupByName(username : String) : void {
 			if(mHttpService) {
 				var req : Object = new Object();
 				req.id = mId;
 				req.task = "findUserByName";
 				req.time = new Date().time;
 				req.username = username;
 				mHttpService.cancel();
 				mActiveRequest = "lookup";
 				mHttpService.send(req);
 			}
 		}
 		
 		override protected function doUnregister():void
 		{
 			if (mHttpService)
			{
				var request:Object = new Object();
				request.id = mId;
				request.task = "unregister";
				request._c = new Date().time;
				mHttpService.cancel();
				mActiveRequest = "unregister";
				mHttpService.send(request);
			}
					
			if (mConnectionTimer)
			{
 				mConnectionTimer.stop();
 				mConnectionTimer = null;
 			}	
 		}
 		
 		override protected function doFilterOut(otherUserId:String):void {
 			var request : Object = new Object();
 			request.task = "filterOutIp";
 			request.id = mId;
 			request.otherId = otherUserId;
 			request.time = new Date().time;
 			mHttpService.send(request);
 		}
 		
 		override protected function doReport(otherUserId:String):void {
 			var request : Object = new Object();
 			request.task = "reportUser";
 			request.id = mId;
 			request.otherId = otherUserId;
 			request.time = new Date().time;
 			mHttpService.send(request);
 		}
 		
 		override protected function doClose():void {
 			if(mHttpService) {
 				mHttpService.cancel();
 				mHttpService.disconnect();
 			}
 			
 			if(mHttpTalksService) {
 				mHttpTalksService.cancel();
 				mHttpTalksService.disconnect();
 			}
 			
 			if(mConnectionTimer) {
 				mConnectionTimer.stop();
 				mConnectionTimer = null;
 			}
 		}
 		
 		override protected function doUpdateSetting(id : String, settName : String, settValue : *) : void {
 			if (mHttpService)
 			{
 				var request:Object = new Object();
				request.id = id;
				request.name = settName;
				request.value = settValue;
				request.task = "updateSetting";
				
				var now:Date = new Date();
				request.time = now.getTime();
				mHttpService.cancel();
				mActiveRequest = "updateSetting";
				mHttpService.send(request);
 			}
 		}
 		
 		override protected function doUpdatePref(id:String, prefName:String, prefValue:*):void {
 			if (mHttpService)
 			{
 				var request:Object = new Object();
				request.id = id;
				request.name = prefName;
				request.value = prefValue;
				request.task = "updatePreference";
				
				var now:Date = new Date();
				request.time = now.getTime();
				mHttpService.cancel();
				mActiveRequest = "updatePreference";
				mHttpService.send(request);
 			}
 		}
 		
 		override protected function doMark(otherUserId:String):void {
 			if(mHttpService) {
 				var request : Object = new Object();
 				request.id = otherUserId;
 				request.task = "mark";
 				request.time = new Date().time;
 				mHttpService.send(request);
 			}
 		}
 		
 		override protected function doConnectToPeer(otherUserId:String):void {
 			if(mHttpService) {
 				var request : Object = new Object();
 				request.id = mId;
 				request.otherId = otherUserId
 				request.task = "connectToPeer";
 				request.time = new Date().time;
 				mHttpService.send(request);
 			}
 		}
 		
 		override protected function doDisconnect():void {
 			if(mHttpService) {
 				var request : Object = new Object();
 				request.id = mId;
 				request.task = "disconnect";
 				request.time = new Date().time;
 				mHttpService.send(request);
 			}
 		}
 		
 		override protected function doCheckUsernameAvailability(username:String):void {
 			if(mHttpService) {
 				var request : Object = new Object();
 				request.username = username;
 				request.task = 'checkuseravailable';
 				request.time = new Date().time;
 				mHttpService.send(request);
 			}
 		}
 		
 		// we need to refresh regsitration with web service periodically
		private function onConnectionTimer(e:TimerEvent):void
		{		
			var request:Object = new Object();
            request.task = "update";
           	request.id = mId;
           	var now:Date = new Date();
			request.time = now.getTime();
//            mHttpService.cancel();
            mHttpService.send(request);
		}

		private function httpTalksFault(e:FaultEvent):void
 		{

 		}
 	
 		private function httpTalksResult(e:ResultEvent):void
 		{
 
 		}
		
 		// process error from web service
		private function httpFault(e:FaultEvent):void
		{	
			//var d:IdManagerError = new IdManagerError("idManagerError", "HTTP error: " + e.message.toString());
			var d:IdManagerError = new IdManagerError("idManagerError", "HTTP error: " + e.fault.faultString);
 			dispatchEvent(d);
		}
		
		// process successful response from web service		
		private function httpResult(e:ResultEvent):void
		{	
			var result:Object = e.result as Object;
			var remote:Object;
			if (!result.result) {
				var d1 : IdManagerError;
				switch (mActiveRequest) {					
					case "lookup":
						d1 = new IdManagerError("idManagerError", "lookup has no result");
					break;
					default:
						d1 = new IdManagerError("idManagerError", "HTTP response has no result");
				}
 				dispatchEvent(d1);
 				return;
			}		
			if (result.hasOwnProperty("result"))
			{
				if(result.result.hasOwnProperty("banned")) {
					var b : IdManagerError = new IdManagerError("registerFailure", "banned");
					b.data = result.result.banned.banTime;
					dispatchEvent(b);
				} else if(result.result.hasOwnProperty('blocked')) {
					var bl : IdManagerError = new IdManagerError("registerFailure", "blocked");
					dispatchEvent(bl);
				} else
				if (result.result.hasOwnProperty("register"))
				{
					// registration response
					if (result.result.register == true)
					{
						var d:IdManagerEvent = new IdManagerEvent("registerSuccess");
						d.ccode = result.result.register.ccode;
						d.country = result.result.register.country;
 						dispatchEvent(d);
					}
					else
					{
						d1 = new IdManagerError("registerFailure", "HTTP update error");
 						dispatchEvent(d1);
					}
				}
				else if (result.result.hasOwnProperty("updateSetting"))
				{
					var res : Object = result.result.updateSetting;
					if(res.settName.toString().search(/sex|age/) > -1) {
						if (res == true)
						{
							var s:Event = new Event(res.settName.toString()=="sex"?
								"updateSexSuccess":"updateAgeSuccess");
							dispatchEvent(s);
						} else
						{
							d1 = new IdManagerError(res.settName.toString()=="sex"?
								"updateSexFailure":"updateAgeFailure", res.settName.toString()
									=="sex"?"HTTP update sex error":"HTTP update age error");
							dispatchEvent(d1);
						}
					} else {
						if(res == true) {
							var s1 : IdManagerEvent = new IdManagerEvent(IdManagerEvent.SETTING_UPDATE_SUCCESS,
								mId, "");
							s1.name = res.settName;
							s1.value = res.settValue;
							
							dispatchEvent(s1);
						}
					}
				}
				else if (result.result.hasOwnProperty("updatePreference"))
				{
					var res1 : Object = result.result.updatePreference;
					if(res1 == true) {
						var s2 : IdManagerEvent = new IdManagerEvent(IdManagerEvent.PREFERENCE_UPDATE_SUCCESS,
							mId, "");
						s2.name = res1.prefName;
						s2.value = res1.prefValue;
						
						dispatchEvent(s2);
					}
				}
				else if (result.result.hasOwnProperty("findUser"))
				{
					// lookup response
					var otherIdentity:String = result.result.findUser;
					var r:Event;
					if(otherIdentity && otherIdentity != "")
					r = new IdManagerEvent("lookupSuccess", otherIdentity, mFilterSex);
					else
					r = new IdManagerError("idManagerError", "lookup has no result");
					dispatchEvent(r);
				} else if (result.result.hasOwnProperty("count"))
				{
					// parse response
					var usersOnline:String = result.result.count;
					var u:IdManagerEvent = new IdManagerEvent("usersOnlineSuccess", usersOnline, "");
					dispatchEvent(u);
				} else if (result.result.hasOwnProperty("talks"))
				{
					
				} else if(result.result.hasOwnProperty("filterOutIp"))
				{
					if(result.result.filterOutIp) {
						var fEv : IdManagerEvent = new IdManagerEvent(IdManagerEvent.FILTER_SUCCESS);
						fEv.value = result.result.filterOutIp.filterTime;
						
						dispatchEvent(fEv);
					}
				} else if(result.result.hasOwnProperty("reportUser"))
				{
					var rEv : IdManagerEvent;
					rEv = new IdManagerEvent(IdManagerEvent.REPORT_SUCCESS);
					rEv.reportTotal = result.result.reportUser.reportToBan;
					rEv.value = result.result.reportUser.toString() == "banned"?rEv.reportTotal:
						result.result.reportUser.reportCount;
					dispatchEvent(rEv);
					
					if(result.result.reportUser.toString() == "banned") {
						var rEv1 : IdManagerEvent = new IdManagerEvent(IdManagerEvent.PEER_BANNED);
						rEv.reportTotal = result.result.reportUser.reportToBan;
						rEv.value = result.result.reportUser.banTime;
						
						dispatchEvent(rEv1);
					}
				}
				else if(result.result.hasOwnProperty("mark")) {
					dispatchEvent(new IdManagerEvent(IdManagerEvent.USER_MARK_RESPONSE, mId, ""));
				} else if(result.result.hasOwnProperty("checkuseravailable")) {
					var uvE : IdManagerEvent = new IdManagerEvent(IdManagerEvent.USERNAME_AVAILABLE_RESPONSE);
					uvE.name = result.result.checkuseravailable.username;
					uvE.value = result.result.checkuseravailable.toString() == "true"?true:false;
					
					dispatchEvent(uvE);
				}
			}
			else
			{
				d1 = new IdManagerError("idManagerError", "HTTP response has no result");
 				dispatchEvent(d1);

			}
		}
 	}
}