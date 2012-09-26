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
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.utils.flash_proxy;

	public class CookieManager extends EventDispatcher
	{
		private static var _instance : CookieManager;
		private static var _singleton : Boolean = false;
		
		[Bindable]
		public var myVideo : Rectangle;
		
		[Bindable]
		public var partnerVideo : Rectangle;
		
		private var sh : SharedObject;
		
		public function CookieManager()
		{
			super();
			
			sh = SharedObject.getLocal("video_settings");
			var needsFlush : Boolean = false;
			if(sh.data.hasOwnProperty('own')) {
				myVideo = new Rectangle(sh.data.own.x, sh.data.own.y, sh.data.own.width, sh.data.own.height);
			} else {
				myVideo = new Rectangle(400, 60, 240, 180);
				sh.data.own = myVideo;
				needsFlush = true;
			}
			
			if(sh.data.hasOwnProperty('partner')) {
				partnerVideo = new Rectangle(sh.data.partner.x, sh.data.partner.y, sh.data.partner.width, sh.data.partner.height);
			} else {
				partnerVideo = new Rectangle(40, 20, 320, 240);
				sh.data.partner = partnerVideo;
				needsFlush = true;
			}
			
			if(needsFlush)
				sh.flush();
		}
		
		public static function get instance() : CookieManager {
			if(!_instance) {
				_singleton = true;
				_instance = new CookieManager();
			}
			
			return _instance;
		}
		
		public function saveMyVideoSettings(myVideo : Rectangle) : void {
			sh.data.own = this.myVideo = myVideo;
		}
		
		public function savePartnerVideoSettings(partnerVideo : Rectangle) : void {
			sh.data.partner = this.partnerVideo = partnerVideo;
		}
		
		public function flush() : void {
			sh.flush();
		}
	}
}