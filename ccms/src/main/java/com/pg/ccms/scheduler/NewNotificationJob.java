package com.pg.ccms.scheduler;

import com.pg.ccms.Status;
import com.pg.ccms.StatusHandler;
import com.pg.ccms.utils.DBHelper;

import java.io.PrintStream;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.joda.time.LocalDate;

public class NewNotificationJob
  implements Runnable
{
  List<Integer> toBeEscalated = new ArrayList();
  
  public void run()
  {
    String sql = "select logID, requestDate,startTiming, endtiming, originator,approvalStatus, isEmergency, notified, approvedDate, escalated from tblChangeControlLog log , tblApprovalStatus stat,tblEquipment e where log.ApprovalStatusID = stat.approvalStatusID and log.equipmentID=e.equipmentID and  (log.hidden is null or log.hidden <> 'Y') and (stat.approvalStatus <> 'Rejected' and stat.approvalStatus <> 'Cancelled' and stat.approvalStatus <> 'On Hold' and stat.approvalStatus <> 'Complete' ) order by logID desc";
    
    Connection conn = DBHelper.getConnection();
    if (conn != null) {
      try
      {
        PreparedStatement stmt = conn.prepareStatement(sql);
        ResultSet resultSet = stmt.executeQuery();
        this.toBeEscalated = new ArrayList();
        while (resultSet.next())
        {
          int logId = resultSet.getInt("logID");
          String status = resultSet.getString("approvalStatus");
          Date startDate = resultSet.getDate("startTiming");
          Date endDate = resultSet.getDate("endTiming");
          Date requestDate = resultSet.getDate("requestDate");
          
          Date approvedDate = resultSet.getDate("approvedDate");
          
          boolean isEmergency = resultSet.getBoolean("isEmergency");
          boolean escalated = resultSet.getBoolean("escalated");
          
          System.out.println("logId : " + logId + "; Status : " + status);
          
          checkLog(logId, status, requestDate, startDate, endDate, approvedDate, isEmergency, escalated);
        }
        NotificationUtil.notifyApproversManager(this.toBeEscalated);
        for (Iterator i$ = this.toBeEscalated.iterator(); i$.hasNext();)
        {
          int logId = ((Integer)i$.next()).intValue();
          updateEscalated(logId);
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
  
  private void checkLog(int logId, String status, Date requestDate, Date startDate, Date endDate, Date approvedDate, boolean isEmergency, boolean escalated)
    throws Exception
  {
    LocalDate reqLocalDate = new LocalDate(requestDate);
    LocalDate startLocalDate = new LocalDate(startDate);
    LocalDate endLocalDate = new LocalDate(endDate);
    LocalDate today = LocalDate.now();
    Status requestStatus = Status.valueOf(status.replace(' ', '_'));
    //Fix emam NewNotificationJob.1.$SwitchMap$com$pg$ccms$Status[requestStatus.ordinal()]
    switch ( requestStatus.ordinal())
    {
    case 1: 
      if ((checkAfterBD(reqLocalDate, 3)) && (escalated)) {
        hideRequest(logId);
      } else if (checkAfterBD(reqLocalDate, 2)) {
        this.toBeEscalated.add(Integer.valueOf(logId));
      }
      break;
    }
  }
  
  private void updateEscalated(int logId)
  {
    System.out.println("Set escalated for :" + logId);
    String sql = "update tblChangeControllog set  escalated=1 where logid=" + logId;
    
    Connection conn = DBHelper.getConnection();
    if (conn != null) {
      try
      {
        Statement stmt = conn.createStatement();
        stmt.executeUpdate(sql);
        conn.commit();
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
  
  private void hideRequest(int logId)
  {
    System.out.println("hide Request :" + logId);
    String sql = "update tblChangeControllog set  hidden='Y' where logid=" + logId;
    
    Connection conn = DBHelper.getConnection();
    if (conn != null) {
      try
      {
        Statement stmt = conn.createStatement();
        stmt.executeUpdate(sql);
        conn.commit();
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
  
  boolean checkAfterBD(LocalDate date, int days)
  {
    System.out.println("check " + date + " after BD " + days);
    boolean result = false;
    LocalDate today = LocalDate.now();
    LocalDate index = new LocalDate(date);
    for (int i = 0; i < days; i++)
    {
      System.out.println("add day");
      index = index.plusDays(1);
      if (date.getDayOfWeek() == 5) {
        index = index.plusDays(2);
      }
      if (date.getDayOfWeek() == 6) {
        index = index.plusDays(1);
      }
      System.out.println("index :" + index);
    }
    System.out.println("index :" + index);
    if (index.isBefore(today)) {
      result = true;
    }
    System.out.println("return " + result);
    return result;
  }
}
