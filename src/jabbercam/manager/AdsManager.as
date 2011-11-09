/**
 * VIDEOSOFTWARE.PRO
 * Copyright 2011 VideoSoftware.PRO
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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import jabbercam.manager.events.AdEvent;
	
	[Event(name="displayAd", type="jabbercam.manager.events.AdEvent")]
	public class AdsManager extends EventDispatcher
	{
		private var _frequency : int;
		private var _adsTimer : Timer;
		
		private var lines : Array;
		public function AdsManager(adsFrequency : int = 0)
		{
			super();
			
			_frequency = adsFrequency;
			
			if(_frequency > 0) {
				var l : URLLoader = new URLLoader();
				var r : URLRequest = new URLRequest('jabbercam/media/text/adtext.txt');
				l.addEventListener(IOErrorEvent.IO_ERROR, error);
				l.addEventListener(Event.COMPLETE, complete);
				l.load(r);
			}
		}
		
		private function error(e : IOErrorEvent) : void {
			
		}
		
		private function complete(e : Event) : void {
			var text : String = e.target.data as String;
			text = text.replace(/\r+/g, '\n').replace(/\n+/g, '\n');
			
			lines = text.split('\n');
			
			if(lines && lines.length > 0) {
				_adsTimer = new Timer(_frequency*1000);
				_adsTimer.addEventListener(TimerEvent.TIMER, newAd);
				_adsTimer.start();
			}
		}
		
		private function newAd(e : TimerEvent) : void {
			var ln : int = Math.round(Math.random()*(lines.length-1));
			
			dispatchEvent(new AdEvent(AdEvent.DISPLAY_AD, lines[ln]));
		}
	}
}