<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>

<%
  String strLogID=request.getParameter("logid")==null?"":request.getParameter("logid");
  String strLogIDCondition="";
  if (!strLogID.equals(""))
    strLogIDCondition=" and log.logid="+strLogID;

  String strEmergencySel=request.getParameter("emergency")==null?"":request.getParameter("emergency");
  String strEmergencyCondition="";
  if (strEmergencySel.equals("Y"))
    strEmergencyCondition=" log.isEmergency=1";
  else if (strEmergencySel.equals("N"))
    strEmergencyCondition=" log.isEmergency=0";

  String strSafetySel=request.getParameter("safety")==null?"":request.getParameter("safety");
  String strSafetyCondition="";
  if (strSafetySel.equals("Y"))
    strSafetyCondition=" log.isSafety=1";
  else if (strSafetySel.equals("N"))
    strSafetyCondition=" log.isSafety=0";


  String strOriginator = request.getParameter("originator")==null?"":request.getParameter("originator");
  String strOriginatorCondition="";
  if (!strOriginator.equals(""))
    strOriginatorCondition=" originator like '%"+strOriginator + "%'";

  String strCreatorTeam=request.getParameter("creatorteam")==null?"":request.getParameter("creatorteam");
  String  strCreatorTeamCondition="";
  if (!strCreatorTeam.equals("")){
	  strCreatorTeamCondition=" creatorteam='"+strCreatorTeam+"'";
  }
  String strAreaName=request.getParameter("areaname")==null?"":request.getParameter("areaname");
  String strArea=request.getParameter("area")==null?"":request.getParameter("area");
  String strAreaCondition="";
  if (!strArea.equals(""))
    strAreaCondition=" CHARINDEX(',"+strArea+",',','+log.areaID+',')>0";

  if (strArea.equals("11")){
	  strAreaCondition=" ("+strAreaCondition+" or take2site>0)";
  }
  String strStatus=request.getParameter("status")==null?"":request.getParameter("status");
  String strStatusName=request.getParameter("statusName")==null?"":request.getParameter("statusName");
  String strStatusCondition="";
//  if (!strStatus.equals(""))
 //   strStatusCondition=" log.ApprovalStatusID="+strStatus;
  if (strStatusName.length()>0){
	   strStatusCondition=" (log.logNewStatus like '%"+strStatusName+"%')";
  }

 String strEquipment=request.getParameter("equipment")==null?"":request.getParameter("equipment");
  String strEquipmentCondition="";
  if (!strEquipment.equals(""))
    strEquipmentCondition=" log.equipmentID="+strEquipment;

  String strCreationDate1=request.getParameter("cdate1")==null?"":request.getParameter("cdate1");
  String strCreationDate2=request.getParameter("cdate2")==null?"":request.getParameter("cdate2");
  String strCreationDate1Condition="";
  String strCreationDate2Condition="";

  if (!strCreationDate1.equals(""))
    strCreationDate1Condition=" requestDate>=convert(datetime,'"+strCreationDate1+"',101)";
 if (!strCreationDate2.equals(""))
    strCreationDate2Condition=" requestDate<=convert(datetime,'"+strCreationDate2+"',101)";

  String strStartDate1=request.getParameter("sdate1")==null?"":request.getParameter("sdate1");
  String strStartDate2=request.getParameter("sdate2")==null?"":request.getParameter("sdate2");
  String strStartDate1Condition="";
  String strStartDate2Condition="";

  if (!strStartDate1.equals(""))
    strStartDate1Condition=" startTiming>=convert(datetime,'"+strStartDate1+"',101)";
 if (!strStartDate2.equals(""))
    strStartDate2Condition=" startTiming<=convert(datetime,'"+strStartDate2+"',101)";

  String strEndDate1=request.getParameter("edate1")==null?"":request.getParameter("edate1");
  String strEndDate2=request.getParameter("edate2")==null?"":request.getParameter("edate2");
  String strEndDate1Condition="";
  String strEndDate2Condition="";

  if (!strEndDate1.equals(""))
    strEndDate1Condition=" endTiming>=convert(datetime,'"+strEndDate1+"',101)";
 if (!strEndDate2.equals(""))
    strEndDate2Condition=" endTiming<=convert(datetime,'"+strEndDate2+"',101)";

  //"requestDate";
   
  String strFormat=request.getParameter("format")==null?"HTML":request.getParameter("format");
   
  if (strFormat.toUpperCase().equals("EXCEL")){
	 response.reset();
     response.setHeader("Content-type","application/vnd.ms-excel");
     response.setHeader("Content-disposition","inline; filename=report.xls");
  }
  else if (strFormat.toUpperCase().equals("WORD")){
	 response.reset();
       response.setHeader("Content-type","application/vnd.ms-word");
     response.setHeader("Content-disposition","inline; filename=report.doc");
  }

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>report</title>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>
<body>
<div class="title">Cost Report</div>
<div>
<%if (strAreaName.length()>0) {%>
     -><%=strAreaName%>
<%}%>
<%if (strCreatorTeam.length()>0){%>
     -> Team: <%=strCreatorTeam%>
 <%}%>
