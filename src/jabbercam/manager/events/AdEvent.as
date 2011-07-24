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
package jabbercam.manager.events
{
	import flash.events.Event;
	
	public class AdEvent extends Event
	{
		public static const DISPLAY_AD : String = "displayAd";
		
		public var adString : String;
		public function AdEvent(type:String, adString : String = "", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.adString = adString;
		}
	}
}