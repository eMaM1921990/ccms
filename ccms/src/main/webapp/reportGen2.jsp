<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>

<%
  
  String strArea=request.getParameter("area")==null?"":request.getParameter("area");
  String strAreaCondition=" 1=1";
  if (!strArea.equals(""))
    strAreaCondition=" CHARINDEX(',"+strArea+",',','+log.areaID+',')>0";

  if (strArea.equals("11")){
	  strAreaCondition=" ("+strAreaCondition+" or take2site>0)";
  }
  String strCreatorTeam=request.getParameter("creatorteam")==null?"":request.getParameter("creatorteam");
  String  strCreatorTeamCondition=" 1=1";
  if (!strCreatorTeam.equals("")){
	  strCreatorTeamCondition=" creatorteam='"+strCreatorTeam+"'";
  }


  String strCreationDate1=request.getParameter("cdate1")==null?"":request.getParameter("cdate1");
  String strCreationDate2=request.getParameter("cdate2")==null?"":request.getParameter("cdate2");
  String strCreationDate1Condition=" 1=1";
  String strCreationDate2Condition=" 1=1";

  if (!strCreationDate1.equals(""))
    strCreationDate1Condition=" requestDate>=convert(datetime,'"+strCreationDate1+"',101)";
 if (!strCreationDate2.equals(""))
    strCreationDate2Condition=" requestDate<=convert(datetime,'"+strCreationDate2+"',101)";

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>report</title>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>
<body>
<div class="title">Close out/Overdue/On hold Report</div>
<form>