<%if (strStatusName.length()>0) {%>
     -> <%=strStatusName%>
<%}%>

</div>
<form>
<table style="border:1px solid #ff8040;border-collapse:collapse" cellpadding="2">
<tr style="height:40px;background-color:#ff8040;font-weight:bold;"><th>Status</th><th>Total Cost</th></th>
</tr>
<%
  Connection c=null;
  Statement st=null;
  Statement st2=null;
  ResultSet rs =null;
  ResultSet rs2=null;
  String innerSql = "select l.*, case when (s.approvalstatus='Approved') or (s.approvalstatus='Overdue')  then ";
  innerSql+=" case when l.endtiming<getdate() then 'Approved(Overdue)' else 'Approved' end ";
  innerSql+=" else s.approvalstatus end logNewStatus ";
  innerSql+=" from tblChangeControlLog l,tblApprovalStatus s where (l.hidden is null or l.hidden<>'Y') and l.approvalstatusid=s.approvalstatusid";

  String sql="select sum(log.cost) sumCost,log.logNewStatus  from ("+innerSql+") log";
  sql+=" where 1=1 ";
  sql+= strOriginatorCondition.length()>0?" and "+strOriginatorCondition:"";
  sql+= strCreatorTeamCondition.length()>0?" and "+strCreatorTeamCondition:"";
sql+= strEmergencyCondition.length()>0?" and "+strEmergencyCondition:"";
sql+= strSafetyCondition.length()>0?" and "+strSafetyCondition:"";
sql+= strLogIDCondition.length()>0?" and "+strLogIDCondition:"";
sql+= strAreaCondition.length()>0?" and "+strAreaCondition:"";
sql+= strStatusCondition.length()>0?" and "+strStatusCondition:"";
sql+= strEquipmentCondition.length()>0?" and "+strEquipmentCondition:"";
sql+= strCreationDate1Condition.length()>0?" and "+strCreationDate1Condition:"";
sql+= strCreationDate2Condition.length()>0?" and "+strCreationDate2Condition:"";
sql+= strStartDate1Condition.length()>0?" and "+strStartDate1Condition:"";
sql+= strStartDate2Condition.length()>0?" and "+strStartDate2Condition:"";
sql+= strEndDate1Condition.length()>0?" and "+strEndDate1Condition:"";
sql+= strEndDate2Condition.length()>0?" and "+strEndDate2Condition:"";
 sql+=" group by logNewStatus";

  
//  out.println(sql);
  int i=0;
  try {
    c=DBHelper.getConnection();
    st=c.createStatement();
    rs = st.executeQuery(sql);
	String strClass="";
	double totalTotal=0.0;
	double totalCost=0.0;
	boolean bOk=false;
	DecimalFormat fmt = new DecimalFormat("#,###.00");
    while (rs.next())  {
		 totalCost= rs.getDouble("sumCost");
		 String strTotalCost=fmt.format(totalCost);
		 totalTotal+=totalCost;
		 String strStatus_t=rs.getString("logNewStatus");
		 bOk=true;

		if (i%2==0)
			strClass="evenRow";
		else
			strClass="oddRow";
		i++;
		%>
        <tr style="height:30px;" class="<%=strClass%>">
		 <td style="border:1px solid #ff8040;font-weight:bold"><%=strStatus_t%></td><td style="border:1px solid #ff8040;text-align:right">$<%=strTotalCost%></td>
		</tr>
		<%
	 }
	 if (bOk){
		 String strGrandTotal=fmt.format(totalTotal);
		 %>
		 <tr style="height:40px;background-color:#ff8040;font-weight:bold;"><td>Grand Total:</td><td>$<%=strGrandTotal%></td></tr>
		 <%
	 }
  }

	 catch(Exception e){
		 out.println(e);
	 }finally{
    	 DBHelper.closeResultset(rs);
	     DBHelper.closeStatement(st);
		 DBHelper.closeResultset(rs2);
	     DBHelper.closeStatement(st2);
	     DBHelper.closeConnection(c);
	 }
%>
</table>
</form>
 </body>
</html>