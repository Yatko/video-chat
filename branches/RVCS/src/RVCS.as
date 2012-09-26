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

import com.jabbercam.crc.AbstractManager;
import com.jabbercam.crc.HttpManager;
import com.jabbercam.crc.Status;
import com.jabbercam.crc.events.ManagerEvent;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.Timer;

import mx.events.PropertyChangeEvent;
//import mx.formatters.DateFormatter;

import org.osmf.events.TimeEvent;

private namespace crc;
use namespace crc;

private var _serviceURL : String;
private var _devKey : String;
[Bindable]
public var cameraRequired : Boolean;
[Bindable]
public var speakerVolume : Number;
[Bindable]
public var microphoneVolume : int;
[Bindable]
public var minimumConnectedTime : int;

private var _timeToLive : int;

private var _connectionTimeout : int;

[Bindable]
public var manager : AbstractManager;

private var _conn : NetConnection;

private var _listener : NetStream;
private var controlStream : NetStream;
private var _recvStream : NetStream;
private var _sendStream : NetStream;

private var _delayFinder : Timer;

private var _connectionTimeoutTimer : Timer;

private var _usersOnlineTimer : Timer;
[Bindable]
public var numUsersOnline : int = 0;

[Bindable]
public var autoNext : Boolean = true;
private var _autoNextTime : int = 600;
private var _autoNextTimer : Timer;

public function loadConfig(src : String) : void {
	var urlLoader : URLLoader = new URLLoader();
	urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
	urlLoader.addEventListener(Event.COMPLETE, loadCompleted);
	urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onConfigLoadError);
	
	try {
		urlLoader.load(new URLRequest(src));
	} catch(e : Error) {
		onConfigLoadError(e);
	}
}

public function onSocialButtonClick(url : String) : void {
	try {
		navigateToURL(new URLRequest(url), "_blank");
	} catch(e : Error) {
		
	}
}

crc function loadCompleted(event : Event) : void {
	var data : ByteArray = event.target.data as ByteArray;
	_serviceURL = data.readUTF();
	_devKey = data.readUTF();
	cameraRequired = data.readBoolean();
	speakerVolume = data.readShort();
	microphoneVolume = data.readShort();
	minimumConnectedTime = data.readShort();
	_timeToLive = data.readShort();
	_connectionTimeout = data.readShort();
	
	initNCConnection();
}

crc function onConfigLoadError(e : Object) : void {
	trace(e);
}

crc function initNCConnection() : void {
	_conn = new NetConnection();
	_conn.addEventListener(NetStatusEvent.NET_STATUS, onNCStatus);
	_conn.addEventListener(IOErrorEvent.IO_ERROR, onNCIOError);
	_conn.connect("rtmfp://stratus.adobe.com/"+_devKey);
}

crc function onNCStatus(event : NetStatusEvent) : void {
	trace('netConnectionStatus: ',event.info.code,event.info.stream==controlStream, event.info.stream==_recvStream,event.info.stream==_sendStream,
		event.info.stream == _listener,controlStream,_recvStream,_sendStream,_listener);
	switch(event.info.code) {
		case "NetConnection.Connect.Success":
			ncConnectionSuccess();
			break;
		case "NetConnection.Connect.Failed":
			break;
		case "NetConnection.Connect.Rejected":
			break;
		case "NetConnection.Connect.Closed":
			break;
		case "NetStream.Connect.Closed":
			if(event.info.stream == controlStream || event.info.stream ==_recvStream) {
				stopConnectionTimeoutTimer();
				_initiatedConnection = false;
				otherVideo.stopVideo();
				getNext();
			}
			break;
	}
}

crc function onNCIOError(event : IOErrorEvent) : void {
	trace(event);
}

crc function ncConnectionSuccess() : void {
	manager = new HttpManager(_conn.nearID, _serviceURL, _timeToLive);
	manager.addEventListener(ManagerEvent.CONNECT_SUCCESS, onConnectSuccess);
	manager.addEventListener(ManagerEvent.CONNECT_FAILED, onConnectFail);
	manager.addEventListener(ManagerEvent.START_SUCCESS, onStartSuccess);
	manager.addEventListener(ManagerEvent.START_FAILED, onStartFailed);
	manager.addEventListener(ManagerEvent.FIND_PEERS_RESPONSE, onFindPeersResponse);
	manager.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onManagerStatusChanged);
	manager.addEventListener(ManagerEvent.NUM_USERS_REPONSE, onNumUsersOnlineResponse);
