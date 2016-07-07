<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>

<%
  String strLogId=request.getParameter("logid")==null?"":request.getParameter("logid");

  String strLogIdCondition=" 1=1";
  if (!strLogId.equals(""))
    strLogIdCondition=" log.logid="+strLogId;

  String strArea=request.getParameter("areaList")==null?"":request.getParameter("areaList");
  if (strArea.equals("-999")) { strArea="";}
  String strAreaCondition=" 1=1";
  if (!strArea.equals(""))
    strAreaCondition=" CHARINDEX(',"+strArea+",', ','+log.areaID+',')>0";

  if (strArea.equals("11")){
	  strAreaCondition=" ("+strAreaCondition+" or take2site>0)";
  }

  String strCreatorTeam=request.getParameter("creatorteam")==null?"":request.getParameter("creatorteam");
  String  strCreatorTeamCondition=" 1=1";
  if (!strCreatorTeam.equals("")){
	  strCreatorTeamCondition=" creatorteam='"+strCreatorTeam+"'";
  }

 
  String strApproverType=request.getParameter("approverTypeList")==null?"":request.getParameter("approverTypeList");
  String strApproverTypeCondition=" 1=1";
  if (!strApproverType.equals(""))
    strApproverTypeCondition=" approverType ='"+strApproverType+"'";


 String strFollowupComplete=request.getParameter("followupComplete")==null?"all":request.getParameter("followupComplete");
 String strFollowupCompleteCondition=" 1=1";
 if (strFollowupComplete.equals("complete")){
    strFollowupCompleteCondition=" isFollowupChecked=1";
 }
 else if (strFollowupComplete.equals("outstanding")){
      strFollowupCompleteCondition=" (isFollowupChecked=0 or isFollowupChecked is null)";
 }



  String strCreationDate1=request.getParameter("cdate1")==null?"":request.getParameter("cdate1");
  String strCreationDate2=request.getParameter("cdate2")==null?"":request.getParameter("cdate2");
  String strCreationDate1Condition=" 1=1";
  String strCreationDate2Condition=" 1=1";

  if (!strCreationDate1.equals(""))
    strCreationDate1Condition=" requestDate>=convert(datetime,'"+strCreationDate1+"',101)";
 if (!strCreationDate2.equals(""))
    strCreationDate2Condition=" requestDate<=convert(datetime,'"+strCreationDate2+"',101)";

  String strOrderBy=request.getParameter("orderby")==null?"log.logid":request.getParameter("orderby");
  //"requestDate";
  String strOrder=request.getParameter("order")==null?"desc":request.getParameter("order");//"desc";

  String strSortImageName="arrowSortDown.gif";
  if (!strOrder.equals("desc"))
    strSortImageName="arrowSortUp.gif";
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Followup report</title>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
  <script  type="text/javascript">

function handleOrder(field){
	var orderByObj=document.getElementById("orderby");
	var orderObj=document.getElementById("order");
	var oldField=orderByObj.value;
	if (field==oldField)
		orderObj.value=(orderObj.value=="desc")?"asc":"desc";
	else {
		orderByObj.value=field;
        orderObj.value=  "desc";
	}
    document.the_form.submit();
}

</script>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
<div class="title">Followup Report</div>
<form name="the_form" id="the_form" method="post" action="">

<%

  Connection c=null;
  Statement st=null;
  Statement st2=null;
  ResultSet rs =null;
  ResultSet rs2=null;
  String sql="select log.logid lgid, log.*,tas.*,isnull(CONVERT(VARCHAR(10), tas.followupCheckDate, 101),'') followupCheckDateStr, appr.approvalStatus  from tblChangeControlLog log, tblApprovalSignature tas,tblApprovalStatus appr where (log.hidden is null or log.hidden<>'Y') and log.logid=tas.logid and log.approvalstatusid=appr.approvalstatusid and appr.approvalstatus not in ('Cancelled','Rejected','On Hold') and  tas.hasFollowup<>0";
  sql+=" and "+strLogIdCondition;
  sql+= " and "+strAreaCondition;
  sql+= " and "+strCreatorTeamCondition;
  sql+= " and "+strApproverTypeCondition;
  sql+= " and "+strFollowupCompleteCondition;
  sql+= " and "+strCreationDate1Condition;
  sql+= " and "+strCreationDate2Condition;
  sql+=" order by "+ strOrderBy+" "+strOrder;

