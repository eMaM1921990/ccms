package com.pg.ccms.utils;

import java.util.ResourceBundle;

public class ConfigHelper
{
  private static ResourceBundle bundle = null;
  private static final String DB_URL = "db.url";
  private static final String DB_USER = "db.user";
  private static final String DB_PASS = "db.pass";
  private static final String MAIL_SERVER = "mail.smtp";
  private static final String MAIL_FROM = "mail.from";
  private static final String SERVER_BASE = "server.base";
  
  public static String getDBUrl()
  {
    return getBundle().getString("db.url");
  }
  
  public static String getDBUser()
  {
    return getBundle().getString("db.user");
  }
  
  public static String getDBPass()
  {
    return getBundle().getString("db.pass");
  }
  
  public static String getMailServer()
  {
    return getBundle().getString("mail.smtp");
  }
  
  public static String getMailFrom()
  {
    return getBundle().getString("mail.from");
  }
  
  public static String getServerBase()
  {
    return getBundle().getString("server.base");
  }
  
  private static ResourceBundle getBundle()
  {
    if (bundle == null)
    {
      String packageName = ConfigHelper.class.getPackage().getName();
      bundle = ResourceBundle.getBundle(packageName + ".config");
    }
    return bundle;
  }
}