//	manager.connect();
}

crc function onConnectSuccess(event : ManagerEvent) : void {
	manager.start();
	getNumUsersOnline();
}

private function getNumUsersOnline(event : TimerEvent = null) : void {
	manager.getNumUsers();
}

private function onNumUsersOnlineResponse(event : ManagerEvent) : void {
	(event.response as ByteArray).endian = Endian.BIG_ENDIAN;
	numUsersOnline = (event.response as ByteArray).readUnsignedInt();
	if(!_usersOnlineTimer) {
		_usersOnlineTimer = new Timer(8000, 1);
		_usersOnlineTimer.addEventListener(TimerEvent.TIMER, getNumUsersOnline);
	}
	
	_usersOnlineTimer.reset();
	_usersOnlineTimer.start();
}

crc function onConnectFail(event : ManagerEvent) : void {
	
}

crc function onStartSuccess(event : ManagerEvent) : void {
	createListener();
	manager.findPeers();
}

crc function onStartFailed(event : ManagerEvent) : void {
	
}

private function stopFind() : void {
	if(_delayFinder) {
		_delayFinder.stop();
		_delayFinder.removeEventListener(TimerEvent.TIMER_COMPLETE, callFindPeers);
	}
}

private function findLater() : void {
	stopFind();
	
	_delayFinder = new Timer(int(Math.random()*2000)+1000, 1);
	_delayFinder.addEventListener(TimerEvent.TIMER_COMPLETE, callFindPeers);
	_delayFinder.start();
	
	manager.status |= Status.CALLING;
}

private function callFindPeers(event : TimerEvent) : void {
//	manager.status &= 0xff ^ Status.CALLING;
	manager.findPeers();
}

private var _currentPeerTried : Object = null;
crc function onFindPeersResponse(event : ManagerEvent) : void {
	if(!((manager.status & Status.CONNECTED_TO_PEER) >> 4) && ((manager.status & Status.STARTED) >> 3)) {
		if(event.response.peers.length > 0) {
			var peer : Object = event.response.peers[Math.round(Math.random()*(event.response.peers.length-1))];
			_currentPeerTried = peer;
			connectTo(peer.id);
		} else {
			findLater();
		}
	}
}

crc function onManagerStatusChanged(event : PropertyChangeEvent) : void {
	if(event.property.toString() == "status") {
		if((manager.status & Status.CONNECTED_TO_PEER) >> 4) {
			startBut.label = "Next";
			
			setupAutoNext();
		} else if(((manager.status & Status.STARTED) >> 3) && (manager.status & Status.CALLING)) {
			startBut.label = "Searching";
		}  else if(!((manager.status & Status.STARTED) >> 3) && (manager.status & Status.READY)) {
			if((manager.status & Status.CONNECTED) >> 2) {
				startBut.label = "Again";
			} else {
				startBut.label = "Start";
			}
		}
		
		trace("onManagerStatusChanged: ", manager.status, event.oldValue, startBut.label);
	}
}

private function setupAutoNext() : void {
	if(autoNext && _autoNextTime > 0) {
		if(!_autoNextTimer) {
			_autoNextTimer = new Timer(_autoNextTime * 1000, 1);
			_autoNextTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onAutoNext);
		}
		_autoNextTimer.reset();
		_autoNextTimer.start();
	}
}

private function onAutoNext(event : TimerEvent) : void {
	if((manager.status & Status.CONNECTED_TO_PEER) >> 4) {
		getNext();
	}
}

crc function startNext() : void {
	if((manager.status & Status.CONNECTED_TO_PEER) >> 4) {
		getNext();
	}  else if(!((manager.status & Status.STARTED) >> 3) && (manager.status & Status.READY)) {
		if((manager.status & Status.CONNECTED) >> 2) {
			manager.start();
		} else {
			manager.connect();
		}
	}
}

private function getNext() : void {
	if(controlStream) {
		controlStream.removeEventListener(NetStatusEvent.NET_STATUS, controlHandler);
		controlStream.close();
		controlStream = null;
	}
	if(_recvStream) {
		_recvStream.removeEventListener(NetStatusEvent.NET_STATUS, recvStreamHandler);
		_recvStream.close();
		_recvStream = null;
	}
	if(_sendStream) {
		_sendStream.removeEventListener(NetStatusEvent.NET_STATUS, sendStreamHandler);
		_sendStream.close();
		_sendStream = null;
	}
	manager.disconnectFromPeer();
	stopConnectionTimeoutTimer();
	findLater();
	otherVideo.stopVideo();
}

