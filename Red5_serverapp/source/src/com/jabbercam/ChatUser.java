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
package com.jabbercam;

public class ChatUser {
	
	private static final Object[] genuid = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
	
	public static String buildId() {
		int i = 0;
		String uid = "";
		while(i++ < 64) {
			uid += genuid[(int)Math.round(Math.random()*15)];
		}
		
		return uid;
	}
}
