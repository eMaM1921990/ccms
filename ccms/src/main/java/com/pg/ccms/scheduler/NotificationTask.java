package com.pg.ccms.scheduler;

import com.pg.ccms.utils.DBHelper;
import com.pg.ccms.utils.MailSender;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Calendar;
import java.util.TimerTask;

public class NotificationTask
  extends TimerTask
{
  public void run()
  {
    System.out.println("find late tasks, and sent notifications");
    String sql = "select logID, requestDate,startTiming, endtiming, originator,approvalStatus, isEmergency, notified, approvedDate from tblChangeControlLog log , tblApprovalStatus stat,tblEquipment e where log.ApprovalStatusID = stat.approvalStatusID and log.equipmentID=e.equipmentID and  (log.hidden is null or log.hidden <> 'Y') and (stat.approvalStatus <> 'Rejected' and stat.approvalStatus <> 'Cancelled' and stat.approvalStatus <> 'On Hold' and stat.approvalStatus <> 'Complete' ) order by logID desc";
    
    Connection conn = DBHelper.getConnection();
    if (conn != null) {
      try
      {
        PreparedStatement stmt = conn.prepareStatement(sql);
        ResultSet resultSet = stmt.executeQuery();
        while (resultSet.next())
        {
          int logId = resultSet.getInt("logID");
          String status = resultSet.getString("approvalStatus");
          java.sql.Date startDate = resultSet.getDate("startTiming");
          java.sql.Date endDate = resultSet.getDate("endTiming");
          java.sql.Date requestDate = resultSet.getDate("requestDate");
          java.sql.Date approvedDate = resultSet.getDate("approvedDate");
          boolean isEmergency = resultSet.getBoolean("isEmergency");
          
          checkLog(logId, status, requestDate, startDate, endDate, approvedDate, isEmergency);
        }
        DBHelper.closeResultset(resultSet);
        DBHelper.closeStatement(stmt);
        DBHelper.closeConnection(conn);
      }
      catch (SQLException e)
      {
        e.printStackTrace();
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }
    }
  }
  
  private void checkLog(int logId, String status, java.sql.Date requestDate, java.sql.Date startDate, java.sql.Date endDate, java.sql.Date approvedDate, boolean isEmergency)
    throws Exception
  {
    Calendar calendar = Calendar.getInstance();
    calendar.setTime(requestDate);
    calendar.add(5, 1);
    java.util.Date requestNextDay = calendar.getTime();
    
    calendar = Calendar.getInstance();
    calendar.setTime(requestDate);
    calendar.add(5, 5);
    java.util.Date requestNext5Days = calendar.getTime();
    
    java.util.Date now = new java.util.Date();
    if ("Pending".equals(status))
    {
      if ((now.after(endDate)) || ((isEmergency) && (now.after(requestNextDay)))) {
        notifyManager(logId, isEmergency);
      }
    }
    else if ("In Progress".equals(status))
    {
      if ((now.after(endDate)) || ((isEmergency) && (now.after(requestNextDay))) || (now.after(requestNext5Days))) {
        notifyApprovers(logId, isEmergency);
      }
    }
    else if ("Approved".equals(status))
    {
      if (now.after(endDate)) {
        notifyCreatorAndManager(logId);
      }
    }
    else if ("Implemented".equals(status))
    {
      if (now.after(endDate)) {
        notifyFollowUp(logId);
      }
    }
    else {
      "Overdue".equals(status);
    }
  }
  
  private void notifyManager(int logId, boolean isEmergency)
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
  
  private void notifyApprovers(int logId, boolean isEmergency)
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
  
  private void notifyCreatorAndManager(int logId)
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
  
  private void notifyFollowUp(int logId)
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
      strMsg = strMsg + " The Change Management Request: " + logId + " has been implemented and needs your follow up.<br/>";
      strMsg = strMsg + " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n=" + logId + "' target='review'>here</a> to review the  request.";
      strMsg = strMsg + "<br/><br/><b>Change Description:</b><div style='border:1px solid #000000;padding:10px'>" + strDesc + "</div>";
      MailSender.sendEMail(strApproverEmails, "Follow up needed for Change Request:" + logId, strMsg);
      
      System.out.println("notifyFollowUp(" + logId + ") :" + strApproverEmails);
    }
  }
}
