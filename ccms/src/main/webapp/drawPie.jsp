<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ page language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.awt.*" %>
<%@ page import="java.awt.geom.*" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="com.sun.image.codec.jpeg.*" %>

<%!
  
 class piece
 {
  Color c;
  String name;
  float amount; 
  
 piece(){
  name="";
  c=new Color(0xffffff);
  amount=0.0f;
 }

 piece(String name, int c, float a){
   this.c=new Color(c);
   this.name=name;
   this.amount=a;
  }
  
 public Color getPieceColor()
 {
   return c;
 }
 public float getPieceAmount(){
  return amount;
 }
 public String getPieceName(){
  return name;
  }

 public String toString(){
  return name + ","+ c +"," + amount;
 }
} //end class piece
 %>
 


 <%
 piece [] piePieces=null;
 String str = request.getParameter("q");
 if (str==null) return;

 if(str.length()<0) return;

 StringTokenizer tk = new StringTokenizer(str,"|") ;
 if (tk.countTokens()>0){
      piePieces=new piece[tk.countTokens()];
      int j=0;
      while (tk.hasMoreTokens()){
       String p = (String)tk.nextToken();
       StringTokenizer tk2 = new  StringTokenizer(p,",");     
       if (tk2.countTokens() ==3){
          String n = (String)tk2.nextToken();
		  try{
          int c = Integer.parseInt((String)tk2.nextToken(), 16);
          float a = Float.parseFloat((String)tk2.nextToken());
          piePieces[j]=new piece(n, c,a);
		  }catch(Exception e){ return;}

          j++;
       } //end if
	   else
		   return;
      }//end while
 }//end if
 else
   return;
 
 if (piePieces.length<=0) return;

 float total = 0.0f;
 float pieceTotal=0.0f;
 int lastElement = 0;



 if ( piePieces!=null)
   for(int i=0; i<piePieces.length; i++)
      pieceTotal += piePieces[i].getPieceAmount();

try{
	String strTotal=request.getParameter("total");
   if (strTotal!=null)
     total=Float.parseFloat(strTotal);
 }catch(Exception e){total=0.0f;}

  
  if (total<pieceTotal)
    total=pieceTotal;
  if (total<=0.0 )
    return;

int bgColor=0xffffff;
 String strBgColor = request.getParameter("bkground");
 if (strBgColor!=null)
 try{
	 bgColor=Integer.parseInt(strBgColor,16);
 }catch(Exception e){
    bgColor=0xffffff;
 }
 

 

 int innerOffset = 10;


 int WIDTH  = 400;
 int HEIGHT = 180;	

 String strWidth = request.getParameter("w");
 try{
	 WIDTH=Integer.parseInt(strWidth);
 }catch(Exception e){
     WIDTH=400;
 }
 String strHeight = request.getParameter("h");
 try{
	 HEIGHT=Integer.parseInt(strHeight);
 }catch(Exception e){
     HEIGHT=180;
 }
 
 int pieHeight = HEIGHT - (innerOffset * 2);
 int pieWidth =  pieHeight;            
