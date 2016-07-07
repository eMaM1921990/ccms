<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%
 boolean bIsProxied= (session.getAttribute("isProxy")==null?"N":(String)(session.getAttribute("isProxy"))).equals("Y");
String strOldLogin="";
if (bIsProxied){
	strOldLogin=(String)(session.getAttribute("oldLogin"));
}
 
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<script type='text/javascript'>
 function doQuickSearch(){
	 var inputObj=document.getElementById("quickID");
	 var qID=-1;
	 if (inputObj.value=="") return false;
	 if (isNaN(inputObj.value)) { alert("Not a Number.");return false;}
	 try{
	  qID=parseInt(inputObj.value);
	 }catch(exp){return false;}
	 
     if (parent.frames["main"])
		 window.parent.frames["main"].location="reviewRequest3.jsp?n="+qID;
	 return false;
}
function handleFocus(obj){
 obj.style.backgroundImage=''
}
function handleBlur(obj){
	if (obj.value==''){
		 obj.style.backgroundImage="url('./images/logNumBg.gif')";
	}

}
</script> 
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>

<body class="header">

<table   border='0' width="100%" cellpadding="0" style="font-family:sans-serif;font-size:10pt;" >
<tr><td><a href="#" onClick="parent.location='./ccms.jsp'"><img border="0" src="./images/ccms.gif" align="center" title="Change Management System"></a></td>
<td valign="top"><% if (bIsProxied){%>[<a href="proxy.jsp?back=true"><%=strOldLogin%></a>]<%}%></td>
<td align="right" valign="top" nowrap>
  <form name="the_form" method="post" action="#" onSubmit="return doQuickSearch();">
    <input type="text" name="quickID" id="quickID" size="6" value="" title="LOG#" style="background-image: url('./images/logNumBg.gif');background-repeat: no-repeat;" onFocus="handleFocus(this);" onBlur="handleBlur(this);" >
	<input type="submit" name="btnQuichSearch" id="btnQuickSearch" value="Quick Review" class="formButton buttonLabel" >
  </form>
</td>
<td align="right" valign="top" nowrap><font size="3" color="#505050" title="Logoff"><a style="color: #505050" href="./logout.jsp"><img src="./images/logout.gif" alt='Logoff' border='0' align="center"><%=strCurLogin%></a></font></td>
</tr>
<tr><td><table style="font-family: sans-serif;font-size:10pt;color:#ffffff;" border='0' cellspacing="0" cellpadding="0">
        <tr>
          <td nowrap><span class="topnav"><a href="./content.jsp"  target="main">Home</a></span></td>
 		   <td nowrap style="color:#EEEEEE;">&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td nowrap><span class="topnav"><a href="./mylist.jsp" target="main">Review My Selection</a></span></td>
  		   
		   <td nowrap style="color:#EEEEEE">&nbsp;&nbsp;&nbsp;&nbsp;</td>
           <td nowrap><span class="topnav"><a href="./list.jsp?creator=<%=strCurLogin%>" target="main" ><%=strCurUserName%>'s Requests</a></span></td>

		   <td nowrap style="color:#EEEEEE">&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td nowrap><span class="topnav"><a href="./help.html" target="_blank">Help</a></span></td>

	    </tr>
		</table>
	</td>
	<td></td>
 </tr>
</table>

</body>
</html>