import com.jabbercam.crc.AbstractManager;
import com.jabbercam.crc.HttpManager;
import com.jabbercam.crc.events.ManagerEvent;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

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

[Bindable]
crc var manager : AbstractManager;

private var _conn : NetConnection;

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

crc function loadCompleted(event : Event) : void {
	var data : ByteArray = event.target.data as ByteArray;
	_serviceURL = data.readUTF();
	_devKey = data.readUTF();
	cameraRequired = data.readBoolean();
	speakerVolume = data.readShort();
	microphoneVolume = data.readShort();
	minimumConnectedTime = data.readShort();
	_timeToLive = data.readShort();
	
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
	manager.connect();
}

crc function onConnectSuccess(event : ManagerEvent) : void {
	manager.start();
}

crc function onConnectFail(event : ManagerEvent) : void {
	
}

crc function onStartSuccess(event : ManagerEvent) : void {
	manager.findPeers();
}

crc function onStartFailed(event : ManagerEvent) : void {
	
}

crc function onFindPeersResponse(event : ManagerEvent) : void {
	
}