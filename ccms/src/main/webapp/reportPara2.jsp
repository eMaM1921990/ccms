<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>

<%
Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;
String sql="select areaid, areaname from tblarea where hidden<>'Y'";
try{
  c=DBHelper.getConnection();
  st=c.createStatement();
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Report</title>
<link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
 <script language="javascript" type="text/javascript" src="datetimepicker.js"></script>
</head>
<body>
<div class="title">Close out/Overdue/On hold Report Parameter page</div>
<form name="the_form" id="the_form" method="GET" action="reportGen2.jsp" >
<table border='0'>
 
<tr>
<th align="right">Department:</th><td><input type="hidden" id="area" name="area" value="">
  <select name="areaList" id="areaList" onchange="document.getElementById('area').value=this.options[selectedIndex].value;">
   <option value="">All</option>
  <%
  sql="select areaid, areaname from tblarea where hidden<>'Y'";
  rs=st.executeQuery(sql);
  while (rs.next()){
  %>
       <option value="<%=rs.getInt("areaid")%>"><%=rs.getString("areaname")%></option>
  <%
  }
  rs.close();
  %>
</select></td>
</tr>
<tr style="visibility: hidden;">
<th align="right">Team:</th><td> 
      <select name="creatorteam" id="creatorteam">
	   <option value=""></option>
	  <%
	     sql="select * from tblCreatorTeam where (hidden<>'Y' or hidden is null) order by teamname";
         rs = st.executeQuery(sql);
       	while(rs.next()){
		  String strCreatorTeam_t=rs.getString("teamname")==null?"":rs.getString("teamname");
       %>
        <option value="<%=strCreatorTeam_t%>"><%=strCreatorTeam_t%></option>
		<%
		}
		 %>

       </select></td>
</tr>
<tr><td colspan="2"><hr/></td></tr>
<tr valign="top"><th align="right">Creation Date:</th>
<td><span  style="width:50px;text-align:right">From:</span>
    <input name="cdate1" id="cdate1" value="">
	  <a href="javascript:NewCal('cdate1','mm/dd/yyyy' )">
	      <img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a> <br/>
     <span  style="width:50px;text-align:right">To:</span>
	 <input name="cdate2" id="cdate2" value="">
	 <a href="javascript:NewCal('cdate2','mm/dd/yyyy' )">
	 <img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td>
</tr>

<tr><td colspan="2"><hr/></td></tr>

<tr><td></td><td><input type="submit" id="btnSubmit" name="btnSubmit" value="Run"><input type="reset" id="btnReset" name="btnReset" value="Reset"></td></tr>

</table>

</form>

</body>
</html>
<%
}catch(Exception e){
	out.println(e);
}
finally{
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeStatement(pstmt);
	DBHelper.closeConnection(c);
}
%>