<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%@include file="inc.jsp" %>
<%@page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>System Administrator Setup</title>
 <script  type="text/javascript">
  var totalArea=-1;

 function handle_cancel(){
	 var oldObj, newObj;
	 var j;
  for (j = 0 ; j < totalArea ; j++){
	  
	   oldObj = document.getElementById("oldOwnerName"+j);
  	   newObj = document.getElementById("newOwnerName"+j);
       newObj.value = oldObj.value;

       oldObj = document.getElementById("oldOwnerAcct"+j);
  	   newObj = document.getElementById("newOwnerAcct"+j);
       newObj.value = oldObj.value;

       oldObj = document.getElementById("oldOwnerEmail"+j);
  	   newObj = document.getElementById("newOwnerEmail"+j);
       newObj.value = oldObj.value;
   }
	  
 }

 </script>
   <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>

<%
 
if (!bIsSysadmin){
	 out.println("You don't have permission to use this function!");
	 return;
}

int totalBlank = Integer.parseInt(request.getParameter("totalBlank") == null ? "3" : request.getParameter("totalBlank"));
String strShowHidden = request.getParameter("showhidden") == null ? "N" : request.getParameter("showhidden");
boolean bShowHidden = strShowHidden.equals("y") || strShowHidden.equals("yes");

%>
<div><a href="settings.jsp">Settings</a> &gt; System Administrator Setup</div>
<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">System Administrator Setup</div>

<form name="the_form" id="the_form" method="post" action="#" >


<%

