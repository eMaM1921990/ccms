<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ page import="java.io.*, java.util.*, javax.servlet.*, javax.servlet.http.*" %>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<title>System Memory Stat.</title>
</head>
<body>

<%
if(request.getParameter("btnSubmit") != null){
 out.println("Recycling Garbage...");
 System.gc();
}


long totMem=Runtime.getRuntime().totalMemory()/1024/1024;
long freeMem=Runtime.getRuntime().freeMemory()/1024/1024;
long usedMem=totMem-freeMem;
out.println("<h4>Current Workbrain Memory Usage:</h4>");
out.println("Total claimed Memory:"+totMem+"MB/512MB");
out.println("<br>");
out.println("Used  Memory:"+usedMem+"MB");
out.println("<br>");
out.println("Free  Memory:"+freeMem+"MB");
out.println("<br>");

int iTot=(int)(150*(totMem/totMem));
int iFree=(int)(150*((float)freeMem/totMem));
int iUsed=(int)(150*((float)usedMem/totMem));

out.println("<div style='border:1px solid #000000; width:"+iTot+" ; height:20;  background-color:#0000ff'><span></span>  </div>");
out.println("<div style='border:1px solid #000000; width: "+iUsed+"; height:20;  background-color:#ff0000'><span></span>  </div>");
out.println("<div style='border:1px solid #000000; width:"+iFree+" ; height:20;  background-color:#00ff00'><span></span>  </div>");
%>
<br>

<div style='border:1px solid #000000; width:50 ; height:20;  background-color:#0000ff'><span>Total</span>  </div>
<div style='border:1px solid #000000; width:50 ; height:20;  background-color:#00ff00'><span>Free</span>  </div>
<div style='border:1px solid #000000; width:50 ; height:20;  background-color:#ff0000'><span>Used</span>  </div>

<form name='WBMemForm'   method="post" action="memstat.jsp">
 <input type=submit name = "btnSubmit" value="Run Garbage Collector">

 <input type=submit name ="btnRefresh" value="refresh" >

  
</form>
<!--

<br />
<h3> Running Garbage Collector...</h3>
<%
// System.gc();
%>

<br/>


<h3>New Workbrain Memory Usage:</h3>
<%  
out.println("Total Memory:"+Runtime.getRuntime().totalMemory()/1024/1024+"MB");
%>
<br />

<%
out.println("Free Memory:"+Runtime.getRuntime().freeMemory()/1024/1024+"MB");
%>

-->
<h5> This Page  automatically refreshes itself every 60 seconds</h5>

<script language="JavaScript">
setInterval("document.WBMemForm.submit();",60000);
</script>
</body>
</html>