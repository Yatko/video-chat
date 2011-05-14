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

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Set;

import javax.sql.DataSource;

import org.red5.server.adapter.ApplicationAdapter;
import org.red5.server.api.IConnection;
import org.red5.server.api.IScope;
import org.red5.server.api.service.IPendingServiceCall;
import org.red5.server.api.service.IPendingServiceCallback;
import org.red5.server.api.service.IServiceCapableConnection;
import org.red5.server.api.stream.IStreamAwareScopeHandler;

public final class JabberCamApp extends ApplicationAdapter implements IPendingServiceCallback,
	IStreamAwareScopeHandler{
	
	public static final String ATT_USER_ID = "userId";
	
	public static int BAN_TIME = 45;
	public static int FILTER_TIME = 15;
	public static int NUM_REPORTS_TO_BAN = 9;
	
	private IScope appScope;
	
	public void setFilterTime(String filterTime) {
		FILTER_TIME = Integer.parseInt(filterTime);
	}
	
	public void setBanTime(String banTime) {
		BAN_TIME = Integer.parseInt(banTime);
	}
	
	public void setNumReportsToBan(String reportCountToBan) {
		NUM_REPORTS_TO_BAN = Integer.parseInt(reportCountToBan);
	}
	
	public void setDataSource(DataSource ds) {
		JabberCamAppData.ds = ds;
	}
	
	@Override
	public boolean appStart(IScope app) {
		
		this.appScope = app;
		
		return super.appStart(app);
	}

	@Override
	public boolean appConnect(IConnection con, Object[] params) {
		super.appConnect(con, params);
		
		if(params == null || params.length == 0 || !params[0].equals("JabberCamApp")) {
			con.close();
			
			return false;
		}
		
//		log.info("appConnect: "+con.getClient().getId());
		
		String stmt = "SELECT true blocked FROM block WHERE ip=\""+con.getRemoteAddress()+"\" LIMIT 1";
		Boolean blocked = false;
		ResultSet resB = JabberCamAppData.getInstance().executeQuery(stmt);
		
		if(resB != null) {
			try {
				resB.next();
				blocked = resB.getBoolean("blocked");
			} catch(SQLException ex2) {
				
			} finally {
				try {
					resB.close();
				} catch(SQLException ex2) {
					
				}
			}
		}
		
		if(blocked) {
			sendIpBlocked(con);
			return true;
		}
		
		stmt = "SELECT (IF(DATE_SUB(NOW(), INTERVAL "+BAN_TIME+" MINUTE) > ban_time, false, true)) " +
				"banned, ("+BAN_TIME+"-MINUTE(TIMEDIFF(NOW(), ban_time))) ban_time_left FROM bans WHERE ip=\""+
				con.getRemoteAddress()+"\" LIMIT 1";
		
		Boolean banned = false;
		int banTime = BAN_TIME;
		ResultSet res = JabberCamAppData.getInstance().executeQuery(stmt);
		if(res != null) {
			try {
				res.next();
				banned = res.getBoolean("banned");
				banTime = res.getInt("ban_time_left");
				
			} catch (SQLException e) {
				// TODO Auto-generated catch block
//				log.error("Error at appConnect", e);
			} finally {
				try {
					res.close();
				} catch(SQLException ex) {
					
				}
			}
		}
		
		String id = ChatUser.buildId();
		con.getClient().setAttribute(ATT_USER_ID, id);
		
		IServiceCapableConnection service = (IServiceCapableConnection)con;
		
		if(banned) {
			sendUserBanned(con, banTime);
		}
		else
		service.invoke("setId", new Object[]{id}, this);
		
		return true;
	}
	
	@Override
	public void appDisconnect(IConnection con) {
		super.appDisconnect(con);
		String userId = con.getClient().getAttribute(ATT_USER_ID).toString();
		
		if(userId == null || userId.equals(""))
			return;
		
		disconnectUser(userId);
	}
	
	private void disconnectUser(String userId) {
		String q = "DELETE sessions, filters, chats, user_settings, user_prefs FROM " +
		"sessions LEFT JOIN filters ON sessions.id=filters.id LEFT JOIN chats ON sessions.id=chats.peer1 || " +
		"sessions.id=chats.peer2 LEFT JOIN user_settings ON sessions.id=user_settings.id " +
		"LEFT JOIN user_prefs ON sessions.id=user_prefs.id "+
		"WHERE sessions.id=\""+userId+"\"";
	
		JabberCamAppData.getInstance().executeUpdate(q);
	}

	public void resultReceived(IPendingServiceCall arg0) {
		
		if(arg0.getServiceMethodName().equals("onBanned") || arg0.getServiceMethodName().equals("onBlocked")) {
			String bannedUserId = arg0.getArguments()[0].toString();
			
			disconnectUser(bannedUserId);
			
			IConnection bannedUser = getUser(bannedUserId);
			
			if(bannedUser != null) {
				
				bannedUser.close();
			}
		}
	}
	
	private IConnection getUser(String id) {
		for (Set<IConnection> set : appScope.getConnections()) {
			   for (IConnection con : set) {
			      if(con.getClient().getAttribute(ATT_USER_ID).equals(id))
			    	  return con;
			   }
			}
		
		return null;
	}
	
	public String findUser(String id) {
		
		String q = "SELECT * FROM sessions s WHERE s.type=1 && s.id!=\""+id+"\" && " +
				"(SELECT ip FROM sessions WHERE id=\""+id+"\" LIMIT 1) NOT IN (SELECT ip FROM filters " +
					"WHERE id=s.id && DATE_SUB(NOW(), INTERVAL "+FILTER_TIME+" MINUTE)<filter_time) && " +
				"(SELECT ip FROM sessions WHERE s.id=id LIMIT 1) NOT IN (SELECT ip FROM filters WHERE id=\""+
					id+"\" && DATE_SUB(NOW(), INTERVAL "+FILTER_TIME+" MINUTE)<filter_time) && "+
				"(SELECT COUNT(*) FROM chats WHERE peer1=s.id || peer2=s.id)=0 && " +
				"(SELECT COUNT(*) FROM user_prefs up WHERE up.id=\""+id+"\" && (up.pref_value=\"0\" || up.pref_value=" +
					"(IF((SELECT sett_value FROM user_settings WHERE id=s.id && sett_name=up.pref_name LIMIT 1) IS NULL," +
					"up.pref_value, (SELECT sett_value FROM user_settings WHERE id=s.id && sett_name=up.pref_name LIMIT 1)))))="+
					"(SELECT COUNT(*) FROM user_prefs WHERE id=\""+id+"\") && "+
				"(SELECT COUNT(*) FROM user_prefs up WHERE up.id=s.id && (up.pref_value=\"0\" || up.pref_value=" +
					"(IF((SELECT sett_value FROM user_settings WHERE id=\""+id+"\" && sett_name=up.pref_name LIMIT 1) IS NULL," +
					"up.pref_value, (SELECT sett_value FROM user_settings WHERE id=\""+id+"\" && sett_name=up.pref_name LIMIT 1)))))="+
					"(SELECT COUNT(*) FROM user_prefs WHERE id=s.id) "+
				"ORDER BY RAND() LIMIT 1";
		
		ResultSet res = JabberCamAppData.getInstance().executeQuery(q);
		
		if(res != null) {
			try {
				res.next();
				
				String userId = res.getString("id");
				return userId;
			} catch(SQLException ex) {
//				log.error("Error at findUser", ex);
			} finally {
				try {
					res.close();
				} catch(SQLException ex2) {
					
				}
			}
		}
		
		return "";
	}
	
	public String findUserByName(String id, String username) {
		String q = "SELECT * FROM sessions s WHERE s.type=1 && s.id!=\""+id+"\" && s.marked=0 "+
			"s.id=(SELECT id FROM user_settings WHERE sett_name='uname' && sett_value='"+username+"' "+
			"LIMIT 1) LIMIT 1";
		
		ResultSet res = JabberCamAppData.getInstance().executeQuery(q);
		
		if(res != null) {
			try {
				res.next();
				
				String userId = res.getString("id");
				return userId;
			} catch(SQLException ex) {
//				log.error("Error at findUser", ex);
			} finally {
				try {
					res.close();
				} catch(SQLException ex2) {
					
				}
			}
		}
		
		return "";
	}
	
	public static Long ipToInt(String addr) {
        String[] addrArray = addr.split("\\.");

        long num = 0;
        for (int i=0;i<addrArray.length;i++) {
            int power = 3-i;

            num += ((Integer.parseInt(addrArray[i])%256 * Math.pow(256,power)));
        }
        return num;
    }
	
	public HashMap<String, Object> register(String id, Object[] settings, Object[] prefs) {
		IConnection user = getUser(id);
		
		HashMap<String, Object> resp = new HashMap<String, Object>();
		
		if(user == null) {
			resp.put("result", false);
			return resp;
		}
		
		String q = "INSERT INTO sessions (id, ip, created_at, marked, type) "+
			"VALUES(\""+id+"\", \""+user.getRemoteAddress()+"\", DEFAULT, 0, 1)";
		
		int res = JabberCamAppData.getInstance().executeUpdate(q);
		
		if(settings != null && settings.length>0) {
			q = "INSERT IGNORE INTO user_settings (id, sett_name, sett_value) VALUES ";
			int i = 0;
			while(i < settings.length) {
				q += "(\""+id+"\", \""+settings[i]+"\", \""+settings[i+1]+"\")";
				i+=2;
				if(i < settings.length)
					q+=",";
			}
			
			JabberCamAppData.getInstance().executeUpdate(q);
		}
		
		if(prefs != null && prefs.length>0) {
			q = "INSERT IGNORE INTO user_prefs (id, pref_name, pref_value) VALUES ";
			int i = 0;
			while(i < prefs.length) {
				q += "(\""+id+"\", \""+prefs[i]+"\", \""+prefs[i+1]+"\")";
				i+=2;
				if(i < prefs.length)
					q+=",";
			}
			
			JabberCamAppData.getInstance().executeUpdate(q);
		}
		
		Long ip = ipToInt(user.getRemoteAddress());
		q = "SELECT code, country FROM cc_country WHERE ipfrom<='"+ip.longValue()+"' && ipto>='"+ip.longValue()+
			"' LIMIT 1";
		
		ResultSet cc = JabberCamAppData.getInstance().executeQuery(q);
		if(cc != null) {
			try {
				cc.next();
				
				resp.put("ccode", cc.getString("code"));
				resp.put("country", cc.getString("country"));
			} catch(SQLException e) {
				
			} finally {
				try {
					cc.close();
				} catch(SQLException ex) {
					
				}
			}
		}
		
		resp.put("result", res > 0);
		
		return resp;
	}
	
	public boolean updateSetting(String id, Object[] setting) {
		if(setting == null || setting.length < 2)
			return false;
		
		String q = "INSERT INTO user_settings (id, sett_name, sett_value) VALUES(\""+id+"\", \""+setting[0]+"\"," +
				"\""+setting[1]+"\") ON DUPLICATE KEY UPDATE sett_value=\""+setting[1]+"\"";
		
		int res = JabberCamAppData.getInstance().executeUpdate(q);
		
		return res > 0;
	}
	
	public boolean updatePref(String id, Object[] pref) {
		if(pref == null || pref.length < 2)
			return false;
		
		String q = "INSERT INTO user_prefs (id, pref_name, pref_value) VALUES(\""+id+"\", \""+pref[0]+"\"," +
				"\""+pref[1]+"\") ON DUPLICATE KEY UPDATE pref_value=\""+pref[1]+"\"";
		
		int res = JabberCamAppData.getInstance().executeUpdate(q);
		
		return res > 0;
	}
	
	public int numUsers() {
		String q = "SELECT COUNT(*) numUsers FROM sessions WHERE type=1";
		
		ResultSet res = JabberCamAppData.getInstance().executeQuery(q);
		
		if(res != null) {
			try {
				res.next();
				
				return res.getInt("numUsers");
			} catch(SQLException ex) {
//				log.error("Error at numUsers", ex);
			} finally {
				try {
					res.close();
				} catch(SQLException ex2) {
					
				}
			}
		}
		
		return 0;
	}
	
	public boolean unregister(String id) {
		IConnection user = getUser(id);
		
		if(user != null)
		{
			disconnectUser(id);
			
			return true;
		}
		
		return false;
	}
	
	public boolean connectToUser(String id, String otherUserId) {
		IConnection otherUser = getUser(otherUserId);
		
		if(otherUser != null) {
			String q = "INSERT INTO chats (peer1, peer2) VALUES (\""+id+"\", \""+otherUserId+"\")";
			
			int res = JabberCamAppData.getInstance().executeUpdate(q);
			
			if(res > 0) {
				sendPeerConnect(otherUser, id);
				
				return true;
			}
		
		}
		
		return false;
	}
	
	public boolean checkUsernameAvailable(String username) {
		String q = "SELECT false available FROM user_settings u, sessions s WHERE u.sett_name='uname' && "+
		"u.sett_value='"+username+"' && s.id=u.id LIMIT 1";
		
		ResultSet res = JabberCamAppData.getInstance().executeQuery(q);
		
		boolean result = true;
		if(res != null) {
			try {
				res.next();
				
				result = res.getBoolean("available");
			} catch(SQLException e) {
				
			} finally {
				try {
					res.close();
				} catch(SQLException ex) {
					
				}
			}
		} else result = false;
		
		return result;
	}
	
	private void sendPeerConnect(IConnection user, String otherUserId) {
		IServiceCapableConnection service = (IServiceCapableConnection)user;
		
		service.invoke("onPeerConnect", new Object[]{otherUserId}, this);
	}
	
	private void sendUserBanned(IConnection user, int banTime) {
		IServiceCapableConnection service = (IServiceCapableConnection)user;
		
		service.invoke("onBanned", new Object[] {user.getClient().getAttribute(ATT_USER_ID), banTime}, this);
	}
	
	private void sendIpBlocked(IConnection user) {
		IServiceCapableConnection service = (IServiceCapableConnection)user;
		
		service.invoke("onBlocked", new Object[] {user.getClient().getAttribute(ATT_USER_ID)}, this);
	}
	
	public boolean disconnectFromUser(String id) {
		String q = "DELETE FROM chats WHERE peer1=\""+id+"\" || peer2=\""+id+"\"";
		
		int res = JabberCamAppData.getInstance().executeUpdate(q);
		
		return res > 0;
	}
	
	public int filterOutUser(String id, String otherUserId) {
		String q = "INSERT INTO filters (id, ip, filter_time) VALUES (\""+id+"\", " +
				"(SELECT ip FROM sessions WHERE id=\""+otherUserId+"\" LIMIT 1), DEFAULT) " +
				"ON DUPLICATE KEY UPDATE filter_time=CURRENT_TIMESTAMP";
		
		int res = JabberCamAppData.getInstance().executeUpdate(q);
		
		return res > 0?FILTER_TIME:0;
	}
	
	public HashMap<String, Object> reportUser(String id, String otherUserId) {
		String q = "SELECT COUNT(*) filtered FROM filters WHERE id=\""+id+"\" && " +
				"ip=(SELECT ip FROM sessions WHERE id=\""+otherUserId+"\" LIMIT 1) && "+
				"DATE_SUB(NOW(), INTERVAL "+FILTER_TIME+" MINUTE)>filter_time";
		
		HashMap<String, Object> responseResult = new HashMap<String, Object>();
		
		ResultSet res = JabberCamAppData.getInstance().executeQuery(q);
		if(res != null) {
			try {
				res.next();
				if(res.getInt("filtered") > 0) {
					responseResult.put("reportSuccess", false);
					return responseResult;
				}
			} catch(SQLException ex) {
//				log.error("Error at reportUser", ex);
			} finally {
				try {
					res.close();
				} catch(SQLException ex2) {
					
				}
			}
		}
		
		IConnection otherUser = getUser(otherUserId);
		if(otherUser == null) {
			responseResult.put("reportSuccess", false);
			return responseResult;
		}
		
		String remoteAddress = otherUser.getRemoteAddress();
		
		String stmt = "INSERT INTO bans VALUES (\""+remoteAddress+"\", 1, "+
			"DEFAULT) ON DUPLICATE KEY UPDATE report_count=report_count+1";
		
		int c = JabberCamAppData.getInstance().executeUpdate(stmt);
		
		responseResult.put("reportSuccess", c > 0);
		responseResult.put("reportToBan", NUM_REPORTS_TO_BAN);
		
		stmt = "SELECT report_count FROM bans WHERE ip=\""+remoteAddress+"\" LIMIT 1";
		res = JabberCamAppData.getInstance().executeQuery(stmt);
		
		if(res != null) {
			try {
				res.next();
				int report_count = res.getInt("report_count");
				
				responseResult.put("reportCount", report_count);
				
				if(report_count >= NUM_REPORTS_TO_BAN) {
					stmt = "UPDATE bans SET report_count=0, ban_time=CURRENT_TIMESTAMP WHERE ip=\""+
						remoteAddress+"\" LIMIT 1";
					
					responseResult.put("banTime", BAN_TIME);
					
					JabberCamAppData.getInstance().executeUpdate(stmt);
					
					sendUserBanned(otherUser, BAN_TIME);
				} else {
					filterOutUser(id, otherUserId);
				}
			} catch(SQLException ex) {
//				log.error("Error at reportUser", ex);
			} finally {
				try {
					res.close();
				} catch(SQLException ex2) {
					
				}
			}
			
		}
		
		return responseResult;
	}
}
