 function getDateFromString(s){
   var pos1=s.indexOf("/");

   var m = s.substring(0,pos1);
   var pos2=s.indexOf("/",pos1+1);
   var d=s.substring(pos1+1,pos2 );
   var y=s.substring(pos2+1);
   return new Date(y,m-1,d);
  }
  function dateDiff(objId1, objId2){
	var str = document.getElementById(objId1).value;
	var  d1 = getDateFromString(str);
	str= document.getElementById(objId2).value;
	var  d2 = getDateFromString(str);
	return (d2.getTime()-d1.getTime())/(1000*60*60*24);

}