crc function stop() : void {
	if(_recvStream) {
		_recvStream.removeEventListener(NetStatusEvent.NET_STATUS, recvStreamHandler);
		_recvStream.close();
		_recvStream = null;
	}
	if(_sendStream) {
		_sendStream.removeEventListener(NetStatusEvent.NET_STATUS, sendStreamHandler);
		_sendStream.close();
		_sendStream = null;
	}
	if(_autoNextTimer) {
		_autoNextTimer.stop();
	}
	stopConnectionTimeoutTimer();
	manager.stop();
	otherVideo.stopVideo();
}

private function controlHandler(event : NetStatusEvent):  void {
	trace('controlStream: ',event.info.code);
	switch(event.info.code) {
		case "NetStream.Play.Start":
			_initiatedConnection = false;
			stopConnectionTimeoutTimer();
			manager.connectToPeer(_currentPeerTried.idOnServer);
			break;
		case "NetStream.Play.Failed":
			_initiatedConnection = false;
			if(_sendStream) {
				_sendStream.removeEventListener(NetStatusEvent.NET_STATUS, sendStreamHandler);
				_sendStream.close();
				_sendStream = null;
			}
			stopConnectionTimeoutTimer();
			findLater();
	}
}

private function sendStreamHandler(event : NetStatusEvent) : void {
	trace("sendstream: ",event.info.code);
	switch(event.info.code) {
		case "NetStream.Play.Start":
			stopConnectionTimeoutTimer();
			_sendStream.send("onPeerIdReceived", manager.idOnServer);
			break;
	}
}

private function recvStreamHandler(event : NetStatusEvent) : void {
	trace("recvstream: "+event.info.code);
	switch(event.info.code) {
		case "NetStream.Play.Start":
			break;
		case "NetStream.Play.UnpublishNotify":
			otherVideo.stopVideo();
			getNext();
			break;
	}
}

private function listenerStreamHandler(event : NetStatusEvent) : void {
	trace("listenerhandler: "+event.info.code);
}

private function startConnectionTimeoutTimer() : void {
	if(!_connectionTimeoutTimer) {
		_connectionTimeoutTimer = new Timer(_connectionTimeout*1000);
		_connectionTimeoutTimer.addEventListener(TimerEvent.TIMER, onConnectionTimeout);
	}
	
	_connectionTimeoutTimer.start();
}

private function stopConnectionTimeoutTimer() : void {
	if(_connectionTimeoutTimer)
		_connectionTimeoutTimer.reset();
}

private function onConnectionTimeout(event : TimerEvent) : void {
	_initiatedConnection = false;
	otherVideo.stopVideo();
	getNext();
}

private var _initiatedConnection : Boolean = false;
private function connectTo(mOtherId : String):void
{	
	trace('trying to connect: ',_initiatedConnection,mOtherId);
	if(_initiatedConnection || ((manager.status & Status.CONNECTED_TO_PEER) >> 4))
		return;
	
	if(controlStream) {
		controlStream.removeEventListener(NetStatusEvent.NET_STATUS, controlHandler);
		try {
			controlStream.close();
			controlStream = null;
		} catch(e : Error) {
			
		}
	}
	
	_initiatedConnection = true;
	controlStream = new NetStream(_conn, mOtherId);
	controlStream.addEventListener(NetStatusEvent.NET_STATUS, controlHandler);
	
	// caller publishes media stream
	if(_sendStream) {
		_sendStream.removeEventListener(NetStatusEvent.NET_STATUS, sendStreamHandler);
		try {
			_sendStream.close();
		} catch(e : Error) {
			
		}
	}
	_sendStream = new NetStream(_conn, NetStream.DIRECT_CONNECTIONS);
	_sendStream.addEventListener(NetStatusEvent.NET_STATUS, sendStreamHandler);
	_sendStream.publish("media-requester");
	
	if(_recvStream) {
		_recvStream.removeEventListener(NetStatusEvent.NET_STATUS, recvStreamHandler);
		try {
			_recvStream.close();
		} catch(e : Error) {
			
		}
	}
	var o:Object = new Object
	o.onPeerConnect = function(caller:NetStream):Boolean // called on the requester side
	{
		if(_recvStream)
			return false;
		// caller subscribes to callee's media stream
		_recvStream = new NetStream(_conn, caller.farID);
		_recvStream.addEventListener(NetStatusEvent.NET_STATUS, recvStreamHandler);
		_recvStream.play("media-responder");
		
		// set volume for incoming stream
		setSpeakerVolume(speakerSlider.value);
		
		_recvStream.receiveAudio(true);
		_recvStream.receiveVideo(true);
		
		var i:Object = new Object;
		i.onMessage = onMessageReceived;
		
		_recvStream.client = i;
		
		otherVideo.netStream = _recvStream;
		
		clearChat();
		
		changeMic(Microphone.getMicrophone(microphones.selectedIndex));
		changeCamera(Camera.getCamera(cameras.selectedIndex.toString()));
		return true;
	}
	_sendStream.client = o;
	
	startConnectionTimeoutTimer();
	controlStream.play("CRC");
	
}

