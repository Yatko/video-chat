package com.jabbercam.crc
{
	import com.jabbercam.crc.events.ManagerEvent;
	
	import flash.errors.EOFError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;

	public class HttpManager extends AbstractManager
	{
		public static const METHOD_UPDATE : String = "update";
		public static const METHOD_START : String = "start";
		public static const METHOD_STOP : String = "disconnect";
		public static const METHOD_CONNECT_TO_PEER : String = "connect";
		public static const METHOD_DISCONNECT_FROM_PEER : String = "disconnectpeer";
		
		public static var BASE_URL : String = "";
		public static const SERVICE_CONNECT : String = "connect.php";
		public static const SERVICE_FUNCTIONS : String = "functions.php";
		public static const SERVICE_FIND_PEERS : String = "findpeers.php";
		private var _loader : URLLoader = null;
		private var _serviceUrl : String = "";
		private var _updateTimer : Timer;
		private var _updateLoader : URLLoader = null;
		
		private var _callQueue : Array;
		public function HttpManager(id:String="", serviceUrl : String = "", timeToLive:int=45)
		{
			super(id, timeToLive);
			this.serviceUrl = serviceUrl;
			
			setStatus(Status.READY);
		}
		
		override public function get isActive() : Boolean {
			return _loader != null;
		}
		
		[Bindable]
		public function set serviceUrl(value : String) : void {
			_serviceUrl = value;
			BASE_URL = _serviceUrl.match(/^(.*?\/?)connect\.php/)[1];
		}
		public function get serviceUrl() : String {
			return _serviceUrl;
		}
		
		override public function setStatus(status : int) : void {
			var oldVal : int = _status;
			
			_status = status;
			
			if(oldVal != _status)
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false,
				PropertyChangeEventKind.UPDATE, "status", oldVal, status, this));
		}
		
		private function createLoader(service : String = "connect.php") : URLRequest {
			var oldValue : Boolean = _loader != null;
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			if(!oldValue)
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false,
				PropertyChangeEventKind.UPDATE, "isActive", false, true, this));
			
			var req : URLRequest = new URLRequest(BASE_URL+service);
			req.method = URLRequestMethod.GET;
			req.data = new URLVariables();
			
			setStatus(_status | Status.CALLING);
			
			return req;
		}
		
		private function destroyLoader() : void {
			var oldValue : Boolean = _loader != null;
			try {
				_loader.close();
			} catch(e : Error) {
				
			}
			_loader = null;
			
			if(oldValue)
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false,
				PropertyChangeEventKind.UPDATE, "isActive", true, false, this));
		}
		
		override public function connect() : void {
			if(!_serviceUrl || !_id)
				return;
			
			var req : URLRequest = createLoader(SERVICE_CONNECT);
			_loader.addEventListener(Event.COMPLETE, connectResponse);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, connectError);
			
			try {
				req.data.id = _id;
				_loader.load(req);
			} catch(e : Error) {
				connectError(e);
			}
		}
		
		private function connectResponse(event : Event) : void {
			var response : ByteArray = event.target.data as ByteArray;
			
			var evt : ManagerEvent;
			try {
				_idOnServer = response.readInt();
				
				setStatus(Status.CONNECTED);
				evt = new ManagerEvent(ManagerEvent.CONNECT_SUCCESS, response);
			} catch(e : EOFError) {
				trace(e.getStackTrace());
				setStatus(Status.READY);
				evt = new ManagerEvent(ManagerEvent.CONNECT_FAILED, response);
			} finally {
				destroyLoader();
				response.position = 0;
				dispatchEvent(evt);
			}
		}
		
		private function connectError(error : Object) : void {
			trace(error);
			setStatus(Status.READY);
		}
		
		override public function start():void {
			if(_loader || _idOnServer < 0)
				return;
			
			var req : URLRequest = createLoader(SERVICE_FUNCTIONS);
			_loader.addEventListener(Event.COMPLETE, startResponse);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, startError);
			
			try {
				req.data.method = METHOD_START;
				req.data.index = _idOnServer;
				
				_loader.load(req);
			} catch(e : Error) {
				startError(e);
			}
		}
		
		private function startResponse(event : Event) : void {
			var response : ByteArray = event.target.data as ByteArray;
			
			var evt : ManagerEvent;
			
			try {
				var success : Boolean = response.readBoolean();
				if(success) {
					evt = new ManagerEvent(ManagerEvent.START_SUCCESS, response);
					setStatus(Status.STARTED);
				} else {
					evt = new ManagerEvent(ManagerEvent.START_FAILED, response);
					setStatus(Status.READY);
				}
			} catch(e : EOFError) {
				trace(e.getStackTrace());
				evt = new ManagerEvent(ManagerEvent.START_FAILED, response);
				setStatus(Status.READY);
			} finally {
				destroyLoader();
				response.position = 0;
				
				if(evt.type == ManagerEvent.START_SUCCESS) {
					startUpdateSequence();
				}
				dispatchEvent(evt);
			}
		}
		
		private function startError(error : Object) : void {
			trace(error);
			setStatus(Status.READY);
		}
		
		private function startUpdateSequence() : void {
			if(!_updateTimer) {
				_updateTimer = new Timer(int(_timeToLive/2)*1000);
				_updateTimer.addEventListener(TimerEvent.TIMER, sendUpdate);
			}
			
			_updateTimer.start();
		}
		
		private function stopUpdateSequence() : void {
			try {
				_updateLoader.close();
			} catch(e : Error) {
				
			} finally {
				if(_updateTimer)
					_updateTimer.stop();
				_updateLoader = null;
			}
		}
		
		private function sendUpdate(event : TimerEvent) : void {
			if(_updateLoader || _loader)
				return;
			
			_updateLoader = new URLLoader();
			_updateLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_updateLoader.addEventListener(Event.COMPLETE, updateResponse);
			_updateLoader.addEventListener(IOErrorEvent.IO_ERROR, updateError);
			
			try {
				var req : URLRequest = new URLRequest(BASE_URL+SERVICE_FUNCTIONS);
				req.method = URLRequestMethod.GET;
				req.data = new URLVariables();
				req.data.method = METHOD_UPDATE;
				req.data.index = _idOnServer;
				
				_updateLoader.load(req);
				_updateTimer.stop();
			} catch(e : Error) {
				updateError(e);
			}
		}
		
		private function updateResponse(event : Event) : void {
			var response : ByteArray = event.target.data as ByteArray;
			
			try {
				var success : Boolean = response.readBoolean();
				
				if(success) {
					trace("success updating");
				} else {
					trace("insuccess updating");
				}
			} catch(e : EOFError) {
				trace(e.getStackTrace());
			} finally {
				response.clear();
				_updateLoader = null;
				if(!_loader)
					_updateTimer.start();
			}
		}
		
		private function updateError(error : Object) : void {
			trace(error);
			_updateLoader = null;
			if(!_loader)
				_updateTimer.start();
		}
		
		override public function stop():void {
			stopUpdateSequence();
			_callQueue = null;
			if(_loader) {
				try {
					_loader.close();
				} catch(e : Error) {
					
				} finally {
					_loader = null;
				}
			}
			
			var req : URLRequest = createLoader(SERVICE_FUNCTIONS);
			setStatus(Status.CONNECTED | Status.CALLING);
			_loader.addEventListener(Event.COMPLETE, stopResponse);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, stopError);
			
			try {
				req.data.method = METHOD_STOP;
				req.data.index = _idOnServer;
				if(_peer_idOnServer > -1) {
					req.data.peerindex = _peer_idOnServer;
				}
				
				_loader.load(req);
			} catch(e : Error) {
				stopError(e);
			}
		}
		
		private function stopResponse(event : Event) : void {
			var response : ByteArray = event.target.data as ByteArray;
			
			var evt : ManagerEvent;
			try {
				var success : Boolean = response.readBoolean();
				
				if(success) {
					evt = new ManagerEvent(ManagerEvent.STOP_SUCCESS, response);
					setStatus(Status.CONNECTED);
				} else {
					evt = new ManagerEvent(ManagerEvent.STOP_FAILED, response);
					setStatus(Status.READY);
				}
			} catch(e : EOFError) {
				evt = new ManagerEvent(ManagerEvent.STOP_FAILED, response);
				setStatus(Status.READY);
			} finally {
				destroyLoader();
				_peer_idOnServer = -1;
				response.position = 0;
				
				dispatchEvent(evt);
			}
		}
		
		private function stopError(error : Object) : void {
			trace(error);
			setStatus(Status.STARTED);
			processQueue();
		}
		
		override public function findPeers():void {
			if(_idOnServer < 0 || _loader)
				return;
			
			if(((_status & Status.STARTED) >> 3) && !(_status & Status.CALLING)) {
				var req : URLRequest = createLoader(SERVICE_FIND_PEERS);
				_loader.addEventListener(Event.COMPLETE, findPeersResponse);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, findPeersError);
				
				try {
					req.data.index = _idOnServer;
					
					_loader.load(req);
					
					stopUpdateSequence();
				} catch(e : Error) {
					findPeersError(e);
				}
			} else {
				if(!_callQueue) {
					_callQueue = [];
				}
				
				if(!_callQueue.some(function(obj:*, index:int,arr:Array):Boolean{
					if(obj.func == findPeers)
						return true;
					return false;
				}))
					_callQueue.push({func:findPeers});
			}
		}
		
		private function findPeersResponse(event : Event) : void {
			var response : ByteArray = event.target.data as ByteArray;
			
			var peers : Array = new Array();
			while(response.bytesAvailable >= 64) {
				try {
					peers.push(response.readUTFBytes(64));
				} catch(e : EOFError) {
					
				}
			}
			
			var evt : ManagerEvent = new ManagerEvent(ManagerEvent.FIND_PEERS_RESPONSE, 
				{peers:peers, raw : response});
			response.position = 0;
			
			destroyLoader();
			setStatus(Status.STARTED);
			
			dispatchEvent(evt);
			
			processQueue();
		}
		
		private function findPeersError(error : Object) : void {
			trace(error);
			setStatus(Status.STARTED);
			
			processQueue();
		}
		
		private function processQueue() : void {
			if(_callQueue && _callQueue.length > 0) {
				var funcObj : Object = _callQueue.shift() as Object;
				funcObj.func.apply(this, funcObj.params);
			} else {
				_callQueue = null;
				
				if(!(_status & Status.CALLING) && (_status & Status.STARTED) >> 3)
					startUpdateSequence();
			}
		}
		
		override public function connectToPeer(peer_idOnServer:int):void {
			if((_status & Status.STARTED) >> 3) {
				if(!((_status & Status.CONNECTED_TO_PEER) >> 4)) {
					if(!(_status & Status.CALLING)) {
						var req : URLRequest = createLoader(SERVICE_FUNCTIONS);
						_loader.addEventListener(Event.COMPLETE, connectToPeerResponse);
						_loader.addEventListener(IOErrorEvent.IO_ERROR, connectToPeerError);
						try {
							req.data.method = METHOD_CONNECT_TO_PEER;
							req.data.index = _idOnServer;
							_peer_idOnServer = req.data.peerindex = peer_idOnServer;
							
							_loader.load(req);
							stopUpdateSequence();
						} catch(e : Error) {
							connectToPeerError(e);
						}
					} else {
						if(!_callQueue)
							_callQueue = [];
						if(!_callQueue.some(function(obj:*, index:int,arr:Array):Boolean{
							if(obj.func == connectToPeer)
								return true;
							return false;
						}))
							_callQueue.push({func:connectToPeer, params:[peer_idOnServer]});
					}
				}
			}
		}
		
		private function connectToPeerResponse(event : Event) : void {
			var response : ByteArray = event.target.data as ByteArray;
			
			var evt : ManagerEvent = new ManagerEvent(ManagerEvent.CONNECT_TO_PEER_RESPONSE, response);
			try {
				var success : Boolean = response.readBoolean();
				if(success) {
					setStatus(Status.CONNECTED_TO_PEER);
				} else {
					_peer_idOnServer = -1;
					setStatus(Status.STARTED);
				}
			} catch(e : Error) {
				_peer_idOnServer = -1;
				setStatus(Status.STARTED);
			} finally {
				destroyLoader();
				response.position = 0;
				
				dispatchEvent(evt);
				processQueue();
			}
		}
		
		private function connectToPeerError(error : Object) : void {
			trace(error);
			_peer_idOnServer = -1;
			setStatus(Status.STARTED);
			processQueue();
		}
		
		override public function disconnectFromPeer():void {
			if(_status & Status.CONNECTED_TO_PEER) {
				destroyLoader();
				stopUpdateSequence();
				_status = Status.STARTED;
				
				var req : URLRequest = createLoader(SERVICE_FUNCTIONS);
				_loader.addEventListener(Event.COMPLETE, disconnectFromPeerResponse);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, disconnectFromPeerError);
				
				try {
					req.data.method = METHOD_DISCONNECT_FROM_PEER;
					req.data.index = _idOnServer;
					req.data.peerindex = _peer_idOnServer;
					
					stopUpdateSequence();
					_loader.load(req);
				} catch(e : Error) {
					disconnectFromPeerError(e);
				}
			}
		}
		
		private function disconnectFromPeerResponse(event : Event) : void {
			var response : ByteArray = event.target.data as ByteArray;
			
			var evt : ManagerEvent = new ManagerEvent(ManagerEvent.DISCONNECT_FROM_PEER_RESPONSE, response);
			try {
				var success : Boolean = response.readBoolean();
				
				if(success) {
					setStatus(Status.STARTED);
				} else {
					setStatus(Status.READY);
				}
			} catch(e : EOFError) {
				setStatus(Status.READY);
			} finally {
				destroyLoader();
				response.position = 0;
				
				_peer_idOnServer = -1;
				dispatchEvent(evt);
				processQueue();
			}
		}
		
		private function disconnectFromPeerError(error : Error) : void {
			setStatus(Status.CONNECTED_TO_PEER);
			processQueue();
		}
		
		override public function localConnectToPeer(peer_idOnServer:int):void {
			_peer_idOnServer = peer_idOnServer;
			setStatus(Status.CONNECTED_TO_PEER);
		}
		
		override public function localDisconnectFromPeer():void {
			_peer_idOnServer = -1;
			setStatus(Status.STARTED);
		}
		
		override public function stopAllTasks() : void {
			destroyLoader();
			if(!((_status & Status.STARTED) >> 3))
				stopUpdateSequence();
		}
	}
}