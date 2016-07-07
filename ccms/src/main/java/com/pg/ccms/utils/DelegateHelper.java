package com.pg.ccms.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DelegateHelper
{
  public static String getDelegate(String user)
  {
    String delegate = "";
    Connection conn = DBHelper.getConnection();
    try
    {
      PreparedStatement stmt = conn.prepareStatement("select delegate from tblCMSUser where account=?");
      
      stmt.setString(1, user);
      
      ResultSet rs = stmt.executeQuery();
      if (rs.next()) {
        delegate = rs.getString("delegate");
      }
      rs.close();
      stmt.close();
    }
    catch (SQLException e)
    {
      e.printStackTrace();
    }
    DBHelper.closeConnection(conn);
    
    return delegate;
  }
  
  public static String getDelegateEmail(String user)
  {
    String email = null;
    Connection conn = DBHelper.getConnection();
    try
    {
      PreparedStatement stmt = conn.prepareStatement("select email from tblCMSUser where account=(select delegate from tblCMSUser where account=?)");
      
      stmt.setString(1, user);
      
      ResultSet rs = stmt.executeQuery();
      if (rs.next()) {
        email = rs.getString("email");
      }
      rs.close();
      stmt.close();
    }
    catch (SQLException e)
    {
      e.printStackTrace();
    }
    DBHelper.closeConnection(conn);
    
    return email;
  }
  
  protected static String isAreaOwner(String user)
  {
    Connection c = null;
    Statement st = null;
    
    ResultSet rs = null;
    String sql = "select o.areaid from tblAreaOwners o,tblArea a where o.areaid=a.areaid and (a.hidden<>'Y' or a.hidden is null) and charindex(';" + user + ";',';'+changeOwnerAccount+';')>0";
    
    String strAreaIDs = "";
    try
    {
      c = DBHelper.getConnection();
      st = c.createStatement();
      rs = st.executeQuery(sql);
      if (rs.next()) {
        strAreaIDs = rs.getString("areaid");
      }
      while (rs.next()) {
        strAreaIDs = strAreaIDs + "," + rs.getInt("areaid");
      }
      return strAreaIDs;
    }
    catch (Exception e)
    {
      e.printStackTrace();
      return strAreaIDs;
    }
    finally
    {
      DBHelper.closeConnection(c);
      DBHelper.closeResultset(rs);
      DBHelper.closeStatement(st);
    }
  }
  
  public static String getDelegatedOwnerIDs(String user)
  {
    String IDs = "";
    Connection conn = DBHelper.getConnection();
    try
    {
      PreparedStatement stmt = conn.prepareStatement("select account from tblCMSUser where delegate=?");
      
      stmt.setString(1, user);
      
      ResultSet rs = stmt.executeQuery();
      while (rs.next())
      {
        String owner = rs.getString("account");
        IDs = IDs + isAreaOwner(owner);
      }
      rs.close();
      stmt.close();
    }
    catch (SQLException e)
    {
      e.printStackTrace();
    }
    DBHelper.closeConnection(conn);
    
    return "".equals(IDs) ? null : IDs;
  }
  
  public static boolean isDirectorDelegate(String user)
  {
    boolean isDelegate = false;
    Connection conn = DBHelper.getConnection();
    try
    {
      PreparedStatement stmt = conn.prepareStatement("select delegate from tblCMSUser where director='Y'");
      
      ResultSet rs = stmt.executeQuery();
      while (rs.next())
      {
        String delegate = rs.getString("delegate");
        if (delegate != null) {
          isDelegate = delegate.equalsIgnoreCase(user);
        }
      }
      rs.close();
      stmt.close();
    }
    catch (SQLException e)
    {
      e.printStackTrace();
    }
    DBHelper.closeConnection(conn);
    
    return isDelegate;
  }
}