// int halfWidth = WIDTH/2;
 int halfWidth = pieHeight+20;

 int innerWIDTH = WIDTH - (innerOffset * 2);

 Dimension graphDim = new Dimension(WIDTH,HEIGHT);
 Rectangle graphRect = new Rectangle(graphDim);

 Dimension borderDim = new Dimension(WIDTH-2,HEIGHT-2);
 Rectangle borderRect = new Rectangle(borderDim);



 BufferedImage bi = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
 Graphics2D g2d = bi.createGraphics();

 RenderingHints renderHints = new RenderingHints( RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
 g2d.setRenderingHints(renderHints);
 g2d.setColor(new Color(bgColor));
 g2d.fill(graphRect);

if (request.getParameter("border")!=null){
 g2d.setColor(Color.black);
 borderRect.setLocation(1,1);
 g2d.draw(borderRect);
}

 //borderRect.setLocation((WIDTH/2) + 1,1);
 //g2d.draw(borderRect);

 int x_pie = innerOffset;
 int y_pie = innerOffset;

 
 Ellipse2D.Double elb = new Ellipse2D.Double(x_pie, y_pie, pieWidth, pieHeight);
 
 Color dropShadow = new Color(255,0,0);
 g2d.setColor(dropShadow);
 g2d.fill(elb);

 g2d.setColor(Color.black);
 g2d.draw(elb);


 int startAngle = 0;

 int legendWidth = 20;
 int x_legendText = halfWidth + innerOffset/2  + legendWidth + 5;
 int x_legendBar = halfWidth + innerOffset/2 ;
 int textHeight = 20;
 
 int y_legend = innerOffset+20;
 
 Dimension legendDim = new Dimension(legendWidth , textHeight/2);
 Rectangle legendRect = new Rectangle(legendDim);
 if(piePieces!=null) {
	 int i=0;
	 float totPerc=0.0f;
	 float totAmount=0.0f;
  for(i=0; i<piePieces.length; i++) {
   if(piePieces[i].getPieceAmount() > 0.0f) {
     float perc = (piePieces[i].getPieceAmount()/total);
	 totPerc+=perc;
	 totAmount+=piePieces[i].getPieceAmount();
	 int sweepAngle = (int)(Math.ceil(perc * 360));
 
	  g2d.setColor(piePieces[i].getPieceColor());
      g2d.fillArc(x_pie, y_pie, pieWidth, pieHeight, startAngle, sweepAngle);
      startAngle += sweepAngle;  

    y_legend = i * textHeight + innerOffset+20;    
    String display = piePieces[i].getPieceName();
    g2d.setColor(Color.black);
    g2d.drawString(display, x_legendText, y_legend);

    display = "" + (int)piePieces[i].getPieceAmount();
    g2d.drawString(display, x_legendText + 80, y_legend);

    DecimalFormat df2 = new DecimalFormat( "#,###,###,##0.00" );

     float dd2dec = new Float(df2.format(perc*100)).floatValue();

    display = "  (" + dd2dec + "%)";
    g2d.drawString(display, x_legendText + 110, y_legend);

    g2d.setColor(piePieces[i].getPieceColor());
    legendRect.setLocation(x_legendBar,y_legend - textHeight/2);
    g2d.fill(legendRect);
   }
  }
  String strLeft = request.getParameter("left");
  if (strLeft!=null && totPerc < 1.0){
    y_legend = i * textHeight + innerOffset+20;    
    String display = strLeft;
    g2d.setColor(Color.black);
    g2d.drawString(display, x_legendText, y_legend);

    display = "" + (int)(total-totAmount);
    g2d.drawString(display, x_legendText + 80, y_legend);

    DecimalFormat df2 = new DecimalFormat( "#,###,###,##0.00" );

     float dd2dec = new Float(df2.format((1.0-totPerc)*100)).floatValue();

    display = "  (" + dd2dec + "%)";
    g2d.drawString(display, x_legendText + 110, y_legend);

    g2d.setColor(dropShadow);
    legendRect.setLocation(x_legendBar,y_legend - textHeight/2);
    g2d.fill(legendRect);
  }

 }

 response.setContentType("image/jpeg"); 
 try{
 response.reset();
 OutputStream output = response.getOutputStream();
//  OutputStream output = new FileOutputStream(System.getProperty("user.dir")+"\\applications\\workbrain\\war\\new_etm\\ST_Gap.jpg");
 JPEGImageEncoder encoder = JPEGCodec.createJPEGEncoder(output);
 encoder.encode(bi);
 output.close();
 }catch(Exception e){ 
 response.setContentType("text/html"); 
 out.println(e);
}
 //response.sendRedirect("ST_Gap.jpg");
 
 %>

 
