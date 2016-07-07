 var xhr = new Array(); // ARRAY OF XML-HTTP REQUESTS
var xi = new Array(0); // ARRAY OF XML-HTTP REQUEST INDEXES
xi[0] = 1; // FIRST INDEX SET TO 1 MAKING IT AVAILABLE


function xhrRequest(type) {
if (!type) {
type = 'html';
}


// xhrsend IS THE xi POSITION THAT GETS PASSED BACK
// INITIALIZED TO THE LENGTH OF THE ARRAY(LAST POSITION + 1)
// IN CASE A FREE RESOURCE ISN'T FOUND IN THE LOOP
var xhrsend = xi.length;

// GO THROUGH AVAILABLE xi VALUES
for (var i=0; i<xi.length; i++) {


// IF IT'S 1 (AVAILABLE), ALLOCATE IT FOR USE AND BREAK
if (xi[i] == 1) {
xi[i] = 0;
xhrsend = i;
break;
}
}


// SET TO 0 SINCE IT'S NOW ALLOCATED FOR USE
xi[xhrsend] = 0;


// SET UP THE REQUEST
if (window.ActiveXObject) {
 try {
   xhr[xhrsend] = new ActiveXObject("Msxml2.XMLHTTP");
  } catch (e) {
    try {
      xhr[xhrsend] = new ActiveXObject("Microsoft.XMLHTTP");
    } catch (e) {}
   }
} else if (window.XMLHttpRequest) {
   xhr[xhrsend] = new XMLHttpRequest();
   if (xhr[xhrsend].overrideMimeType) {
      xhr[xhrsend].overrideMimeType('text/' + type);
   }
  }
  return (xhrsend);
}


function makePOSTRequest(url, parameters, cbfn) {
	var xhri = xhrRequest('html');
// alert("index:"+xhri);
// xhr[xhri].open('GET', url, true);
  var para=parameters+"&dummy=1";
  try{
	xhr[xhri].onreadystatechange = function() {
    if (xhr[xhri].readyState == 4 && xhr[xhri].status == 200) {
	 if (cbfn!=undefined && cbfn!=null)
	 {
		 cbfn(xhr[xhri].responseText);
	 }
	 else{
     // alert(xhr[xhri].responseText);
	 }
     xi[xhri] = 1;
     xhr[xhri] = null;
     }
    };
    xhr[xhri].open('POST', url, false);
    xhr[xhri].setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=ISO-8859-6");
    xhr[xhri].setRequestHeader("Content-Length", para.length);
    
   // xhr[xhri].setRequestHeader("Connection", "close");
 
  }catch(e){
	  alert("Error when connecting to the server, plz. try again");
  }
  try{
   xhr[xhri].send(para);
  }catch(e){
	  alert("Error when sending data to the server, plz. try again");
  }
}

function makePOSTRequest2(url, parameters,cbfn) {
 var xhri = xhrRequest('html');
// alert("index:"+xhri);
// xhr[xhri].open('GET', url, true);
  var para=parameters+"&dummy=1";
  try{
	xhr[xhri].onreadystatechange = function() {
    if (xhr[xhri].readyState == 4 && xhr[xhri].status == 200) {
	 if (cbfn!=undefined && cbfn!=null)
	 {
		 cbfn(xhr[xhri].responseText);
	 }
	 else{
     // alert(xhr[xhri].responseText);
	 }
     xi[xhri] = 1;
     xhr[xhri] = null;
     }
    };
    xhr[xhri].open('POST', url, true);
    xhr[xhri].setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr[xhri].setRequestHeader("Content-length", para.length);
   // xhr[xhri].setRequestHeader("Connection", "close");
 
  }catch(e){
	  alert("Error when connecting to the server, plz. try again");
  }
  try{
   xhr[xhri].send(para);
  }catch(e){
	  alert("Error when sending data to the server, plz. try again");
  }
}
