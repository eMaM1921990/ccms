<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>My Selection Setup</title>
 <script  type="text/javascript">
  var totalAreas=-1;
  function doSubmit(){
	    var newValue="";
	  for (var i=0;i<totalAreas;i++){
		  var obj=document.getElementById("area_"+i);
		  var selectedAreaId=obj.value;
		  var bChecked=obj.checked;
		  if (bChecked){
      		  newValue=newValue+","+selectedAreaId;
		  }
	  }
	  if (newValue!=""){
		  newValue=newValue.substring(1);
	  }
	  document.getElementById("newPreferedArea").value=newValue;
	  document.getElementById("pageAction").value="save";
	  document.getElementById("btnSave").value="submitting...";
      document.getElementById("btnSave").disabled =true;
	  document.the_form.submit();
    	  return false;
  }
  </script>
   <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
<%
String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");

%>
<div class="title">My Selection Setup</div>

<form name="the_form" id="the_form" method="post" action="#" >

<%

Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;
try{
  c=DBHelper.getConnection();
  if (strPageAction.equals("save")){ //click the save button
     String strNewAreas=request.getParameter("newPreferedArea")==null?"":request.getParameter("newPreferedArea");
	 String strOldAreas=request.getParameter("oldPreferedArea")==null?"":request.getParameter("oldPreferedArea");
	 boolean bPreferenceExist=request.getParameter("preferenceExist").equals("yes");
	 String sqlstr="";
	 boolean bConfirm=false;
	 if (!strNewAreas.equals(strOldAreas)) {
		 if (bPreferenceExist){
			 sqlstr="update tblCMSUserPreference set preferenceValue=? where preferencetype=1 and account=?";
			  pstmt=c.prepareStatement(sqlstr);
			  pstmt.setString(1,strNewAreas);
			  pstmt.setString(2,strCurLogin);
			  pstmt.execute();
			  c.commit();
			  bConfirm=true;
		 }
		 else{
			 sqlstr="insert into tblCMSUserPreference (account,preferenceType,preferenceValue) values (?,?,?)";
			  pstmt=c.prepareStatement(sqlstr);
			  pstmt.setString(1,strCurLogin);
			  pstmt.setString(2,"1");
			  pstmt.setString(3,strNewAreas);
			  pstmt.execute();
			  c.commit();
			  bConfirm=true;
		 }
         if (bConfirm){
		 %>
              <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
	    <%
	     }
	 }
  }	 
	 //end if action == save


	 	String sql="select * from tblCMSUserPreference where preferencetype='1' and account='"+strCurLogin+"'";
		String strUserPreferedArea=null;
		String strExist="no";

       st=c.createStatement();
	   rs=st.executeQuery(sql);
        if (rs.next()){
			strExist="yes";
			strUserPreferedArea=rs.getString("preferenceValue")==null?"":rs.getString("preferenceValue");
		}
		rs.close();

        sql="select * from tblArea  where hidden <>'Y' or hidden is null order by areaname";
 	   rs=st.executeQuery(sql);
 	   int i=0;
	   String strRowClass="oddRow";

	   	 %>
		<div style="font-weight:bold">I prefer to see requests from department(s):</div>
		<input type="hidden" name="oldPreferedArea" id="oldPreferedArea" value="<%=strUserPreferedArea%>">
		<input type="hidden" name="newPreferedArea" id="newPreferedArea" value="<%=strUserPreferedArea%>">
		<table  border="0">
		<%
       while (rs.next()){
		   String strAreaID=rs.getString("areaid");
   		   String strAreaName=rs.getString("areaname");
		   String strAreaAbbr=rs.getString("abbr");
 	       strRowClass=i%2==0?"evenRow":"oddRow";
		   boolean bChecked=(","+strUserPreferedArea+",").indexOf(","+strAreaID+",")>-1;
		   String strChecked=bChecked?"checked":"";
			%>
			<tr class="<%=strRowClass%>">
			 <td>
			     <input type="checkbox" name="area_<%=i%>" id="area_<%=i%>" value="<%=strAreaID%>" <%=strChecked%> onclick="document.getElementById('btnSave').disabled=false;">
			 </td>
			 <td>
			  <span><%=strAreaName%></span>
			 </td>
			</tr>
		  <%
				i++;
		 }
	   rs.close();
	   st.close();
       int totalAreas=i;

			%>

		</table>

		   <input type="submit" id="btnSave" name="btnSave" value="Save" disabled onclick="doSubmit();">
		   <input type="reset" id="btnCancel" name="btnCancel" value="Reset" >
		   <input type="hidden" id="pageAction" name="pageAction" value="">
		   <input type="hidden" id="preferenceExist" name="preferenceExist" value="<%=strExist%>">
		   <input type="hidden" id="totalArea" name="totalArea" value="<%=totalAreas%>">
		   <script  type="text/javascript">
		        totalAreas=<%=totalAreas%>;
		   </script>
		   <%
   
}catch (Exception e){
	out.println(e);
	if (c!=null) c.rollback();
}
finally{
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeStatement(pstmt);
	DBHelper.closeConnection(c);
}
%>

</form>
</body>
</html>
