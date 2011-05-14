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

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.DataSource;

//import org.apache.log4j.Logger;

public class JabberCamAppData {
	private static JabberCamAppData instance;
	
	private Connection conn;
	
//	private Logger log;
	
	public static DataSource ds;
	
	public static JabberCamAppData getInstance() {
		if(instance == null)
			instance = new JabberCamAppData();
		return instance;
	}
	
	private JabberCamAppData() {
//		log = Logger.getLogger(JabberCamAppData.class);
		
		if(this.conn == null)
		reconnect();
	}
	
	private void reconnect() {
		try {
			this.conn = ds.getConnection();
		} catch(SQLException ex) {
			this.conn = null;
//			log.error("Error at ChatrouletteAppData::reconnect", ex);
		}
	}
	
	public ResultSet executeQuery(String stmt) {
		Statement st = null;
		ResultSet res = null;
		
		try {
			st = this.conn.createStatement();
		} catch(SQLException ex) {
			reconnect();
			if(this.conn == null)
				return null;
			try {
				st = this.conn.createStatement();
			} catch(SQLException e) {
				return null;
			}
		}
		
		try {
			res = st.executeQuery(stmt);
		} catch(SQLException ex1) {
//			log.error("Error at ChatrouletteAppData::executeQuery", ex1);
			if(st != null)
				try {
					st.close();
				} catch(SQLException ex) {
//					log.error("Error at ChatrouletteAppData::executeQuery", ex);
				}
			return null;
		}
		
		return res;
	}
	
	public int executeUpdate(String stmt) {
		Statement st = null;
		int res = 0;
		
		try {
			st = this.conn.createStatement();
		} catch(SQLException ex) {
			reconnect();
			if(this.conn == null)
				return 0;
			try {
				st = this.conn.createStatement();
			} catch(SQLException e) {
				return 0;
			}
		}
		
		try {
			st.execute(stmt);
			res = st.getUpdateCount();
			st.close();
		} catch(SQLException ex1) {
//			log.error("Error at ChatrouletteAppData::executeUpdate", ex1);
			if(st != null)
				try {
					st.close();
				} catch(SQLException ex) {
//					log.error("Error at ChatrouletteAppData::executeUpdate", ex);
				}
			res = 0;
		}
		
		return res;
	}
}