//  out.println(sql);
  %>
  <input type="hidden" name="orderby" id="orderby" value="<%=strOrderBy%>">
  <input type="hidden" name="order" id="order" value="<%=strOrder%>">
  <input type="hidden" name="areaList" id="areaList" value="<%=strArea%>">
  <input type="hidden" name="approverTypeList" id="approverTypeList" value="<%=strApproverType%>">

 <table border="1" cellspacing="0" cellpadding="2">
 <tr><th style="width:50px"><a href="javascript:handleOrder('log.logid')">ID</a>
       <% if (strOrderBy.equals("log.logid")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>
	   <th><a href="javascript:handleOrder('log.originator')">Request Originator</a>
       <% if (strOrderBy.equals("log.originator")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>
	   <th><a href="javascript:handleOrder('log.areanames')">Department</a>
       <% if (strOrderBy.equals("log.areanames")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>
	   <%-- 
	   <th><a href="javascript:handleOrder('log.creatorteam')">Team</a>
       <% if (strOrderBy.equals("log.creatorteam")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>
	   --%>
	   <th><a href="javascript:handleOrder('log.linenames')">Line</a>
       <% if (strOrderBy.equals("log.linenames")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>
	   <th><a href="javascript:handleOrder('appr.approvalstatus')">Status</a>
       <% if (strOrderBy.equals("appr.approvalstatus")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>
	   	   <th><a href="javascript:handleOrder('tas.approvertype')">FollowUp Department</a>
       <% if (strOrderBy.equals("tas.approvertype")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>

	   <th><a href="javascript:handleOrder('approvername')">Followup Originator</a>
       <% if (strOrderBy.equals("approvername")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>
	   <th>Followup</th>
	   <th><a href="javascript:handleOrder('isfollowupchecked')">Followup Complete</a>
       <% if (strOrderBy.equals("isfollowupchecked")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %></th>
	   </tr>

 <%
try{
    c=DBHelper.getConnection();
    st=c.createStatement();
    rs = st.executeQuery(sql);
	while (rs.next()){
	 int iLogID=rs.getInt("lgid");
	 String strOriginator_t=rs.getString("originator");
	 String strCreatorTeam_t=rs.getString("creatorteam")==null?"&nbsp;":rs.getString("creatorteam");
	 String strAreaNames_t=rs.getString("areaNames");
	 String strLineNames_t=rs.getString("lineNames");
	 String strApproverName_t=rs.getString("approverName");
	 String strApproverType_t=rs.getString("approverType");
	 String strApprovalStatus_t=rs.getString("approvalStatus");
	 boolean bHasFollowup_t=rs.getBoolean("hasFollowup");
//	 String strFollowup_t=rs.getString("followup");
     String strFollowup_t=bHasFollowup_t?"x":"&nbsp;";
//	 if (!bHasFollowup_t) strFollowup_t="-";

	 boolean bFollowupComplete_t=rs.getBoolean("isFollowupChecked");
	 String strFollowupCheckedBy_t=rs.getString("followupBywho");
     String strFollowupCheckDate_t=rs.getString("followupcheckdatestr");
	 if (!bFollowupComplete_t) strFollowupCheckedBy_t="&nbsp;";
     else
          strFollowupCheckedBy_t+=":"+strFollowupCheckDate_t;
	 %>
	 <tr><td><a href="./reviewRequest3.jsp?n=<%=iLogID%>"><%=iLogID%></a></td>
	 <td><%=strOriginator_t%></td><td><%=strAreaNames_t%></td> <%-- <td><%=strCreatorTeam_t%></td> --%> <td><%=strLineNames_t%></td><td><%=strApprovalStatus_t%></td>
	 <td><%=strApproverType_t%></td><td><%=strApproverName_t%></td><td align="center"><%=strFollowup_t%></td><td align="center"><%=strFollowupCheckedBy_t%></td>
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