private function clearChat() : void {
	textOut.text = "";
	textInput.text = "";
}

private function onPeerIdReceived(peerIdOnServer : int) : void {
	manager.localConnectToPeer(peerIdOnServer);
}

private function onMessageReceived(message:String) : void {
	putMessage(message, "Partner");
}

public function putMessage(message : String, sender : String) : void {
//	var fmt : DateFormatter = new DateFormatter();
//	fmt.formatString = "HH:NN:SS";
//	textOut.text += fmt.format(new Date())+" "+sender+": "+message+"\n";
	textOut.text += sender+": "+message+"\n";
}

public function sendMessage(message : String) : void {
	if(_sendStream)
	_sendStream.send("onMessage", message);
}

private function createListener() : void {
	_listener = new NetStream(_conn, NetStream.DIRECT_CONNECTIONS);
	_listener.addEventListener(NetStatusEvent.NET_STATUS, listenerStreamHandler);
	_listener.publish("CRC");
	
	var c:Object = new Object();
	c.onPeerConnect = function(caller:Object):Boolean
	{
		if((manager.status & Status.CONNECTED_TO_PEER) >> 4)
			return false;
		
		if(controlStream) {
			controlStream.removeEventListener(NetStatusEvent.NET_STATUS, controlHandler);
			controlStream.close();
			controlStream = null;
		}
		
		_initiatedConnection = false;
		
		if(_recvStream) {
			_recvStream.removeEventListener(NetStatusEvent.NET_STATUS, recvStreamHandler);
			_recvStream.close();
			_recvStream = null;
		}
		
		stopFind();
		
		manager.stopAllTasks();
		
		_recvStream = new NetStream(_conn, caller.farID);
		_recvStream.addEventListener(NetStatusEvent.NET_STATUS, recvStreamHandler);
		
		
		
		setSpeakerVolume(speakerSlider.value);
		
		_recvStream.receiveAudio(true);
		_recvStream.receiveVideo(true);
		
		otherVideo.netStream = _recvStream;
		
		var i:Object = new Object;					
		i.onMessage = onMessageReceived;
		i.onPeerIdReceived = onPeerIdReceived;
		
		_recvStream.client = i;
		
		if(_sendStream) {
			_sendStream.removeEventListener(NetStatusEvent.NET_STATUS, sendStreamHandler);
			try {
				_sendStream.close();
			} catch(e : Error) {
				
			}
		}
		
		_sendStream = new NetStream(_conn, NetStream.DIRECT_CONNECTIONS);
		changeMic(Microphone.getMicrophone(microphones.selectedIndex));
		changeCamera(Camera.getCamera(cameras.selectedIndex.toString()));
		
		_sendStream.addEventListener(NetStatusEvent.NET_STATUS, sendStreamHandler);
		_sendStream.publish("media-responder");
		
		_recvStream.play("media-requester");
		
		clearChat();
		return true;
	};
	
	_listener.client = c;
}

crc function setSpeakerVolume(volume : int) : void {
	if(_recvStream) {
		_recvStream.soundTransform = new SoundTransform(volume/100);
	}
}

crc function setMicrophoneGain(gain : int) : void {
	if(_sendStream) {
		Microphone.getMicrophone(microphones.selectedIndex).gain = gain;
	}
}

crc function changeMic(mic : Microphone) : void {
	if(_sendStream) {
		_sendStream.attachAudio(mic);
		mic.gain = micSlider.value;
	}
}

crc function changeCamera(camera : Camera) : void {
	if(_sendStream) {
		_sendStream.attachCamera(camera);
		camera.setMode(320, 240, 30);
		camera.setQuality(0, 95);
	}
}