package com.pg.ccms.scheduler;

import com.pg.ccms.utils.DBHelper;
import com.pg.ccms.utils.MailSender;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class NotificationUtil
{
  public static void notifyManager(int logId, boolean isEmergency)
    throws Exception
  {
    String sql = "select Originator, creatorEmail, ChangeDesc, ChangeOwnerName, ChangeOwnerEmail from tblChangeControlLog inner join tblAreaOwners on tblChangeControlLog.AreaID = tblAreaOwners.areaID where LogID=?";
    
    Connection conn = DBHelper.getConnection();
    String ownerName = "";
    String ownerEmail = "";
    String originator = "";
    String strDesc = "";
    if (conn != null)
    {
      PreparedStatement stmt = conn.prepareStatement(sql);
      stmt.setInt(1, logId);
      ResultSet rs = stmt.executeQuery();
      while (rs.next())
      {
        ownerName = rs.getString("ChangeOwnerName");
        ownerEmail = rs.getString("ChangeOwnerEmail");
        originator = rs.getString("Originator");
        strDesc = rs.getString("ChangeDesc");
      }
      String strMsg = "Hello, " + ownerName + "<br/>";
      strMsg = strMsg + " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
      if (isEmergency) {
        strMsg = strMsg + "<p style='color:#ff0000'>IMPORTANT- EMERGENCY CHANGE REQUEST. Review Immediately</p>";
      }
      strMsg = strMsg + " A Change Management Request:" + logId + " has not been approved in time, submitted by <b>" + originator + "</b><br/>";
      
      strMsg = strMsg + " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n=" + logId + "' target='review'>here </a> to view the request.<br/>";
      
      strMsg = strMsg + "<br/>Change Description:<br/><div style='border:1px solid #000000;padding:10px;'>" + strDesc + "</div>";
      
      String strSubject = "Change Request Not approved: " + logId;
      if (isEmergency) {
        strSubject = "Emergency change request NOT approved yet: " + logId;
      }
      MailSender.sendEMail(ownerEmail, strSubject, strMsg);
      
      System.out.println("notifyManager(" + logId + ") :" + "ownerEmail = " + ownerEmail);
      
      DBHelper.closeResultset(rs);
      DBHelper.closeStatement(stmt);
      DBHelper.closeConnection(conn);
    }
  }
  
  public static void notifyApprovers(int logId, boolean isEmergency)
    throws Exception
  {
    Connection conn = DBHelper.getConnection();
    if (conn == null) {
      return;
    }
    String strSql = "select changeDesc from tblChangeControlLog where logID=" + logId;
    
    String strDesc = "";
    String strApproverEmails = "";
    
    Statement st = conn.createStatement();
    ResultSet rs = st.executeQuery(strSql);
    if (rs.next()) {
      strDesc = rs.getString("changeDesc") == null ? "" : rs.getString("changeDesc");
    }
    strSql = "select approverEmail from tblApprovalSignature where isChecked=0 and rejected=0 and  logID=" + logId;
    
    rs = st.executeQuery(strSql);
    while (rs.next())
    {
      String strEmail = rs.getString("approverEmail");
      if ((strEmail != null) && (strEmail.indexOf("@") > -1)) {
        strApproverEmails = strApproverEmails + ";" + strEmail;
      }
    }
    strSql = "select reviewerEmail from tblTeamReview where checked=0 and rejected=0 and logid=" + logId;
    
    rs = st.executeQuery(strSql);
    while (rs.next())
    {
      String strEmail = rs.getString("reviewerEmail") == null ? "" : rs.getString("reviewerEmail");
      if ((!strEmail.equals("")) && (strEmail.indexOf("@") > -1)) {
        strApproverEmails = strApproverEmails + ";" + strEmail;
      }
    }
    strSql = "select email from tblLineTeamReview where approved<>'Y' and rejected<>'Y' and logid=" + logId;
    
    rs = st.executeQuery(strSql);
    while (rs.next())
    {
      String strEmail = rs.getString("email") == null ? "" : rs.getString("email");
      if ((!strEmail.equals("")) && (strEmail.indexOf("@") > -1)) {
        strApproverEmails = strApproverEmails + ";" + strEmail;
      }
    }
    if (strApproverEmails.length() > 0)
    {
      strApproverEmails = strApproverEmails.substring(1);
      
      String strMsg = "Hello,<br/>";
      strMsg = strMsg + " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
      
      strMsg = strMsg + " Change request: <em>#" + logId + "</em>  needs your approval.<br/>";
      
      strMsg = strMsg + " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n=" + logId + "' target='review'>here</a> to review the change request.";
      
      strMsg = strMsg + "<br/><br/><b>Change Description:</b><div style='border:1px solid #000000;padding:10px'>" + strDesc + "</div>";
      
      MailSender.sendEMail(strApproverEmails, "Approval needed for Change Request: " + logId, strMsg);
      
      System.out.println("notifyApprovers(" + logId + ") :" + "strApproverEmails = " + strApproverEmails);
    }
    DBHelper.closeResultset(rs);
    DBHelper.closeStatement(st);
    DBHelper.closeConnection(conn);
  }
  
  static void notifyCreatorAndManager(int logId)
    throws Exception
  {
    String sql = "select Originator, creatorEmail, ChangeDesc, ChangeOwnerName, ChangeOwnerEmail from tblChangeControlLog inner join tblAreaOwners on tblChangeControlLog.AreaID = tblAreaOwners.areaID where LogID=?";
    
    Connection conn = DBHelper.getConnection();
    String ownerName = "";
    String ownerEmail = "";
    String creatorEmail = "";
    String originator = "";
    String strDesc = "";
    if (conn != null)
    {
      PreparedStatement stmt = conn.prepareStatement(sql);
      stmt.setInt(1, logId);
      ResultSet rs = stmt.executeQuery();
      while (rs.next())
      {
        ownerName = rs.getString("ChangeOwnerName");
        ownerEmail = rs.getString("ChangeOwnerEmail");
        creatorEmail = rs.getString("creatorEmail");
        originator = rs.getString("Originator");
        strDesc = rs.getString("ChangeDesc");
      }
      String strMsg = "Hello, " + ownerName + "<br/>";
      strMsg = strMsg + " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
      
      strMsg = strMsg + " The Change Management Request:" + logId + " has been approved and passed the complete date and not yet implemented.<br/>" + "Creator: <b>" + originator + "</b><br/>";
      
      strMsg = strMsg + " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n=" + logId + "' target='review'>here </a> to view the request.<br/>";
      
      strMsg = strMsg + "<br/>Change Description:<br/><div style='border:1px solid #000000;padding:10px;'>" + strDesc + "</div>";
      
      String strSubject = "Approved Change Request Overdue: " + logId;
      
      MailSender.sendEMail(creatorEmail + ";" + ownerEmail, strSubject, strMsg);
      
      System.out.println("notifyCreatorAndManager(" + logId + ") :" + creatorEmail + ";" + ownerEmail);
      
      DBHelper.closeResultset(rs);
      DBHelper.closeStatement(stmt);
      DBHelper.closeConnection(conn);
    }
  }
  
  public static void notifyFollowUp(int logId)
    throws Exception
  {
    Connection conn = DBHelper.getConnection();
    Statement st = conn.createStatement();
    String strApproverEmails = "";
    String strDesc = "";
    String strSql = "select * from tblChangeControlLog where logID=" + logId;
    
    ResultSet rs = st.executeQuery(strSql);
    if (rs.next()) {
      strDesc = rs.getString("changeDesc") == null ? "" : rs.getString("changeDesc");
    }
    strSql = "select approverEmail from tblApprovalSignature where hasFollowup=1 and isFollowupChecked=0 and logID=" + logId;
    
    rs = st.executeQuery(strSql);
    while (rs.next())
    {
      String strEmail = rs.getString("approverEmail");
      if ((strEmail != null) && (strEmail.indexOf("@") > -1)) {
        strApproverEmails = strApproverEmails + ";" + strEmail;
      }
    }
    if (strApproverEmails.length() > 0)
    {
      strApproverEmails = strApproverEmails.substring(1);
      
      String strMsg = "Hello,<br/>";
      strMsg = strMsg + " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
      
      strMsg = strMsg + " Change request: <em>#" + logId + "</em>  has been implemented and needs your follow up.<br/>";
      
      strMsg = strMsg + " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n=" + logId + "' target='review'>here</a> to review the change request.";
      
      strMsg = strMsg + "<br/><br/><b>Change Description:</b><div style='border:1px solid #000000;padding:10px'>" + strDesc + "</div>";
      
      MailSender.sendEMail(strApproverEmails, "Follow up needed for Change Request:" + logId, strMsg);
      
      System.out.println("notifyFollowUp(" + logId + ") :" + strApproverEmails);
    }
  }
  
  public static void notifyApproversManager(List<Integer> toBeEscalated)
    throws Exception
  {
    Connection conn = DBHelper.getConnection();
    if (conn == null) {
      return;
    }
    String strSql = "select DISTINCT o.ChangeOwnerEmail, s.approverEmail FROM dbo.tblAreaOwners o, dbo.tblApprovalSignature s, dbo.tblApprovers a where isChecked=0 and rejected=0 and s.approverEmail=a.approverEmail and o.areaId=a.areaId and  logID= ?";
    
    Map<String, Map<String, List<Integer>>> approversManagersEmails = new HashMap();
    ResultSet rs = null;
    PreparedStatement st = null;
    for (Iterator i$ = toBeEscalated.iterator(); i$.hasNext();)
    {
      int logId = ((Integer)i$.next()).intValue();
      st = conn.prepareStatement(strSql);
      st.setInt(1, logId);
      rs = st.executeQuery();
      while (rs.next())
      {
        String manager = rs.getString("ChangeOwnerEmail");
        if (!approversManagersEmails.containsKey(manager)) {
          approversManagersEmails.put(manager, new HashMap());
        }
        String approver = rs.getString("approverEmail");
        if (!((Map)approversManagersEmails.get(manager)).containsKey(approver)) {
          ((Map)approversManagersEmails.get(manager)).put(approver, new ArrayList());
        }
        ((List)((Map)approversManagersEmails.get(manager)).get(approver)).add(Integer.valueOf(logId));
      }
    }
    for (String manager : approversManagersEmails.keySet())
    {
      StringBuilder sb = new StringBuilder();
      
      sb.append("Hello " + manager.substring(0, manager.indexOf('@')) + ",<br/>").append(" This is an auto-generated message by online Change Management System, please do NOT reply!<br/>").append(" There are some requests has been delayed and needs your follow up.<br/>").append("<p> This Requests needs approval of below approvals:</p><br/>");
      
      sb.append("<p><table><thead><tr><th>Approver &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>").append("<th>Requests &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th></tr></thead><tbody>");
      
      //FIX BY emam 01000292810
      //for (String email : ((Map)approversManagersEmails.get(manager)).keySet())
      //Map<String, Map<String, List<Integer>>> approversManagersEmails = new HashMap();
      
      for (String email : approversManagersEmails.get(manager).keySet())
      {
        sb.append("<tr><td>").append(email).append(" </td><td> ");
        String delimiter = "";
        for (Iterator i$ = ((List)((Map)approversManagersEmails.get(manager)).get(email)).iterator(); i$.hasNext();)
        {
          int logId = ((Integer)i$.next()).intValue();
          sb.append(delimiter);
          delimiter = ",";
          sb.append(logId);
        }
        sb.append("</td></tr>");
      }
      sb.append("</tbody></table></p>");
      sb.append("<p><h4>This request will be deleted next day if not change its status.</h4></p>");
      
      MailSender.sendEMail(manager, "[Delayed] Requests", sb.toString());
    }
    DBHelper.closeResultset(rs);
    DBHelper.closeStatement(st);
    DBHelper.closeConnection(conn);
  }
}