<%
  Connection c=null;
  Statement st=null;
  Statement st2=null;
  ResultSet rs =null;
  ResultSet rs2=null;


  String sqlTotal="select count(*) totalRequest  from tblChangeControlLog log where (log.hidden is null or log.hidden<>'Y')";
  sqlTotal+= " and "+strAreaCondition;
  sqlTotal+= " and "+strCreatorTeamCondition;
  sqlTotal+= " and "+strCreationDate1Condition;
  sqlTotal+= " and "+strCreationDate2Condition;

  //out.println(sqlTotal);

  String sqlGrpBy = "select logid, (case when appr.approvalStatus='Approved' and log.endTiming<dateadd(day,-1,getDate()) then 'Overdue' else appr.approvalStatus end) apprStatus from tblChangeControlLog log,tblApprovalStatus appr where (log.hidden is null or log.hidden<>'Y') and log.approvalstatusid=appr.approvalstatusid";
  sqlGrpBy+= " and "+strAreaCondition;
  sqlGrpBy+= " and "+strCreatorTeamCondition;
  sqlGrpBy+= " and "+strCreationDate1Condition;
  sqlGrpBy+= " and "+strCreationDate2Condition;
  sqlGrpBy="select count(*) as subTotal,apprstatus from ("+sqlGrpBy+") as X";
  sqlGrpBy+=" group by X.apprStatus";
   
  int total=0;
  int validTotal=0;
  int openTotal=0;

  int others=0;
  int onhold=0,closeout=0,overdue=0;
  try {
    c=DBHelper.getConnection();
    st=c.createStatement();


    rs = st.executeQuery(sqlTotal);
	if (rs.next())
         total=rs.getInt("totalRequest");
	rs.close();

	rs=st.executeQuery(sqlGrpBy);
	%>
    <h3 style="background-color:#EEEEEE">Close out/Overdue/On Hold Report</h3>
	<p>Total Request:<%=total%></p>
	<table border='1'>
	<tr><th>Status</th><th>Total</th><th>%</th><th style="width:200px;background-color:#0000ff"></th></tr>
	<%
	while (rs.next()){
        int subTotal=rs.getInt("subTotal");
		String strApprStatus=rs.getString("apprStatus");
		int w= 0;
		if (total!=0)
			w=(int)((double)200/(total)*subTotal);
		
		%>
		<tr><td><%=strApprStatus%></td><td><%=subTotal%></td>
		   <td><% if (total!=0)
			       out.print(new DecimalFormat("0.00").format((double)subTotal/total*100));
		          else
					  out.print("-");
			   %></td>
			<td><span style="width:<%=w%>px; background-color:#0000ff"></span></td>
	    </tr>
		<%
	}
  
    rs.close();
	%>
	</table>
	
	<%
  String validCondition=" approvalStatus not in ('Cancelled','Rejected')";
  String openCondition=" approvalStatus not in ('Cancelled','Rejected','Complete')";

  String sqlValidTotal="select  count(*) validTotal  from tblChangeControlLog log,tblApprovalStatus appr where (log.hidden is null or log.hidden<>'Y') and log.approvalstatusid=appr.approvalstatusid";
  sqlValidTotal+= " and "+strAreaCondition;
  sqlValidTotal+= " and "+strCreatorTeamCondition;
  sqlValidTotal+= " and "+strCreationDate1Condition;
  sqlValidTotal+= " and "+strCreationDate2Condition;
  sqlValidTotal+= " and "+validCondition;

 String sqlOpenTotal="select  count(*) openTotal from tblChangeControlLog log,tblApprovalStatus appr where (log.hidden is null or log.hidden<>'Y') and log.approvalstatusid=appr.approvalstatusid";
  sqlOpenTotal+= " and "+strAreaCondition;
  sqlOpenTotal+= " and "+strCreatorTeamCondition;
  sqlOpenTotal+= " and "+strCreationDate1Condition;
  sqlOpenTotal+= " and "+strCreationDate2Condition;
  sqlOpenTotal+= " and "+openCondition;

  String sqlOnHold="select  count(*) onhold  from tblChangeControlLog log,tblApprovalStatus appr where (log.hidden is null or log.hidden<>'Y') and log.approvalstatusid=appr.approvalstatusid and appr.approvalStatus='On Hold'";
  sqlOnHold+= " and "+strAreaCondition;
  sqlOnHold+= " and "+strCreatorTeamCondition;
  sqlOnHold+= " and "+strCreationDate1Condition;
  sqlOnHold+= " and "+strCreationDate2Condition;
  
  String sqlOverdue="select  count(*) overdue  from tblChangeControlLog log,tblApprovalStatus appr where (log.hidden is null or log.hidden<>'Y') and log.approvalstatusid=appr.approvalstatusid and appr.approvalStatus in('Approved','Overdue') and endtiming<dateadd(day,-1,getDate())";
  sqlOverdue+= " and "+strAreaCondition;
  sqlOverdue+= " and "+strCreatorTeamCondition;
  sqlOverdue+= " and "+strCreationDate1Condition;
  sqlOverdue+= " and "+strCreationDate2Condition;

  String sqlCloseout="select  count(*) closeout  from tblChangeControlLog log,tblApprovalStatus appr where (log.hidden is null or log.hidden<>'Y') and log.approvalstatusid=appr.approvalstatusid and appr.approvalStatus='Complete'";
  sqlCloseout+= " and "+strAreaCondition;
  sqlCloseout+= " and "+strCreatorTeamCondition;
  sqlCloseout+= " and "+strCreationDate1Condition;
  sqlCloseout+= " and "+strCreationDate2Condition;


    rs = st.executeQuery(sqlValidTotal);
    if (rs.next()) 
		validTotal=rs.getInt("validTotal");
	rs.close();

    rs = st.executeQuery(sqlOpenTotal);
    if (rs.next()) 
		openTotal=rs.getInt("openTotal");
	rs.close();


    rs = st.executeQuery(sqlOnHold);
    if (rs.next()) 
		onhold=rs.getInt("onhold");
    rs.close();

	rs = st.executeQuery(sqlOverdue);
    if (rs.next()) 
		overdue=rs.getInt("overdue");
    rs.close();

     rs = st.executeQuery(sqlCloseout);
    if (rs.next()) 
		closeout=rs.getInt("closeout");

     rs.close();
    // others=total-onhold-overdue-closeout;

    double closeoutPerc=0;
    double overduePerc=0;
    double onholdPerc=0;
	String strCloseoutPerc="";
    String strOverduePerc="";
    String strOnholdPerc="";
	DecimalFormat df = new DecimalFormat("0.00");

    if (openTotal!=0){
		overduePerc=(double)overdue/openTotal*100;
		strOverduePerc=df.format(overduePerc);
	}
	if (validTotal!=0){
		closeoutPerc=(double)closeout/validTotal*100;
		onholdPerc=(double)onhold/validTotal*100;
	
        strCloseoutPerc = df.format(closeoutPerc);
		strOnholdPerc=df.format(onholdPerc);

	}
		%>
		<br/>
		<br/>
		<hr  style="text-align:left;width:400px"/>
		<p> Total Valid Requests(Exclude Reject, Cancelled):<%=validTotal%></p>
	    <p> Total Open Requests(Exclude Reject Cancelled, Complete):<%=openTotal%></p>
	<table border='1' cellpadding='4' cellspacing='0'>
     <tr><th>Close Out</th><th>OverDue</th><th>On Hold</th></tr>
	  <tr>
		 <td><%=closeout%>/<%=validTotal%></td><td><%=overdue%>/<%=openTotal%></td>
		 <td><%=onhold%>/<%=validTotal%></td>
		</tr>
        <tr>
		 <td><%=strCloseoutPerc%>%</td><td><%=strOverduePerc%>%</td>
		 <td><%=strOnholdPerc%>%</td>
		</tr>

	</table>
	<!--
	<img src="drawPie.jsp?total=<%=total%>&q=Closeout,00ff00,<%=closeout%>|Overdue,ff0000,<%=overdue%>|Onhold,0000ff,<%=onhold%>|Others,aaaaaa,<%=others%>" alt="Graph">
	-->
	<%
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