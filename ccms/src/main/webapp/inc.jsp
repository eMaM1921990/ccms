<%!
boolean  bLoggedIn = false;
String strCurLogin;
String strCurUserName;
String strUserType;
boolean bIsSysadmin;
boolean bIsDirector;
String strIsApprover;
boolean bIsApprover;
boolean bIsLoginOwner;
String strLoginAreaOwnerIDs;
boolean bIsLoginSiteOwner;
%>

<%
String [] strUndirectURL={"login.jsp","updatedb.jsp","sendfollowup.jsp","inc.jsp"};

String strRequestUrl=request.getRequestURI();
String queryString = request.getQueryString();
//String strFromEmail="elmansi.k@pg.com";

if (queryString !=null)
 strRequestUrl+="?"+queryString;

boolean bRedirect = true;

for (int i=0;i<strUndirectURL.length;i++){
  if (strRequestUrl.toLowerCase().indexOf(strUndirectURL[i].toLowerCase())>-1){
    bRedirect=false;
    break;
  }
}



if(session.getAttribute("isLogin") != null)
    bLoggedIn = Boolean.valueOf((String)(session.getAttribute("isLogin")));

if (!bLoggedIn || session.getAttribute("usertype") == null) {
	 if (bRedirect) {
	  String strUrl="login.jsp?url="+strRequestUrl;
	  //out.println("<script type='text/javascript'>\n");
	  //out.println("top.location='"+strUrl+"';");
	  //out.println("</script>");
	  System.out.println("Redirecting...");
	  response.sendRedirect(strUrl);
	  return;
	 }
	 else{
	  String strUrl="login.jsp";
	  //out.println("<script type='text/javascript'>\n");
	 //out.println("top.location='"+strUrl+"';");
	 //out.println("</script>");
	 System.out.println("Redirecting...");
	 response.sendRedirect(strUrl);
	  return;
	 
	  }
	}

strCurLogin = (String)(session.getAttribute("user"));
strCurUserName = (String)(session.getAttribute("username"));
strUserType = (String)(session.getAttribute("usertype"));
bIsSysadmin = strUserType.toUpperCase().equals("SYSADMIN");
strIsApprover = session.getAttribute("isApprover") == null ? "N" : (String)(session.getAttribute("isApprover"));
bIsApprover = strIsApprover.equals("Y");

String strIsDirector = strIsApprover = session.getAttribute("isDirector") == null ? "N" : (String)(session.getAttribute("isDirector"));
bIsDirector = strIsDirector.equals("Y");

bIsLoginOwner = session.getAttribute("userAreaIDs") != null;
strLoginAreaOwnerIDs = bIsLoginOwner ? (String)(session.getAttribute("userAreaIDs")) : "";
bIsLoginSiteOwner = bIsLoginOwner?("," + strLoginAreaOwnerIDs + ",").indexOf(",11,") >= 0 : false;
//change the 11 to your own site id in area table

%>