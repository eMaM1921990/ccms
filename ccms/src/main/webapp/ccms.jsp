<%@ include file="inc.jsp" %>
<%
	response.setHeader("Cache-Control", "no-cache"); //HTTP 1.1
	response.setHeader("Pragma", "no-cache"); //HTTP 1.0
	response.setDateHeader("Expires", 0); //prevents caching at the proxy server
%>

<%
	String strUrl = request.getParameter("url") == null ? "" : request
			.getParameter("url");

	if (strUrl.equals(""))
		strUrl = "content.jsp";
%>


<frameset id="set1" rows="70,*" frameborder="no">
	<frame name="top" id="top" src="./header.jsp" noresize scrolling="no">
                       
       <frameset id="set2" cols="120,*">
        <frame name="toc" id="toc" scrolling="no"
			style="border-right-style: solid; border-right-width: 1;"
			src="./toc.jsp">
        <frame name="main" id="main" src="<%=strUrl%>" scrolling="auto">
                       
     </frameset>
    </frameset>




 
	

