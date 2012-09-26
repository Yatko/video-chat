package com.jabbercam.crc
{
	import flash.events.EventDispatcher;

	[Event(name="connectSuccess", 				type="com.jabbercam.crc.events.ManagerEvent")]
	[Event(name="connectFailed", 				type="com.jabbercam.crc.events.ManagerEvent")]
	[Event(name="stopSuccess", 					type="com.jabbercam.crc.events.ManagerEvent")]
	[Event(name="stopFailed", 					type="com.jabbercam.crc.events.ManagerEvent")]
	[Event(name="startSuccess", 				type="com.jabbercam.crc.events.ManagerEvent")]
	[Event(name="startFailed", 					type="com.jabbercam.crc.events.ManagerEvent")]
	[Event(name="findPeersResponse", 			type="com.jabbercam.crc.events.ManagerEvent")]
	[Event(name="connectToPeerResponse", 		type="com.jabbercam.crc.events.ManagerEvent")]
	[Event(name="disconnectFromPeerResponse", 	type="com.jabbercam.crc.events.ManagerEvent")]
	public class AbstractManager extends EventDispatcher
	{
		protected var _id : String = "";
		protected var _idOnServer : int = -1;
		protected var _timeToLive : int;
		protected var _peer_idOnServer : int = -1;
		protected var _status : int = Status.INVALID;
		
		public function AbstractManager(id : String = "", timeToLive : int = 45)
		{
			super();
			this.id = id;
			this.timeToLive = timeToLive;
		}
		
		[Bindable]
		public function set id(value : String) : void {
			_id = value;
		}
		
		public function get id() : String {
			return _id;
		}
		
		[Bindable]
		public function set timeToLive(value : int) : void {
			_timeToLive = value;
		}
		
		public function get timeToLive() : int {
			return _timeToLive;
		}
		
		public function get status() : int {
			return _status;
		}
		public function setStatus(status : int) : void {
			
		}
		
		public function connect() : void {
			
		}
		
		public function start() : void {
			
		}
		
		public function stop() : void {
			
		}
		
		public function findPeers() : void {
			
		}
		
		public function connectToPeer(peer_idOnServer : int) : void {
			
		}
		
		public function localConnectToPeer(peer_idOnServer : int) : void {
			
		}
		
		public function disconnectFromPeer() : void {
			
		}
		
		public function localDisconnectFromPeer() : void {
			
		}
		
		public function get isActive() : Boolean {
			return false;
		}
		
		public function stopAllTasks() : void {
			
		}
	}
}