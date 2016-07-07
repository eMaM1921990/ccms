package com.pg.ccms.utils;

import java.io.PrintStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class DBHelper
{
  private static String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
  private static boolean bLoaded = false;
  
  public static Connection getConnection()
  {
    Connection conn = null;
    if (!bLoaded) {
      loadDriver();
    }
    try
    {
      conn = DriverManager.getConnection(ConfigHelper.getDBUrl(), ConfigHelper.getDBUser(), ConfigHelper.getDBPass());
      
      conn.setAutoCommit(false);
    }
    catch (Exception e)
    {
      System.out.println("Error:" + e);
      conn = null;
    }
    return conn;
  }
  
  public static void closeConnection(Connection conn)
  {
    try
    {
      if (conn != null)
      {
        conn.close();
        conn = null;
      }
    }
    catch (Exception localException) {}
  }
  
  public static void closeStatement(Statement stmt)
  {
    try
    {
      if (stmt != null)
      {
        stmt.close();
        stmt = null;
      }
    }
    catch (Exception localException) {}
  }
  
  public static void closeResultset(ResultSet rs)
  {
    try
    {
      if (rs != null)
      {
        rs.close();
        rs = null;
      }
    }
    catch (Exception localException) {}
  }
  
  public static void loadDriver()
  {
    try
    {
      Class.forName(driver);
      bLoaded = true;
    }
    catch (ClassNotFoundException e)
    {
      System.out.println("When Loading Drivers: " + e);
      bLoaded = false;
    }
  }
  
  public static void log(Connection conn, String user, String msg)
    throws Exception
  {
    String sqlstr = "insert into tblCCMSLogging(acct, creationTime, message) values (?,getDate(),?)";
    String newMsg = new String(msg);
    boolean bNewConnection = false;
    if (newMsg.length() > 1000) {
      newMsg = newMsg.substring(0, 999);
    }
    Connection dbconn = conn;
    if (dbconn == null)
    {
      dbconn = getConnection();
      bNewConnection = true;
    }
    PreparedStatement pstmt = dbconn.prepareStatement(sqlstr);
    try
    {
      pstmt.setString(1, user);
      pstmt.setString(2, newMsg);
      pstmt.execute();
      dbconn.commit();
    }
    catch (Exception e)
    {
      dbconn.rollback();
      System.out.println("NotificationTask: " + e);
    }
    finally
    {
      closeStatement(pstmt);
      if ((dbconn != null) && (bNewConnection)) {
        closeConnection(dbconn);
      }
    }
  }
  
  public static String getSystemOwnerEmail()
  {
    String sqlstr = "Select email from tblCMSUser where director='Y'";
    String directorAcct = "";
    
    Connection dbconn = getConnection();
    
    PreparedStatement stmt = null;
    try
    {
      stmt = dbconn.prepareStatement(sqlstr);
      ResultSet rs = stmt.executeQuery();
      if (rs.next()) {
        directorAcct = rs.getString("email");
      }
    }
    catch (Exception e)
    {
      System.out.println("NotificationTask: " + e);
    }
    finally
    {
      closeStatement(stmt);
      closeConnection(dbconn);
    }
    return directorAcct;
  }
}