Connection c = null;
Statement st = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
boolean bConfirm = false;
try {
	c = DBHelper.getConnection();
	  if (request.getParameter("btnSave") != null) { //clicked the save button
		  int iTotal=Integer.parseInt(request.getParameter("total") == null ? "0" : request.getParameter("total"));
		  for (int i = 0 ; i < iTotal ; i++) {
			  String oldAccount = request.getParameter("oldAccount" + i) == null ? "" : request.getParameter("oldAccount" + i);
	          String newAccount = request.getParameter("newAccount" + i) == null ? "" : request.getParameter("newAccount" + i);
	          
	          String oldEmail = request.getParameter("oldEmail" + i) == null ? "" : request.getParameter("oldEmail" + i);
	          String newEmail = request.getParameter("newEmail" + i) == null ? "" : request.getParameter("newEmail" + i);
	          
	          if(oldAccount == null || "".equals(oldAccount) || newAccount == null || "".equals(newAccount))
	        	  continue;
	          
	          boolean deleteUser = "Y".equals(request.getParameter("deleteUser" + i)); // == null ? false : request.getParameter("newEmail" + i);
	          
	          if(deleteUser) {
	        	  pstmt = c.prepareStatement("update tblCMSUser set type='user' where account=?");
                  pstmt.setString(1, oldAccount);
                  pstmt.execute();
                  pstmt.close();
                  
                  bConfirm = true;
	        	  continue;
	          }
	          
			  if(!oldAccount.equals(newAccount)) {
				  // set old to normal
				  pstmt = c.prepareStatement("update tblCMSUser set type='user' where account=?");
				  pstmt.setString(1, oldAccount);
				  pstmt.execute();
				  pstmt.close();
				  
				  bConfirm = true;
				  
				  // set new to sysadmin
				  // if exists -> update, else insert
				  boolean existing = false;
				  pstmt = c.prepareStatement("select * from tblCMSUser where account=?");
				  pstmt.setString(1, newAccount);
				  rs = pstmt.executeQuery();
				  if(rs.next())
					  existing = true;
				  rs.close();
				  pstmt.close();
				  
				  if(existing) {
					  pstmt = c.prepareStatement("update tblCMSUser set type='SYSADMIN' where account=?");
					  pstmt.setString(1, newAccount);
					  pstmt.execute();
					  pstmt.close();
				  } else {
					  pstmt = c.prepareStatement("insert into tblCMSUser(account, email, type, active, allowAccess) values(?,?,?,'Y','Y')");
	                  pstmt.setString(1, newAccount);
	                  pstmt.setString(2, newEmail);
	                  pstmt.setString(3, "SYSADMIN");
	                  pstmt.execute();
	                  pstmt.close();
				  }
				  
				  String  strSubject = "CMS Role";
	              String strMsg="Hello, <br/>";
	              strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
	              
	              strMsg += " Your account at Change Management System has been added/modified as a System Administrator</b><br/>";
	              strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
	              
	              
	              MailSender.sendEMail(newEmail, strSubject, strMsg);
			  }
	   }
	  
	  for(int i = 0 ; i < totalBlank ; i++) {
		  String newAcct = request.getParameter("addAccount" + i) == null ? "" : request.getParameter("addAccount" + i).trim();
          String newEmail= request.getParameter("addEmail" + i) == null ? "" : request.getParameter("addEmail" + i).trim();
          
          if("".equals(newAcct) || "".equals(newEmail))
        	  continue;
          
          boolean existing = false;
          pstmt = c.prepareStatement("select * from tblCMSUser where account=?");
          pstmt.setString(1, newAcct);
          rs = pstmt.executeQuery();
          if(rs.next())
              existing = true;
          rs.close();
          pstmt.close();
          
          if(existing) {
              pstmt = c.prepareStatement("update tblCMSUser set type='SYSADMIN' where account=?");
              pstmt.setString(1, newAcct);
              pstmt.execute();
              pstmt.close();
              bConfirm = true;
          } else {
        	  System.out.println("Inserting new user: " + newAcct);
              pstmt = c.prepareStatement("insert into tblCMSUser(account, email, type, active, allowAccess) values(?,?,?,'Y','Y')");
              pstmt.setString(1, newAcct);
              pstmt.setString(2, newEmail);
              pstmt.setString(3, "SYSADMIN");
              pstmt.execute();
              pstmt.close();
              bConfirm = true;
          }
          
          String  strSubject = "CMS Role";
          String strMsg="Hello, <br/>";
          strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
          
          strMsg += " Your account at Change Management System has been added as a System Administrator</b><br/>";
          strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
          
          
          MailSender.sendEMail(newEmail, strSubject, strMsg);
	  }
	  c.commit();
     %>
	  <% if (bConfirm){ %>
	   <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa">
	       <img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.
	   </div>
      <%}%>
 <%
  }
       String sql="select * from tblCMSUser where type like 'SYSADMIN'";
	   if (!bShowHidden)
		   sql+=" and  active <> 'N'";
	   sql+=" order by account";

       st = c.createStatement();
	   rs = st.executeQuery(sql);
	   int i = 0;
       %>
	   <table cellspacing="2" border='0'>
	   <tr><th>Delete</th><th>Account</th><th>Email.</th></tr>
	   <%
	   while (rs.next()){
		   String strAccount = rs.getString("account");
		   String strEmail = rs.getString("email");
		   String disabled = strCurLogin.equals(strAccount) ? "disabled" : "";
		   String strClass = "evenRow";
           if (i%2 == 0)
            strClass = "evenRow";
    	   else
	    	   strClass = "oddRow";
	     %>

            <tr class="<%=strClass%>" style="height:40px;">
			 	<td> 
			 	   <input type="checkbox" name="deleteUser<%=i%>" id="deleteUser<%=i%>" value="Y" <%=disabled%>>
				</td>
				<td>
				    <input type="hidden" name="oldAccount<%=i%>" id="oldAccount<%=i%>" value="<%=strAccount%>">
				    <input type="text" style="width:120px" id="newAccount<%=i%>"  name="newAccount<%=i%>" value="<%=strAccount%>" <%=disabled%>> 
				</td>
				<td>
				    <input type="hidden" name="oldEmail<%=i%>" id="oldEmail<%=i%>" value="<%=strEmail%>">
				    <input type="text" style="width:250px" id="newEmail<%=i%>"  name="newEmail<%=i%>" value="<%=strEmail%>" <%=disabled%>> 
				</td>
			</tr>
		   <%
			   i++;
	   }
		   %>

		   <% for (int j = 0 ; j < totalBlank ; j++){  %>

              <tr  class="newRow" style="height:40px">
                <td style="color:#ff0000" align="center">+</td>
		        <td><input style="width:120px" type="text" name="addAccount<%=j%>" id="addAccount<%=j%>" value=""></td>
		        <td><input style="width:250px" type="text" name="addEmail<%=j%>" id="addEmail<%=j%>" value=""></td>
		      </tr>
            <%}%>
		   </table>

     	   <input type="hidden" name="totalBlank" id="totalBlank" value="<%=totalBlank%>">
		   <input type="submit" id="btnSave" name="btnSave" value="Save">
		   <input type="reset" id="btnCancel" name="btnCancel" value="Reset" >
		   <input type="hidden" id="total" name="total" value="<%=i%>">
		   <script  type="text/javascript">
			    totalArea = <%=i%>;
		   </script>
  <%
}catch (Exception e){
	out.println(e);
	if (c!=null) c.rollback();
}
finally{
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeConnection(c);
}
%>

</form>
</body>
</html>
