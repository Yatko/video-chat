package com.jabbercam.crc.events
{
	import flash.events.Event;
	
	public class ManagerEvent extends Event
	{
		public static const CONNECT_SUCCESS : String = "connectSuccess";
		public static const CONNECT_FAILED : String = "connectFailed";
		public static const START_SUCCESS : String = "startSuccess";
		public static const START_FAILED : String = "startFailed";
		public static const STOP_SUCCESS : String = "stopSuccess";
		public static const STOP_FAILED : String = "stopFailed";
		public static const FIND_PEERS_RESPONSE : String = "findPeersResponse";
		public static const CONNECT_TO_PEER_RESPONSE : String = "connectToPeerResponse";
		public static const DISCONNECT_FROM_PEER_RESPONSE : String = "disconnectFromPeer";
		
		public var response : Object;
		
		public function ManagerEvent(type:String, response : Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.response = response;
		}
		
		override public function clone():Event {
			return new ManagerEvent(type, response, bubbles, cancelable);
		}
	}
}