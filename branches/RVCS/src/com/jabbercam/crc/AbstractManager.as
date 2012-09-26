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