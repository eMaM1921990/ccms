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
<div class="title"> General Report Parameter page</div>
<form name="the_form" id="the_form" method="GET" action="reportGen.jsp" >
<table border='0'>
<tr><td>Log#:</td>
<td><input type="text" name="logid" id="logid" value=""></td>
</tr>
<tr><td colspan="2"><hr/></td></tr>
<tr><td>Emergency:</td><td><select name="emergency" id="emergency">
                           <option value=""></option>
                           <option value="Y">Yes</option>
                           <option value="N">No</option>
                           </select>
                      </td></tr>
<tr><td>Safety:</td><td><select name="safety" id="safety" value="Y">
                           <option value=""></option>
                           <option value="Y">Yes</option>
                           <option value="N">No</option>
                           </select>

                     </td></tr>
<tr><td colspan="2"><hr/></td></tr>
<tr><td>Originator:</td>
<td><input type="text" name="originator" id="originator" value="">
    <select name="originatorList" id="originatorList" onchange="document.getElementById('originator').value=this.options[selectedIndex].value;">
	<option value="">All</option>
	<%
     sql="select distinct originator from tblChangeControlLog order by originator";
     rs=st.executeQuery(sql);
     while (rs.next()){
     %>
       <option value="<%=rs.getString("originator")%>"><%=rs.getString("originator")%></option>
   <%
     }
    rs.close();
  %>
 </select>
</td>
</tr>
<tr><td style="visibility: hidden;">Team:</td><td> 
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
<tr><td colspan="2"><hr/></td></tr>
<tr>
<td>Department:</td><td><input type="hidden" id="area" name="area" value="">
  <select name="areaList" id="areaList" onchange="document.getElementById('area').value=this.options[selectedIndex].value;">
   <option value=""></option>
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
<tr>
<tr><td colspan="2"><hr/></td></tr>
<td>Status:</td>
<td>
    <input type="hidden" id="statusName" name="statusName" value="">
<select name="status" id="status" onchange="document.getElementById('statusName').value=this.options[selectedIndex].text;">
<option value=""></option>
 <%
 sql = "select * from tblApprovalStatus";
 rs = st.executeQuery(sql);
 while (rs.next()){
    int iID=rs.getInt("approvalStatusID");
    String strApprovalStatusTemp = rs.getString("approvalStatus");
  %>
    <option value="<%=iID%>"><%=strApprovalStatusTemp%></option>
  <%
  }
  rs.close();
  %>
  </select></td>
</tr>
<tr><td colspan="2"><hr/></td></tr>
<tr><td>Equipment:</td>
<td><input type="hidden" name="equipment" id="equipment" value=""> <select name="equipmentList" id="equipmentList" onchange="document.getElementById('equipment').value=this.options[selectedIndex].value;">
<option value=""></option>
  <%
   sql="select equipmentid,equipmentname from tblEquipment order by equipmentname";
   rs=st.executeQuery(sql);
   while (rs.next()){
	 int iID=rs.getInt("equipmentid");
	 String strEquipmentName=rs.getString("equipmentname");
  %>
  <option value="<%=iID%>"><%=strEquipmentName%></option>
  <%
   }
   rs.close();
  %>
 </select></td>
</tr>
<tr><td colspan="2"><hr/></td></tr>

<tr><td>Creation Date:</td>
<td>From:<input name="cdate1" id="cdate1" value=""><a href="javascript:NewCal('cdate1','mm/dd/yyyy' )"><img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a> 
To:<input name="cdate2" id="cdate2" value=""><a href="javascript:NewCal('cdate2','mm/dd/yyyy' )"><img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td>
</tr>

<tr><td>Start of construction Date:</td>
<td>From:<input name="sdate1" id="sdate1" value=""><a href="javascript:NewCal('sdate1','mm/dd/yyyy' )"><img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a> 
To:<input name="sdate2" id="sdate2" value=""><a href="javascript:NewCal('sdate2','mm/dd/yyyy' )"><img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td>
</tr>
<tr><td>Project startup Date:</td>
<td>From:<input name="edate1" id="edate1" value=""><a href="javascript:NewCal('edate1','mm/dd/yyyy' )"><img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a> 
To:<input name="edate2" id="edate2" value=""><a href="javascript:NewCal('edate2','mm/dd/yyyy' )"><img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a></td>
</tr>
<tr><td colspan="2"><hr/></td></tr>
<tr><td>Order by:</td>
     <td><select id="orderby" name="orderby">
       <option value="logid">Log#</option>
	   <option value="requestDate">Request Date</option>
       <option value="areaNames">Department</option>
       <option value="originator">Originator</option>	   
       <option value="costType">CostType</option>	   
       <option value="isSafety">Is EO/Chemical Clearance</option>	   
       <option value="isEmergency">Is Emergency</option>	   
	   </select>
	   <input type="radio" name="sort" id="sort" value="asc" checked="checked">Asc
   	   <input type="radio" name="sort" id="sort" value="desc">Desc
     </td>
</tr>
<tr><td colspan="2"><hr/></td></tr>
<tr><td>Export Format:</td>
     <td><select id="format" name="format">
       <option value="HTML">HTML</option>
	   <option value="EXCEL">Excel</option>
       <option value="WORD">Word</option>
	   </select>
     </td>
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