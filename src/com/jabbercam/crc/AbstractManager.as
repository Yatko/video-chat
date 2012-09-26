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
	[Event(name="numUsersReponse",				type="com.jabbercam.crc.events.ManagerEvent")]
	[Bindable]
	public class AbstractManager extends EventDispatcher
	{
		protected var _id : String = "";
		protected var _idOnServer : int = -1;
		protected var _timeToLive : int;
		protected var _peer_idOnServer : int = -1;
		protected var _status : int = Status.INVALID;
		
		protected var _lastFoundPeers : Array;
		
		public function AbstractManager(id : String = "", timeToLive : int = 45)
		{
			super();
			this.id = id;
			this.timeToLive = timeToLive;
			_lastFoundPeers = [];
		}
		
		public function set id(value : String) : void {
			_id = value;
		}
		
		public function get id() : String {
			return _id;
		}
		
		public function get idOnServer() : int {
			return _idOnServer;
		}
		
		public function get peerIdOnServer() : int {
			return _peer_idOnServer;
		}
		
		public function set timeToLive(value : int) : void {
			_timeToLive = value;
		}
		
		public function get timeToLive() : int {
			return _timeToLive;
		}
		
		public function get status() : int {
			return _status;
		}
		
		public function set status(value : int) : void {
			_status = value;
		}
		
		public function setStatus(status : int) : void {
			this.status = status;
		}
		
		public function connect() : void {
			
		}
		
		public function start() : void {
			
		}
		
		public function stop() : void {
			
		}
		
		public function findPeers() : void {
			
		}
		
		public function get lastFoundPeers() : Array {
			return _lastFoundPeers;
		}
		
		public function connectToPeer(peer_idOnServer : int) : void {
			
		}
		
		public function localConnectToPeer(peer_idOnServer : int) : void {
			
		}
		
		public function disconnectFromPeer() : void {
			
		}
		
		public function localDisconnectFromPeer() : void {
			
		}
		
		public function getNumUsers() : void {
			
		}
		
		public function get isActive() : Boolean {
			return false;
		}
		
		public function stopAllTasks() : void {
			
		}
	}
}