<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Area Setup</title>
 <script  type="text/javascript">
  var totalArea=-1;

 function handle_cancel(){
	 var oldObj, newObj;
	 var j;
  for (j=0;j<totalArea;j++){
	  
	   oldObj=document.getElementById("oldOwnerName"+j);
  	   newObj=document.getElementById("newOwnerName"+j);
       newObj.value=oldObj.value;

       oldObj=document.getElementById("oldOwnerAcct"+j);
  	   newObj=document.getElementById("newOwnerAcct"+j);
       newObj.value=oldObj.value;

       oldObj=document.getElementById("oldOwnerEmail"+j);
  	   newObj=document.getElementById("newOwnerEmail"+j);
       newObj.value=oldObj.value;
   }
	  
 }

 </script>
   <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
<div style="width:500px;height:40px;background:#EEEEEE;"><h3>Department &amp; Owner Setup</h3></div>

<%
 
if (!bIsLoginOwner&& !bIsSysadmin){
	 out.println("You don't have permission to use this function!");
	 return;
}

int totalBlank=Integer.parseInt(request.getParameter("totalBlank")==null?"3":request.getParameter("totalBlank"));

%>

<form name="the_form" id="the_form" method="post" action="#" >


<%

Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;
try{
  c=DBHelper.getConnection();
  if (request.getParameter("btnSave")!=null){ //clicked the save button
      int iTotal=Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
	  String oldCatName="";
	  String newCatName="";
	  

	  int key=-999;
	  boolean bUpdated=false;
	  boolean bNewRow=false;
	  boolean bConfirm=false;
	  boolean bDeleted=false;

	  String sqlUpdate="update tblsitelistsubcategory set subcatname=?, hidden=? where subcatID=?";
       pstmt=c.prepareStatement(sqlUpdate);
    
	  for (int i=0;i<iTotal;i++){
		  bUpdated=false;
		   key=Integer.parseInt(request.getParameter("subcatID"+i)==null?"-9999":request.getParameter("subcatID"+i));
           bDeleted=request.getParameter("delete"+i)==null?false:request.getParameter("delete"+i).equals("Y");

           oldCatName = request.getParameter("oldCatName"+i)==null?"":request.getParameter("oldCatName"+i);
		   newCatName= request.getParameter("newCatName"+i)==null?"":request.getParameter("newCatName"+i);


		    if (!oldCatName.equals(newCatName)) 
			   bUpdated=true;

			if (bUpdated||bDeleted){
				 pstmt.setString(1, bDeleted?oldCatName:newCatName);
				 pstmt.setString(2,bDeleted?"Y":"N");
                 pstmt.setInt(3, key);
	 		     pstmt.execute();
			}
			bConfirm=bConfirm||bUpdated||bDeleted;
	  }

      pstmt.close();

	  String sqlInsert="insert into tblsitelistsubcategory(subcatname,hidden) values(?,?)";
      pstmt=c.prepareStatement(sqlInsert);

		  for(int i=0;i<totalBlank;i++){
		    bNewRow=false;
			newCatName= request.getParameter("addCatName"+i)==null?"":request.getParameter("addCatName"+i).trim();
   	      
		    if (newCatName.length()>0){
			    bNewRow=true;
                pstmt.setString(1,newCatName);
				pstmt.setString(2,"N");
				pstmt.execute();
			}
           bConfirm=bConfirm||bNewRow;
		  }
		  
	  c.commit();
     %>
	  <% if (bConfirm){  %>
                <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
		<%}%>
 <%
  }


       String sql="select * from tblsitelistsubcategory subcat where subcat.hidden<>'Y' order by subcatID";
       st=c.createStatement();
	   rs=st.executeQuery(sql);
	   int i=0;
       %>
	   <table cellspacing="2" border='0'>
	   <tr><th>Del.</th><th>SubCategory</th></tr>
	   <%
	   while (rs.next()){
		   int iID=rs.getInt("subcatID");
		   String strSubCatName=rs.getString("subcatName");

		   String strClass="evenRow";
           if (i%2==0)
            strClass="evenRow";
    	   else
	    	   strClass="oddRow";
	     %>
		   
            <tr class="<%=strClass%>" style="height:30px;">
			 	<td> <input type="checkbox" name="delete<%=i%>" id="delete<%=i%>" value="Y"></td>
			    <td><input type="hidden" name="subcatID<%=i%>" id="subcatID<%=i%>"  value=<%=iID%>>
              		 <input type="hidden" name="oldCatName<%=i%>" id="oldCatName<%=i%>" value="<%=strSubCatName%>">
               		 <input title="<%=strSubCatName%>" style="width:300px" type="text" name="newCatName<%=i%>" id="newCatName<%=i%>" value="<%=strSubCatName%>">
			    </td>
			</tr>
		   <%
			   i++;
	   }
		   %>

		   <% for (int j=0;j<totalBlank;j++){  %>

              <tr  class="newRow" style="height:30px">
                <td style="color:#ff0000" align="center">+</td>
                <td><input type="text" name="addCatName<%=j%>" id="addCatName<%=j%>" value="">  </td>
		      </tr>
            <%}%>
		   </table>

     	   <input type="hidden" name="totalBlank" id="totalBlank" value="<%=totalBlank%>">
		   <input type="submit" id="btnSave" name="btnSave" value="Save">
		   <input type="reset" id="btnCancel" name="btnCancel" value="Reset" >
		   <input type="hidden" id="total" name="total" value="<%=i%>">
		   <script  type="text/javascript">
			    totalArea=<%=i%>;
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
	DBHelper.closeStatement(pstmt2);
	DBHelper.closeConnection(c);
}
%>

</form>
</body>
</html>
