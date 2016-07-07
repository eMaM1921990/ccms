<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<%
  Connection c=null;
  Statement st=null;
  ResultSet rs =null;
  String sql="";
  String strPageSize = request.getParameter("pagesize")==null?"100":request.getParameter("pagesize");
  String strCurPage = request.getParameter("curPage")==null?"1":request.getParameter("curPage");
  boolean bErrFilter=request.getParameter("errBox")==null?false:request.getParameter("errBox").equals("Y");
  String strFilterChecked="";
  if (bErrFilter)
    strFilterChecked="checked";
  int pageSize=0;
  int curPage=1;
  try{
	  pageSize=Integer.parseInt(strPageSize);
  }catch(Exception e){
	  pageSize=100;
  }
 try{
	  curPage=Integer.parseInt(strCurPage);
  }catch(Exception e){
	  curPage=1;
  }
 
  String strAction="";
  strAction=request.getParameter("btnPrev")==null?strAction:request.getParameter("btnPrev");
  strAction=request.getParameter("btnNext")==null?strAction:request.getParameter("btnNext");
  
  if (strAction.equals("Prev")){
	  curPage--;
  }
  else if (strAction.equals("Next")){
	  curPage++;
  }
  curPage=curPage<1?1:curPage;


  int from=(curPage-1)*pageSize;
  int to=(curPage)*pageSize;
  int cnt=0;

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>CMS System Log</title>
  <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

 </head>
 <body>
 <form name="the_form" id="the_form" method="post" action="#">
   <input type="hidden" name="curPage" id="curPage" value="<%=curPage%>">
   <input type="submit" name="btnPrev" id="btnPrev" value="Prev">
   <input type="submit" name="btnNext" id="btnNext" value="Next"> 
   <input type="checkbox" name="errBox" id="errBox" value="Y" <%=strFilterChecked%>>
   <br/>

<%
String strFilter="";
sql ="select  * from tblCCMSLogging order by id desc";

try{
	c=DBHelper.getConnection();
	st=c.createStatement();
	rs=st.executeQuery(sql);
	%>
	<table border="1" cellpadding="0" cellspacing="0">
	<%
	while(rs.next()){
		if ( cnt>=from && cnt<to){
          String strID=rs.getString("id");
	      String strAcct=rs.getString("acct");
	      String strTime=rs.getString("creationtime");
	      String strMessage=rs.getString("message");
		  boolean bIsError=strMessage.toLowerCase().indexOf("error")>-1 || strMessage.toLowerCase().indexOf("exception")>-1;
		  String strClass=bIsError?"missing":"";
	      if (bErrFilter){
			 if(bIsError){

	    %>
	      <tr class="<%=strClass%>"><td><%=cnt%></td><td><%=strID%></td><td><%=strAcct%></td><td><%=strTime%></td><td><textarea style="width:800px;height:60px"><%=strMessage%></textarea></td></tr>
	    <%
			}
		  }
		  else{
	    %>
	      <tr class="<%=strClass%>"><td><%=cnt%></td><td><%=strID%></td><td><%=strAcct%></td><td><%=strTime%></td><td><textarea style="width:800px;height:60px"><%=strMessage%></textarea></td></tr>
       <%
		  }
		}
		else {
			   if (cnt>=to) break;
		}
		 cnt++;
	}
	%>
	</table>
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
</form>
</body>
</html>