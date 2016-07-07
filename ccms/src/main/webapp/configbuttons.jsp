<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Toolbar Configuration</title>
 <script  type="text/javascript">
  function doSubmit(){
	    var newValue="";
	  var obj=document.getElementById("showLabel");
	  if (obj.checked)
        newValue="Y";
	  else
        newValue="N";

	  document.getElementById("newPreferedValue").value=newValue;
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
<div class="title">Toolbar Configuration</div>

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
     String strNewValue=request.getParameter("newPreferedValue")==null?"Y":request.getParameter("newPreferedValue");
	 String strOldValue=request.getParameter("oldPreferedValue")==null?"Y":request.getParameter("oldPreferedValue");
	 boolean bPreferenceExist=request.getParameter("preferenceExist").equals("yes");
	 String sqlstr="";
	 boolean bConfirm=false;

	 if (bPreferenceExist){
			 sqlstr="update tblCMSUserPreference set preferenceValue=? where preferencetype=1001 and account=?";
			  pstmt=c.prepareStatement(sqlstr);
			  pstmt.setString(1,strNewValue);
			  pstmt.setString(2,strCurLogin);
			  pstmt.execute();
			  c.commit();
			  bConfirm=true;
		 }
		 else{

			 sqlstr="insert into tblCMSUserPreference (account,preferenceType,preferenceValue) values (?,?,?)";
			  pstmt=c.prepareStatement(sqlstr);
			  pstmt.setString(1,strCurLogin);
			  pstmt.setString(2,"1001");
			  pstmt.setString(3,strNewValue);
			  pstmt.execute();
			  c.commit();
			  bConfirm=true;
		 }
         if (bConfirm){
		 %>
              <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
	    <%
	     }
  }	 //end if action == save
 
	 	String sql="select * from tblCMSUserPreference where preferencetype='1001' and account='"+strCurLogin+"'";
		String strUserPreferedValue="N";
		String strExist="no";
		String strChecked="checked";

       st=c.createStatement();
	   rs=st.executeQuery(sql);
        if (rs.next()){
			strExist="yes";
			strUserPreferedValue=rs.getString("preferenceValue")==null?"Y":rs.getString("preferenceValue");
			strChecked=strUserPreferedValue.equals("Y")?"checked":"";
		}
		rs.close();

	   	 %>
		<div style="font-weight:bold">Button Label</div>
		<span>Show Label:</span>
		 <input type="hidden" name="oldPreferedValue" id="oldPreferedValue" value="<%=strUserPreferedValue%>">
		 <input type="checkbox" name="showLabel" id="showLabel" value="Y" onClick="document.getElementById('btnSave').disabled=false;"  <%=strChecked%> >
		 <input type="hidden" name="newPreferedValue" id="newPreferedValue" value="<%=strUserPreferedValue%>">
		<br/> 
		<br/>
		   <input type="submit" id="btnSave" name="btnSave" value="Save" disabled onclick="doSubmit();">
		   <input type="reset" id="btnCancel" name="btnCancel" value="Reset" >
		   <input type="hidden" id="pageAction" name="pageAction" value="">
		   <input type="hidden" id="preferenceExist" name="preferenceExist" value="<%=strExist%>">

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
