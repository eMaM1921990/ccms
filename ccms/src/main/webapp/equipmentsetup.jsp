<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="java.util.ArrayList"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Equipment Setup</title>
 <script  type="text/javascript">
  var totalAreas=-1;
  var totalEquipment=-1;

  function resetArea(eSeq){  //a is the equip sequence number for 0 to totalEqupment
 
      var newAreaObj= document.getElementById("newAreaId_"+eSeq);
 
	 var newAreaValue="";
	 
	 for (var i=0;i<totalAreas;i++){
		 var objId="areaBox_"+eSeq+"_"+i;
	     var obj=document.getElementById(objId);
 	     if (obj.checked) newAreaValue+=obj.value+",";
	 }
	 
	 if (newAreaValue.length>0){
		 newAreaValue=newAreaValue.substring(0,newAreaValue.length-1);
         newAreaObj.value=newAreaValue;
	 } 
  }
 </script>
   <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
<%
 
if (!bIsLoginOwner && !bIsSysadmin){
	 out.println("You don't have permission to use this function!");
	 return;
}
%>
<div><a href="settings.jsp">Settings</a> > Equipment Setup</div>
<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">Equipment Setup</div>

<form name="the_form" id="the_form" method="post" action="#" >

<%

Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;
try{
  c=DBHelper.getConnection();
  if (request.getParameter("btnSave")!=null){ //click the save button
      int iTotal=Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
	  int iTotalArea=Integer.parseInt(request.getParameter("totalArea")==null?"0":request.getParameter("totalArea"));
	  boolean bDeleted=false;
	  boolean bNewRow=false;
	  boolean bConfirm=false;
	  String oldEquipmentName="";
	  String newEquipmentName="";
	  String oldAreaIds="";
	  String newAreaIds="";
  	  
	  int key=-999;
	  boolean bUpdated=false;
	  String sqlUpdate="update tblEquipment set equipmentName=?,hidden=?,areaid=?, lineid=? where equipmentId=?";
	  String sqlInsert="insert into tblEquipment(equipmentName, hidden,areaid,lineid) values(?,?,?,?)";
      pstmt=c.prepareStatement(sqlUpdate);
	   

	  for (int i=0;i<iTotal;i++){
		   bUpdated=false;
		   key=Integer.parseInt(request.getParameter("equipmentId"+i)==null?"-9999":request.getParameter("equipmentId"+i));

		   bDeleted=request.getParameter("delete"+i)==null?false:request.getParameter("delete"+i).equals("Y");

		   oldEquipmentName = request.getParameter("oldName"+i)==null?"":request.getParameter("oldName"+i);
		   newEquipmentName = request.getParameter("newName"+i)==null?"":request.getParameter("newName"+i);
		   if (!oldEquipmentName.equals(newEquipmentName)) 
			   bUpdated=true;
           
		   oldAreaIds = request.getParameter("oldAreaId_"+i)==null?"":request.getParameter("oldAreaId_"+i);
		   newAreaIds = request.getParameter("newAreaId_"+i)==null?"":request.getParameter("newAreaId_"+i);
		   if (!oldAreaIds.equals(newAreaIds)) 
			   bUpdated=true;
           //System.out.println("equipment"+i+"  Updated:"+bUpdated);
           if (bUpdated||bDeleted){
              pstmt.setString(1, bDeleted?oldEquipmentName:newEquipmentName);
   			  pstmt.setString(2, bDeleted?"Y":"N");
			  pstmt.setString(3, bDeleted? oldAreaIds:newAreaIds);
			  pstmt.setString(4,"");
              pstmt.setInt(5, key);

//			  pstmt.setInt(7,iAreaId);
//			  out.println("area:"+iAreaId);
			  pstmt.execute();
	  		  String strTemp=bDeleted?"delete":"update";
               DBHelper.log(null,strCurLogin, "equipmentSetup.jsp:"+strTemp+":id="+key+"/"+oldEquipmentName+"="+newEquipmentName+"/"+oldAreaIds+"="+newAreaIds);
			}
			if ((bUpdated||bDeleted) && !bConfirm)
				bConfirm=true;
	  } //end for
	      
	       newEquipmentName = request.getParameter("addEquipmentName")==null?"":request.getParameter("addEquipmentName").trim();
		    
		   if (newEquipmentName.length()>0  ){
			    bNewRow=true;
                pstmt=c.prepareStatement(sqlInsert);
				pstmt.setString(1,newEquipmentName);
				pstmt.setString(2,"N");
				pstmt.setString(3,"");
				pstmt.setString(4,"");
				pstmt.execute();
 			   DBHelper.log(null,strCurLogin,"equipmentSetup.jsp:insert:"+newEquipmentName);

		   }
          bConfirm=bConfirm || bNewRow;
	  c.commit();
     %>
	  <%
		 if (bConfirm){
		 %>
                <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
	 <%
	     }
	 } //end if action == save
       String sql="select * from tblArea  where hidden <>'Y' or hidden is null order by areaid";
       st=c.createStatement();
	   rs=st.executeQuery(sql);
	   ArrayList idList = new ArrayList(); //store all active areas 
	   ArrayList nameList = new ArrayList();
       ArrayList abbrList = new ArrayList();
       while (rs.next()){
		   String strAreaID=rs.getString("areaid");
   		   String strAreaName=rs.getString("areaname");
		   String strAreaAbbr=rs.getString("abbr");
		   idList.add(strAreaID);
		   nameList.add(strAreaName);
		   abbrList.add(strAreaAbbr);
	   }
       int totalAreas=idList.size();

	   sql="select * from tblEquipment where hidden<>'Y' or hidden is null order by equipmentName";
       st=c.createStatement();
	   rs=st.executeQuery(sql);
	   int i=0;
       %>
	   <table border='0'>
	   <tr style="background-color:#aaaaaa"><th>Del.</th><th>Equipment Name</th><th>Owner</th><th>Applicable Department(s)</th></tr>
	   <%
	   while (rs.next()){
		   int iEquipmentId=rs.getInt("equipmentid");
		   String strEquipmentName=rs.getString("equipmentName");
           String strAreaIDs=rs.getString("areaid")==null?"":rs.getString("areaid");

		   String strClass="evenRow";
	       if (i%2==0)
                strClass="evenRow";
	       else
		         strClass="oddRow";
	   %>
		  
            <tr class="<%=strClass%>"  style="height:30px;">
			<td> <input type="checkbox" name="delete<%=i%>" id="delete<%=i%>" value="Y"></td>
			<td> <input type="hidden" name="equipmentId<%=i%>" id="equipmentId<%=i%>"  value=<%=iEquipmentId%>>
              		 <input type="hidden" name="oldName<%=i%>" id="oldName<%=i%>" value="<%=strEquipmentName%>">
				     <input type="text" style="width:180px" id="newName<%=i%>"  name="newName<%=i%>" title="<%=strEquipmentName%>" value="<%=strEquipmentName%>"> 
			</td>
			<td style="text-align:center" title="Edit Equipment Owner"><a href="equipmentownersetup.jsp?page=2&equipment=<%=iEquipmentId%>&equipmentname=<%=strEquipmentName%>"><img border="0" src="images/person.gif" alt="Edit"></a>
			</td>
			<td nowrap><input type="hidden" name="oldAreaId_<%=i%>" id="oldAreaId_<%=i%>" value="<%=strAreaIDs%>">
			           <input type="hidden" name="newAreaId_<%=i%>" id="newAreaId_<%=i%>" value="<%=strAreaIDs%>">
			   <%
				 for (int k =0; k<idList.size();k++){
				    String areaId_t=(String)(idList.get(k));
					String areaName_t=(String)(nameList.get(k));
					String areaAbbr_t=(String)(abbrList.get(k));
					boolean bHasThisArea=strAreaIDs.trim().equals("")?false: (","+strAreaIDs+",").indexOf(","+areaId_t+",")>-1 ;
				 	String strChecked=bHasThisArea?"checked":"";
					%>
                    <span title="<%=areaName_t%>"><%=areaAbbr_t%><input type="checkbox" name="areaBox_<%=i%>_<%=k%>" id="areaBox_<%=i%>_<%=k%>" value="<%=areaId_t%>" onclick="resetArea(<%=i%>);" <%=strChecked%>></span>
					<%
			      }
				%>
			</td>
			</tr>
		   <%
			   i++;
	   }
		   %>
	     <tr  class="newRow" style="height:30px">
         <td align="center" style="color:#ff0000">+</td>
         <td>
		 <input type="text" name="addEquipmentName" id="addEquipmentName" value="">
		</td>
		<td>&nbsp;</td>
		<td>
		</td>
	    </tr>
		   </table>

		   <input type="submit" id="btnSave" name="btnSave" value="Save">
		   <input type="reset" id="btnCancel" name="btnCancel" value="Reset" >
		   <input type="hidden" id="total" name="total" value="<%=i%>">
		   <input type="hidden" id="totalArea" name="totalArea" value="<%=totalAreas%>">
		   <script  type="text/javascript">
			    totalEquipment=<%=i%>;
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
