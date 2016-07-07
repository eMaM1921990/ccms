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
String sql="";
try{
	 c=DBHelper.getConnection();
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Followup Report</title>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
 <script language="javascript" type="text/javascript" src="datetimepicker.js"></script>

 <%@ include file="jsInc.jsp"%>
 <script type="text/javascript">
  function init(){
	var listObj=document.getElementById("areaList");
	var listHidden=document.getElementById("area");
	var hiddenValue=","+listHidden.value+",";
 
	var i=0;
 
 	for (i=0;i<areaArray.length;i++){                      //populate the area list
		var newOption = document.createElement("option");
		newOption.value=areaArray[i].id;
		newOption.text=areaArray[i].name;
		listObj.options.add(newOption);
		if (hiddenValue.indexOf(","+newOption.value+",")>-1)
			listObj.options[listObj.options.length-1].selected=true;
	}

}
function inList(aListObj, id){
	var retVal=false;
	for (var i=0;i<aListObj.options.length ;i++ )
	{
		if (aListObj.options[i].value==id)
		{
			retVal=true;
			break;
        }
	}
	return retVal;
}
  function doChange(curList, dependentList,curArray,dependentArray){
	//alert("doChange"+curList+"  "+dependentList);
	var curObj = document.getElementById(curList);
	var dObj= document.getElementById(dependentList);
	var  i;
 
        for (i= dObj.options.length;i>=0;i--){	 dObj.options[i]=null;	}
		var  cnt=0;
		 
		 for (i = 0; i < curObj.options.length; i++) {
           if(curObj.options[i].selected == true) {
			   var key=curObj.options[i].value;
			   var j;
			   for (j=0;j<dependentArray.length;j++){
				 //  if (dependentArray[j].parentID==key){
					 var strParentIDs=","+dependentArray[j].parentID+",";
					 var strKey=","+key+",";
					   if (strParentIDs.indexOf(strKey)>-1 && !inList(dObj,dependentArray[j].id) ){
                         var newOption = document.createElement('option');
		            	 newOption.value=dependentArray[j].name;
             			 newOption.text=dependentArray[j].name;
			             dObj.options.add(newOption);
			         }
		       }
		    }

		 }
	 
}
 </script>
</head>

<body onload="init()">
<div class="title">Followup Report Parameter page</div>
<form name="the_form" id="the_form" method="post" action="reportGen3.jsp" >
<table border='0'>
 
<tr>
<th align="right">Log#:</th><td><input type="text" name="logid" id="logid" value=""></td>
</tr>
<tr><td colspan="2"><hr/></td></tr>
<tr>
<th align="right">Department:</th><td><input type="hidden" id="area" name="area" value="">
  <select name="areaList" id="areaList" onchange="javascript:doChange('areaList','approverTypeList',areaArray,approverArray);">
  <option value="-999" selected></option>
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
<tr>
<th align="right">FollowUp Department:</th>
<td>
  <select name="approverTypeList" id ="approverTypeList">
  </select>
  <span style="margin-left:40px"><b>Follow Up Status:</b><select name="followupComplete" id ="followupComplete">
    <option value="all">All</option>
	<option value="complete">Complete</option>
	<option value="outstanding" selected>Outstanding</option>
  </select></span>
</td>
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
	DBHelper.closeStatement(pstmt2);
	DBHelper.closeConnection(c);
}
%>