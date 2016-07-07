<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>

<%
  String strLogID=request.getParameter("logid")==null?"":request.getParameter("logid");
  String strLogIDCondition=" 1=1";
  if (!strLogID.equals(""))
    strLogIDCondition=" log.logid="+strLogID;


  String strOriginator = request.getParameter("originator")==null?"":request.getParameter("originator");
  String strOriginatorCondition=" 1=1";
  if (!strOriginator.equals(""))
    strOriginatorCondition=" originator like '%"+strOriginator + "%'";

  String strArea=request.getParameter("area")==null?"":request.getParameter("area");
  String strAreaCondition=" 1=1";
  if (!strArea.equals(""))
    strAreaCondition=" CHARINDEX(',"+strArea+",',areaID+',')>0";

  String strStatus=request.getParameter("status")==null?"":request.getParameter("status");
  String strStatusCondition=" 1=1";
  if (!strStatus.equals(""))
    strStatusCondition=" log.ApprovalStatusID="+strStatus;

 String strEquipment=request.getParameter("equipment")==null?"":request.getParameter("equipment");
  String strEquipmentCondition=" 1=1";
  if (!strEquipment.equals(""))
    strEquipmentCondition=" log.equipmentID="+strEquipment;

  String strCreationDate1=request.getParameter("cdate1")==null?"":request.getParameter("cdate1");
  String strCreationDate2=request.getParameter("cdate2")==null?"":request.getParameter("cdate2");
  String strCreationDate1Condition=" 1=1";
  String strCreationDate2Condition=" 1=1";

  if (!strCreationDate1.equals(""))
    strCreationDate1Condition=" requestDate>=convert(datetime,'"+strCreationDate1+"',101)";
 if (!strCreationDate2.equals(""))
    strCreationDate2Condition=" requestDate<=convert(datetime,'"+strCreationDate2+"',101)";

  String strStartDate1=request.getParameter("sdate1")==null?"":request.getParameter("sdate1");
  String strStartDate2=request.getParameter("sdate2")==null?"":request.getParameter("sdate2");
  String strStartDate1Condition=" 1=1";
  String strStartDate2Condition=" 1=1";

  if (!strStartDate1.equals(""))
    strStartDate1Condition=" startTiming>=convert(datetime,'"+strStartDate1+"',101)";
 if (!strStartDate2.equals(""))
    strStartDate2Condition=" startTiming<=convert(datetime,'"+strStartDate2+"',101)";

  String strEndDate1=request.getParameter("edate1")==null?"":request.getParameter("edate1");
  String strEndDate2=request.getParameter("edate2")==null?"":request.getParameter("edate2");
  String strEndDate1Condition=" 1=1";
  String strEndDate2Condition=" 1=1";

  if (!strEndDate1.equals(""))
    strEndDate1Condition=" endTiming>=convert(datetime,'"+strEndDate1+"',101)";
 if (!strEndDate2.equals(""))
    strEndDate2Condition=" sendTiming<=convert(datetime,'"+strEndDate2+"',101)";

  //"requestDate";
  String strOrderBy=request.getParameter("orderby")==null?"":request.getParameter("orderby");
  String strSort=request.getParameter("sort")==null?"asc":request.getParameter("sort");

  String strSortImageName="arrowSortDown.gif";
  if (!strSort.equals("desc"))
    strSortImageName="arrowSortUp.gif";
  
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
<form>
<table>
<tr><th>Log#</th><th>RequestDate</th><th>Originator</th><th>Department</th><th>Line</th><th>Equipment</th><th>StartTiming</th><th>EndTiming</th><th>costType</th><th>Cost</th><th>Status</th><th>EO/Chemical Clearance?</th><th>Emergency?</th>
</tr>
<%
  Connection c=null;
  Statement st=null;
  Statement st2=null;
  ResultSet rs =null;
  ResultSet rs2=null;
  String sql="select log.*,appr.*,e.*, isnull(CONVERT(VARCHAR(10), log.requestDate, 101),'') requestDateStr,isnull(CONVERT(VARCHAR(10), log.startTiming, 101),'') startTimingStr,isnull(CONVERT(VARCHAR(10), log.endTiming, 101),'') endTimingStr   from tblChangeControlLog log,tblApprovalStatus appr, tblEquipment e where log.approvalstatusid=appr.approvalstatusid and log.equipmentID=e.equipmentID";
  sql+= " and "+strOriginatorCondition;
  sql+= " and "+strLogIDCondition;
  sql+= " and "+strAreaCondition;
  sql+= " and "+strStatusCondition;
  sql+= " and "+strEquipmentCondition;
  sql+= " and "+strCreationDate1Condition;
  sql+= " and "+strCreationDate2Condition;
  sql+= " and "+strStartDate1Condition;
  sql+= " and "+strStartDate2Condition;
  sql+= " and "+strEndDate1Condition;
  sql+= " and "+strEndDate2Condition;

  if (!strOrderBy.equals(""))
   sql+=" order by "+ strOrderBy +" "+strSort;

 // out.println(sql);
  int i=0;
  try {
    c=DBHelper.getConnection();
    st=c.createStatement();
    rs = st.executeQuery(sql);
    while (rs.next())  {
		int iLogID_t=rs.getInt("logID");
		String strRequestDate_t=rs.getString("requestDateStr");
		String strOriginator_t=rs.getString("originator");
		String strAreaID_t=rs.getString("areaID");
		String strLineID_t=rs.getString("lineID");
		String strAreaNames=rs.getString("areaNames");
		String strLineNames=rs.getString("lineNames");
		String strEquipment_t=rs.getString("equipmentName");
		boolean bIsReapplication=rs.getBoolean("isReapplication");
		String strStartTiming_t=rs.getString("startTimingStr");
		String strEndTiming_t=rs.getString("endTimingStr");
		String strCost_t=rs.getString("cost");
		String strCostType_t=rs.getString("costType");
		String strStatus_t=rs.getString("approvalStatus");
		strStatus_t=strStatus_t.equalsIgnoreCase("Approved")?"<font color='#00DD00'>"+strStatus_t+"</font>":strStatus_t;
        String strClass="even";
		boolean isSafety=rs.getBoolean("IsSafety");
    	boolean isEmergency=rs.getBoolean("IsEmergency");
        String strSafety=isSafety?"<font color='#FF0000'>Y</font>":"N";
        String strEmergency=isEmergency?"<font color='#FF0000'>Y</font>":"N";

		if (i%2==0)
			strClass="evenRow";
		else
			strClass="oddRow";
		i++;
		%>
        <tr class="<%=strClass%>">
		 <td><a href="./reviewRequest.jsp?n=<%=iLogID_t%>"><%=iLogID_t%></a></td><td><%=strRequestDate_t%></td>
		 <td><%=strOriginator_t%></td><td><%=strAreaNames%></td><td><%=strLineNames%></td><td><%=strEquipment_t%></td>
		 <td><%=strStartTiming_t%></td><td><%=strEndTiming_t%></td><td><%=strCostType_t%></td><td><%=strCost_t%></td><td><%=strStatus_t%></td><td><%=strSafety%></td><td><%=strEmergency%></td>

		</tr>
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