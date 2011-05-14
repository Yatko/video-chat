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
package jabbercam.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Excluder
	{
		private static var _singleton : Boolean = false;
		
		private static var _excluded : Array;
		
		private static var _excludedFor : Object;
		
		public static function init(excluded : Array) : void {
			_excluded = excluded;
		}
		
		public static function exclude(obj : Object) : void {
			if(!_excluded || !obj)
			return;
			
			if(_excluded.indexOf(obj) == -1)
			_excluded.push(obj);
		}
		
		public static function excludeFor(obj : Object, time : uint = 72) : void {
			if(!_excluded || !obj || !time)
			return;
			
			if(!_excludedFor)
			_excludedFor = new Object();
			
			if(_excluded.indexOf(obj) == -1)
			_excluded.push(obj);
			
			if(_excludedFor[obj]) {
				_excludedFor[obj].timer.stop();
				_excludedFor[obj].timer.removeEventListener(TimerEvent.TIMER_COMPLETE, _excludedFor[obj].func);
				_excludedFor[obj] = null;
			}
			
			var timer : Timer = new Timer(time * 1000, 1);
			var func : Function = function(event : TimerEvent) : void {
				event.target.removeEventListener(TimerEvent.TIMER_COMPLETE, arguments.callee);
				
				_excluded.splice(_excluded.indexOf(obj), 1);
				_excludedFor[obj] = null;
			};
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, func);
			_excludedFor[obj] = {timer:timer, func:func};
			
			timer.start();
		}
		
		public static function reinclude(obj : Object) : void {
			if(!_excluded || !obj)
			return;
			
			_excluded.splice(_excluded.indexOf(obj), 1);
			
			if(_excludedFor && _excludedFor[obj]) {
				_excludedFor[obj].timer.stop();
				_excludedFor[obj].timer.removeEventListener(TimerEvent.TIMER_COMPLETE, _excludedFor[obj].func);
				_excludedFor[obj] = null;
			}
		}
		
		public static function reincludeAll() : void {
			if(!_excluded)
			return;
			
			_excluded.splice(0, _excluded.length);
			
			if(_excludedFor) {
				for (var o : Object in _excludedFor) {
					_excludedFor[o].timer.stop();
					_excludedFor[o].timer.removeEventListener(TimerEvent.TIMER_COMPLETE, _excludedFor[o].func);
					_excludedFor[o] = null;
				}
				
				_excludedFor = null;
			}
		}
	}
}