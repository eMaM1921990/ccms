<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%
	Connection c = null;
	Statement st = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sql = "SELECT COUNT(LogID) AS TOTAL,S.ApprovalStatus FROM tblChangeControlLog T INNER JOIN tblArea A ON T.AreaID=A.AreaID"
			+" INNER JOIN tblApprovalStatus S ON S.ApprovalStatusID=T.ApprovalStatusID  GROUP BY S.ApprovalStatus";
	try {
		c = DBHelper.getConnection();
		st = c.createStatement();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript"
	src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script src="js/highcharts.js"></script>
<script src="js/highcharts-3d.js"></script>
<script type="text/javascript">


function Pie(){
	
	var options = {
			chart: {
				renderTo: 'container',
	            type: 'pie',
	            options3d: {
	                enabled: true,
	                alpha: 45,
	                beta: 0
	            }
	        },
	        title: {
	            text: 'Approval by site chart'
	        },
	        
	        plotOptions: {
	            pie: {
	                allowPointSelect: true,
	                cursor: 'pointer',
	                depth: 35,
	                dataLabels: {
	                    enabled: true,
	                   	format: '<b>{point.name}</b>: {point.y} '
	                },
	        showInLegend: true
	            }
	        },
	        
	        credits: {
	        	enabled: false
	        	},
	        	
	        series: []
			};
			
	
	options.series = new Array();
	options.series[0] = new Object();
	options.series[0].name = "Status";
	options.series[0].data = new Array(); 
	
	<%rs = st.executeQuery(sql);
	int total=0;
								while (rs.next()) {
									total=total+rs.getInt(1);
								%>
	options.series[0].data.push(["<%=rs.getString(2)%>",parseInt(<%=rs.getInt(1)%>)]);
	<%
								}
								rs.close();
	%>
	
	options.series[0].data.push(["Total",parseInt(<%=total%>)]);
	var chart = new Highcharts.Chart(options);
			
			
			}
	


$(function () {
	Pie();
	
	
	/*
    $('#container').highcharts({
        chart: {
            type: 'pie',
            options3d: {
                enabled: true,
                alpha: 45,
                beta: 0
            }
        },
        title: {
            text: 'Approval by department chart'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                depth: 35,
                dataLabels: {
                    enabled: true,
                    format: '{point.name}'
                }
            }
        },
        
        credits: {
        	enabled: false
        	},
        	
        series: []
        	
        	options.series = new Array();
        	options.series[0] = new Object();
        	options.series[0].name = "Orders";
        	options.series[0].data = new Array(); 	
        
    });
    
   */
});
		</script>
<title>Reports</title>
</head>
<body>
	<div id="container" style="height: 400px"></div>
</body>
</html>
<%
	} catch (Exception e) {
		out.println(e);
	} finally {
		DBHelper.closeResultset(rs);
		DBHelper.closeStatement(st);
		DBHelper.closeStatement(pstmt);
		DBHelper.closeConnection(c);
	}
%>