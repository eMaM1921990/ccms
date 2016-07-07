<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="java.util.Calendar"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<%
  Connection c=null;
  Statement st=null;
  ResultSet rs =null;
  String sql="";

 try {
    c=DBHelper.getConnection();
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>My Selected Requests</title>
 <%@ include file="jsInc.jsp"%>

 <script  type="text/javascript">
 function updateAreaNameArray(ids){
	var pointer=0;
	areaNameArray=new Array();

	for (var i=0;i<areaArray.length;i++){
		if ((","+ids+",").indexOf(","+areaArray[i].id+",")>-1){
			areaNameArray[pointer]=areaArray[i].name;
		     pointer++;
		}
	}
 }
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
function handleFind(){
  document.the_form.submit();
}
function handle_clear(){
 document.getElementById("idBox").value="";
 document.getElementById("requestDateBox").value="";
 document.getElementById("areaBox").value="";
 document.getElementById("lineBox").value="";
 document.getElementById("originatorBox").value="";
 document.getElementById("approvalBox").value="";
}
</script>
 <script language="javascript" type="text/javascript" src="datetimepicker.js"></script>
 <script language="javascript" type="text/javascript" src="ccms.js?v=30"></script>


 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body style="background-color:#ffaa00">
<%
  String strAreaPara="-9999";

  String strCreatorPara=request.getParameter("creator")==null?"":request.getParameter("creator");

  String strIdBox=request.getParameter("idBox")==null?"":request.getParameter("idBox");
  String strRequestDateBox=request.getParameter("requestDateBox")==null? "": request.getParameter("requestDateBox");
  String strOriginatorBox=request.getParameter("originatorBox")==null?"":request.getParameter("originatorBox");
  String strAreaBox=request.getParameter("areaBox")==null?"":request.getParameter("areaBox");
  String strLineBox=request.getParameter("lineBox")==null?"":request.getParameter("lineBox");
  String strEquipmentBox=request.getParameter("equipmentBox")==null?"":request.getParameter("equipmentBox");
  String strApprovalBox=request.getParameter("approvalBox")==null?"":request.getParameter("approvalBox");

  String strPageSize=request.getParameter("pagesize")==null?"20":request.getParameter("pagesize");
  
  String action = request.getParameter("action")==null?"":request.getParameter("action");
  String strPage=request.getParameter("page")==null?"0":request.getParameter("page");
  String strCurPage=request.getParameter("curPage")==null?"0":request.getParameter("curPage");
  
  String strOrderBy=request.getParameter("orderby")==null?"logID":request.getParameter("orderby");
  //"requestDate";
  String strOrder=request.getParameter("order")==null?"desc":request.getParameter("order");//"desc";
  String strSortImageName="arrowSortDown.gif";
  if (!strOrder.equals("desc"))
    strSortImageName="arrowSortUp.gif";

  int pageSize=20;
  try{
	  pageSize=Integer.parseInt(strPageSize);
  }catch(Exception e)
  {pageSize=20;}

  if (pageSize<=0) pageSize =20;
  
  int requestPage = Integer.parseInt(strPage);
  int curPage=Integer.parseInt(strCurPage);

  long count=0;
  long totalPage=0;
  
    st=c.createStatement();
    sql="select * from tblCMSUserPreference where account='"+strCurLogin+"' and preferenceType=1";
	rs=st.executeQuery(sql);
	if (rs.next()){
		strAreaPara=rs.getString("preferenceValue")==null?"":rs.getString("preferenceValue");
	}
	strAreaPara=strAreaPara.equals("")?"-9999":strAreaPara;

	rs.close();

//  String sql="select count(*) from tblChangeControlLog where (hidden is null or hidden<>'Y')";
//  sql="select count(*) from tblChangeControlLog log , tblApprovalStatus stat ";
 // sql+="where log.ApprovalStatusID=stat.approvalStatusID and (log.hidden is null or log.hidden<>'Y')";
  sql="select count(*) from tblChangeControlLog log , tblApprovalStatus stat,tblEquipment e ";
  sql+="where log.ApprovalStatusID=stat.approvalStatusID and log.equipmentID=e.equipmentID and  (log.hidden is null or log.hidden<>'Y')";
  if (!strAreaPara.equals("")){
	  %>
	   <script  type="text/javascript">
		  updateAreaNameArray("<%=strAreaPara%>");
	   </script>
      <%
	
	 // sql+=(","+strAreaPara+",").indexOf(",11,")>-1?" and (CHARINDEX(','+log.areaid+',',',"+strAreaPara+",')>0 or log.take2site=1)":" and CHARINDEX(','+log.areaid+',',',"+strAreaPara+",')>0";
	  String [] strAreaIDs=strAreaPara.split(",");
	  sql+=" and (";
	  for (int i=0;i<strAreaIDs.length;i++){

       sql+=" (charindex(',"+strAreaIDs[i]+",', ','+log.areaid+',')>0) or";
	   if (strAreaIDs[i].equals("11"))
		   sql+=" (log.take2site=1) or";
	  }
	  sql+=" (1=0)";
	  sql+=")";
  }
 
  if (!strCreatorPara.equals("")){
	  sql+=" and creator='"+strCreatorPara+"'";
  }
  sql+= strIdBox.equals("")?"":" and logid like '"+strIdBox+"'";
  sql+= strRequestDateBox.equals("")?"":" and CONVERT(VARCHAR(10), requestDate, 101) like '"+strRequestDateBox+"%'";
  
  sql+= strOriginatorBox.equals("")?"":" and upper(originator) like upper('%"+strOriginatorBox+"%')";
  if (strAreaBox.toUpperCase().equals("SITE")){
	  sql+=" and (upper(areaNames) like upper('%"+strAreaBox+"%') or take2site=1)";
  }
  else
    sql+= strAreaBox.equals("")?"":" and upper(areaNames) like upper('%"+strAreaBox+"%')";
  sql+= strLineBox.equals("")?"":" and upper(lineNames) like upper('%"+strLineBox+"%')";
  sql+= strEquipmentBox.equals("")?"":" and upper(equipmentName) like ('"+strEquipmentBox+"%')";
 
 if (strApprovalBox.equalsIgnoreCase("Overdue"))
   sql+= " and ( upper(approvalStatus) like upper('"+strApprovalBox+"%') or ((upper(approvalStatus) like upper('Approved') and  dateadd(day,-1,getDate())>endTiming)))";
  else 
    sql+= strApprovalBox.equals("")?"":" and upper(approvalStatus) like upper('"+strApprovalBox+"%')";
//   System.out.println(sql);

	rs = st.executeQuery(sql);
     if (rs.next())  
      count=rs.getLong(1); //total number of logs

    totalPage= (long)(Math.ceil((double)count/pageSize));
  
  
  if (action.equals("next")) requestPage=curPage+1;
  if (action.equals("prev")) requestPage=curPage-1;
  if (requestPage<0) requestPage =0;
  if (requestPage>=totalPage) requestPage=(int)totalPage-1;

%>
<form name="the_form" id="the_form" method="post" action="">

 <input type="hidden" name="area" id="area" value="<%=strAreaPara%>">
 <input type="hidden" name="creator" id="creator" value="<%=strCreatorPara%>">

 <input type="hidden" name="curPage" id="curPage" value="<%=requestPage%>">
 <input type="hidden" name="orderby" id="orderby" value="<%=strOrderBy%>">
 <input type="hidden" name="order" id="order" value="<%=strOrder%>">
 <input type="hidden" name="action" id="action" value="">
 <div class="title">My Selected Change Requests</div>
 
<div style="margin-top:0px; padding:5px; width:500px;background-color:#aaaaaa">
<%
  if (requestPage<=0)
//	out.println("Prev");
    out.println("<span style='width:30px'>&nbsp;</span>");
  else
//     out.println("<a href=\"#\" onclick=\"document.getElementById('action').value='prev'; document.the_form.submit();\">Prev</a>");
       out.println("<span style='width:30px'><img align='top' src='images/left.gif' alt='Prev' onclick=\"document.getElementById('action').value='prev'; document.the_form.submit();\"/></span>");
  out.println("&nbsp;&nbsp;Page "+(requestPage+1)+" of "+totalPage+" &nbsp;&nbsp;");
  if (requestPage>=totalPage-1)
//	  out.println("Next");
      out.println("<span style='width:30px'>&nbsp;</span>");
  else
	 // out.println("<a href=\"#\" onclick=\"document.getElementById('action').value='next'; document.the_form.submit();\">Next</a>");
      out.println("<span style='width:30px'><img align='top' src='images/right.gif' alt='Next' onclick=\"document.getElementById('action').value='next'; document.the_form.submit();\"/></span>");

%>
Page Size: <input type="text" name="pagesize" id="pagesize" size="4" value="<%=pageSize%>"> 
<span style="margin-left:20px;font-size:10pt;"><a style="text-decoration:none" href="myareaSetup.jsp"><img src="./images/config2.gif" style="width:16px;height:16px;border:0px;margin-right:5px" align="middle">Config My Selection</a></span>
 </div>

<br/>
<div>
  <table border='1' bordercolor="#CCCCCC" cellpadding='5' cellspacing='0' style="border-collapse: collapse;background-color:#DDDDDD;text-align:left;font-family:Arial;font-size:10pt;">
   <tr>
  	<th style="vertical-align:top;"><div style="width:40px">
	  <input type="submit" name="btnFind" id="btnFind" value="Find"">
	   </div>
	   <a href="javascript:void(0)" onclick="handle_clear();" style="font-size:8pt">Clear</a>
    </th>
    <th style="vertical-align:top;" ><div style="width:65px"><a href="javascript:handleOrder('logID')">ID</a>
       <% if (strOrderBy.equals("logID")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %>
	   <br/>
   	  <input style="width:60px;height:20px" type="text" name="idBox" id="idBox" value="<%=strIdBox%>">
	  </div>
   </th>
  <th style="vertical-align:top;"><div style="width:120px"><a href="javascript:handleOrder('requestDate')">Creation Date</a>
       <% if (strOrderBy.equals("requestDate")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %>
	   <br/>
	   <input style="width:80px;height:20px" type="text" name="requestDateBox" id="requestDateBox" value="<%=strRequestDateBox%>">
	   <a href="javascript:NewCal('requestDateBox','MM/DD/YYYY' )">
	      <img src="./images/cal.gif" width="14" height="14" border="0" alt="Pick a date">
	</a>
	</div>
   </th>
   <th style="vertical-align:top;"><div style="width:105px"><a href="javascript:handleOrder('originator')">Originator</a>
       <% if (strOrderBy.equals("originator")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %>
	   <br/>
  	   <input style="vertical-align:top;width:100px;height:20px" type="text" name="originatorBox" id="originatorBox" value="<%=strOriginatorBox%>">
	   </div>
   </th>
   <th style="vertical-align:top;"><div style="width:120px"><a href="javascript:handleOrder('areaNames')">Department</a>
       <% if (strOrderBy.equals("areaNames")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %>
	     <br/>
<!--	   <input style="width:100px;height:20px" type="text" name="areaBox" id="areaBox" value="<%=strAreaBox%>">-->
	 <script  type="text/javascript">
	  newCombo("areaBox","areaBox",100,"<%=strAreaBox%>","", 120,150,areaNameArray); //editable:""
	// newCombo(name, id, input_width, value,list_width,list_height,src)
     </script>
     </div>
   </th>
   <th style="vertical-align:top;"><div style="width:120px"><a href="javascript:handleOrder('lineNames')">Line</a>
       <% if (strOrderBy.equals("lineNames")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %>
	     <br/>
<!--	   <input style="width:100px;height:20px" type="text" name="lineBox" id="lineBox" value="<%=strLineBox%>">-->
	   	 <script  type="text/javascript">
	  newCombo("lineBox","lineBox",100,"<%=strLineBox%>","",150,180,lineNameArray);
     </script>
	 </div>

   </th>
    <th style="vertical-align:top;"><div style="width:120px"><a href="javascript:handleOrder('equipmentName')">Equipment</a>
       <% if (strOrderBy.equals("equipmentName")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %>
	     <br/>
<!--	   <input style="width:100px;height:20px" type="text" name="lineBox" id="lineBox" value="<%=strLineBox%>">-->
	   	 <script  type="text/javascript">
	  newCombo("equipmentBox","equipmentBox",100,"<%=strEquipmentBox%>","",150,180,equipmentNameArray);
     </script>
	 </div>
	 </th>

    <th style="vertical-align:top;"><div style="width:80px"><a href="javascript:handleOrder('approvalStatus')">Status</a>
       <% if (strOrderBy.equals("approvalStatus")) {
	          out.print("<img src='./images/"+strSortImageName+"'>");
         }
	   %>
	     <br/>
   	 <script  type="text/javascript">
	  newCombo("approvalBox","approvalBox",60,"<%=strApprovalBox%>","",150,180,approvalStatusNameArray);
     </script>
	 <!--  <input style="width:100px;height:20px" type="text" name="approvalBox" id="approvalBox" value="<%=strApprovalBox%>">-->
	 </div>
	</th>
</tr>
</table>

</div>
<br/>
<%
sql="select logID, requestDate,startTiming, endtiming, isnull(CONVERT(VARCHAR(10), requestDate, 101),'') requestDateStr, originator,approvalStatus,areaNames,lineNames,equipmentName, notified from tblChangeControlLog log , tblApprovalStatus stat,tblEquipment e ";
  sql+="where log.ApprovalStatusID=stat.approvalStatusID and log.equipmentID=e.equipmentID and  (log.hidden is null or log.hidden<>'Y')";

 if (!strAreaPara.equals("")){
//	  sql+=(","+strAreaPara+",").indexOf(",11,")>-1?" and (CHARINDEX(','+log.areaid+',',',"+strAreaPara+",')>0 or log.take2site=1)":" and CHARINDEX(','+log.areaid+',',',"+strAreaPara+",')>0";
	 // sql+=" and CHARINDEX(','+log.areaid+',',',"+strAreaPara+",')>0";
	 String [] strAreaIDs=strAreaPara.split(",");
	  sql+=" and (";
	  for (int i=0;i<strAreaIDs.length;i++){

       sql+=" (charindex(',"+strAreaIDs[i]+",', ','+log.areaid+',')>0) or";
	   if (strAreaIDs[i].equals("11"))
		   sql+=" (log.take2site=1) or";
	  }
	  sql+=" (1=0)";
	  sql+=")";
  }     

  if (!strCreatorPara.equals("")){
	  sql+=" and creator='"+strCreatorPara+"'";
  }
  sql+= strIdBox.equals("")?"":" and logid like '"+strIdBox+"'";
  sql+= strRequestDateBox.equals("")?"":" and CONVERT(VARCHAR(10), requestDate, 101) like '"+strRequestDateBox+"%'";
  sql+=strOriginatorBox.equals("")?"":" and upper(originator) like upper('%"+strOriginatorBox+"%')";


   if (strAreaBox.toUpperCase().equals("SITE")){
	  sql+=" and (upper(areaNames) like upper('%"+strAreaBox+"%') or take2site=1)";
  }
  else
    sql+= strAreaBox.equals("")?"":" and upper(areaNames) like upper('%"+strAreaBox+"%')";
 
  sql+= strLineBox.equals("")?"":" and upper(lineNames) like upper('%"+strLineBox+"%')";
  sql+= strEquipmentBox.equals("")?"":" and upper(equipmentName) like ('"+strEquipmentBox+"%')";
 if (strApprovalBox.equalsIgnoreCase("Overdue"))
    sql+= " and ( upper(approvalStatus) like upper('"+strApprovalBox+"%') or ((upper(approvalStatus) like upper('Approved') and  dateadd(day,-1,getDate())>endTiming)))";
  else 
    sql+= strApprovalBox.equals("")?"":" and upper(approvalStatus) like upper('"+strApprovalBox+"%')";
 
  sql+=" order by ";
  sql+=strOrderBy+" "+strOrder;
  //out.println("<br/>"+sql);
  rs = st.executeQuery(sql);
  int j=0;

  %>
  <table border='1' bordercolor="#BBBBBB" cellpadding='5' cellspacing='0' style="border-collapse: collapse;background-color:#DDDDDD;text-align:left;font-family:Arial;font-size:10pt;">
 
<%
  String strClass="evenRow";
	  java.util.Date todayDate=new java.util.Date();
	  Calendar cal=Calendar.getInstance();
	  cal.setTime(todayDate);
	  cal.add(Calendar.DATE,-1);
	  todayDate=cal.getTime();


  while (rs.next()){
	  int iLogID_t=rs.getInt("logID");
	  String strCreationDate_t=rs.getString("requestDateStr")==null?"":rs.getString("requestDateStr");
	  String strOriginator_t=rs.getString("originator")==null?"":rs.getString("originator");
	  String strAreaName_t=rs.getString("areaNames")==null?"":rs.getString("areaNames");
	  String strLineName_t=rs.getString("lineNames")==null?"":rs.getString("lineNames");
	  String strEquipmentName_t=rs.getString("equipmentName")==null?"":rs.getString("equipmentName");
	  String strApprovalStatus_t=rs.getString("approvalStatus")==null?"":rs.getString("approvalStatus");
	  java.sql.Date endTimingDate=rs.getDate("endtiming");
	  int iNotified_t=rs.getInt("notified");
      boolean bOverdue=false;
	  if (strApprovalStatus_t.equalsIgnoreCase("Approved") && todayDate.after(endTimingDate) ){
		  bOverdue=true;
	  }
	  strApprovalStatus_t=bOverdue?strApprovalStatus_t+"<img title='Overdue' src='./images/overdue_alarm.gif'>":strApprovalStatus_t;

      if (j%2==0)
		  strClass="evenRow";
	  else
		  strClass="oddRow";		  

	  if(j>=requestPage*pageSize && j<(requestPage+1)*pageSize){
		  %>
            <tr class="<%=strClass%>" height='30'>
             <td><div class="cellNowrapHidden" style="width:40px"><a href='reviewRequest3.jsp?n=<%=iLogID_t%>'>Review</a></div></td>
             <td><div class="cellNowrapHidden" style="width:65px"><%=iLogID_t%></div></td>
             <td><div class="cellNowrapHidden" style="width:120px"><%=strCreationDate_t%></div></td>
             <td><div class="cellNowrapHidden" style="width:105px" title="<%=strOriginator_t%>"><%=strOriginator_t%></div></td>
             <td><div class="cellNowrapHidden" style="width:120px" title="<%=strAreaName_t%>"><%=strAreaName_t%></div></td>
             <td><div class="cellNowrapHidden" style="width:120px" title="<%=strLineName_t%>"><%=strLineName_t%></div></td>
             <td><div class="cellNowrapHidden" style="width:120px" title="<%=strEquipmentName_t%>"><%=strEquipmentName_t%></div></td>
             <td><div class="cellNowrapHidden" style="width:80px"><%=strApprovalStatus_t%></div></td>
       
            </tr>
	<%
	  }
   j++;
  }
 out.println("</table>");
%>


<div style="margin-top:20px; padding-top:5px;padding-bottom:5px; width:500px;background-color:#aaaaaa">
<%
  if (requestPage<=0)
//	out.println("Prev");
    out.println("<span style='width:30px'>&nbsp;</span>");
  else
//     out.println("<a href=\"#\" onclick=\"document.getElementById('action').value='prev'; document.the_form.submit();\">Prev</a>");
       out.println("<span style='width:30px'><img align='top' src='images/left.gif' alt='Prev' onclick=\"document.getElementById('action').value='prev'; document.the_form.submit();\"/></span>");
  out.println("&nbsp;&nbsp;Page "+(requestPage+1)+" of "+totalPage+" &nbsp;&nbsp;");
  if (requestPage>=totalPage-1)
//	  out.println("Next");
      out.println("<span style='width:30px'>&nbsp;</span>");
  else
	 // out.println("<a href=\"#\" onclick=\"document.getElementById('action').value='next'; document.the_form.submit();\">Next</a>");
      out.println("<span style='width:30px'><img align='top' src='images/right.gif' alt='Next' onclick=\"document.getElementById('action').value='next'; document.the_form.submit();\"/></span>");

%>
 </div>
</form>
<script language="javascript" type="text/javascript">
document.body.onclick =closeDDL2 ;
</script>
</body>
</html>
<%
 }
 catch(Exception e){
   out.println(e);
 }
 finally{
        DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeConnection(c);
 }
%>