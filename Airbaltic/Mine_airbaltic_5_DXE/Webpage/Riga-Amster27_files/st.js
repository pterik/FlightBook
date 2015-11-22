var _noteGlAnalytics='';
var _notevalute='LVL';
var _notegoal='';
var _notegoalprice='';
var _clientlang='';
var _pagename='';
var _clientId='0';
var _currentOrderId='';
var _currentOrderSum='0';
var _clientindex=new Array();
var _clientPirkims=new Array();
var _clientPirkimsLd=0;
var _clientItems=new Array();
var _clientItemsInc=0;
var _clientItemsInc2=0;
var _segment=0;
var _writeToFrame='';
var _analyticsTransactionFrm=0;
var _nt_image=new Image(1,1);
__isChrome = function() { return Boolean(window.chrome); }
function __noteVoid() { return; }
function __noteAnalytics() {
__prtclw=document.location.protocol;
__noteHostw=(__prtclw=="https:")?'s://':'://';
cdDepths=window.screen.colorDepth;
document.cookie="__noteCook";
if (document.cookie) {
_clcook=1;
} else {
_clcook=0;
}
_pname=_pagename;
_clang=_clientlang;
if (_notegoal != '') { _noteGlAnalytics='&gt='+_notegoal+'&vlt='+_notevalute; if (_notegoalprice != '') { _noteGlAnalytics=_noteGlAnalytics+'&gp='+_notegoalprice; } }
_currentOrderstr='';
if (_currentOrderId != '') { _currentOrderstr='&oid='+_currentOrderId+'&osm='+_currentOrderSum; }
sw=window.screen.width;
sh=window.screen.height;
ref=encodeURIComponent(document.referrer);
locat=encodeURIComponent(location.href);
_title=encodeURIComponent(document.title);
nt_date=new Date();
var _tmz=encodeURIComponent(nt_date.getTimezoneOffset());
_nt_image.src='http'+__noteHostw+'www.airbaltic.com/thirdparty/s.php?cookie='+_clcook +'&color='+cdDepths +'&ww='+sw +'&wh='+sh +'&ref='+ref +'&loc='+locat+'&title='+_title +'&tmz='+_tmz +'&cid='+_clientId +'&sq='+_segment +'&clang='+_clang +'&pagename='+_pname+_noteGlAnalytics+_currentOrderstr +'&rnd='+Math.random();
}
function __addTransaction(orderId,clientId,clientName,sumTotal,shipTotal,ordValute) {
_currentOrderId=orderId;
_currentOrderSum=sumTotal;
__prtclw=document.location.protocol;
__noteHostw=(__prtclw=="https:")?'s://s.':'://www.';
document.write('<iframe name="transactionIframe" id="transactionIframe" src="/thetransactions.html" style="border: 0px;" width="1" height="1" marginwidth="0" marginheight="0" vspace="0" hspace="0" frameborder="0" scrolling="0"></iframe>');
_writeToFrame+='<html><head><title></title></head><body><form name="divsTransactionAnalytics" id="divsTransactionAnalytics" target="_self" method="POST" action="http'+__noteHostw+'we'+'bstatistika.lv/nt/tr.php?cid='+_clientId +'">';
_writeToFrame+='<input type="hidden" name="W_submit" value="1">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[orderId]" value="'+orderId+'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[clientId]" value="'+clientId+'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[clientName]" value="'+clientName+'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[sumTotal]" value="'+sumTotal+'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[shipTotal]" value="'+shipTotal+'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[ordValute]" value="'+ordValute+'">';
}
function __addItem(orderId,itemId,itemName,itemCat,itemPrice,itemTax,itemQuant,itemCode,itemDiscount) {
if (_currentOrderId != "" && _currentOrderId != orderId) { orderId=_currentOrderId; }
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[trans][I_'+_clientItemsInc+'][itemId]" value="'+itemId +'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[trans][I_'+_clientItemsInc+'][itemName]" value="'+itemName +'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[trans][I_'+_clientItemsInc+'][itemCat]" value="'+itemCat +'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[trans][I_'+_clientItemsInc+'][itemPrice]" value="'+itemPrice +'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[trans][I_'+_clientItemsInc+'][itemTax]" value="'+itemTax +'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[trans][I_'+_clientItemsInc+'][itemQuant]" value="'+itemQuant +'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[trans][I_'+_clientItemsInc+'][itemCode]" value="'+itemCode +'">';
_writeToFrame+='<input type="hidden" name="W_'+orderId +'[trans][I_'+_clientItemsInc+'][itemDiscount]" value="'+itemDiscount +'">';
_clientItemsInc++;
}
function __submitOrder() {
_writeToFrame+='</form></body></html>';
window.frames.transactionIframe.document.open();
window.frames.transactionIframe.document.write(_writeToFrame);
window.frames.transactionIframe.document.close();
if (window.frames.transactionIframe.document.divsTransactionAnalytics) { __sOTM(); }
}
function __sOTM() {
if (_nt_image.complete==true) { window.frames.transactionIframe.document.divsTransactionAnalytics.submit(); return true; }
var t=setTimeout("__sOTM()",100);
}
function __noteExplode(inputstring,separators,includeEmpties) {
inputstring=new String(inputstring);
separators=new String(separators);
if(separators=="undefined") { separators=" :;"; }
fixedExplode=new Array(1);
_currentElement="";
_count=0;
for(x=0;x<inputstring.length;x++) {
_char=inputstring.charAt(x);
if(separators.indexOf(_char) != -1) {
if ( ( (includeEmpties <= 0) || (includeEmpties==false)) && (_currentElement=="")) {
} else {
fixedExplode[_count]=_currentElement;
_count++;
_currentElement="";
}
} else { _currentElement+=_char; }
}
if (( !(includeEmpties<=0) && (includeEmpties!=false)) || (_currentElement!="")) { fixedExplode[_count]=_currentElement; }
return fixedExplode;
}
function __noteClickerMan(hr) {
__prtclw=document.location.protocol;
__noteHostw=(__prtclw=="https:")?'s://':'://';
locat=encodeURIComponent(location.href); _title=encodeURIComponent(document.title); _pname=_pagename; _clang=_clientlang; hr=encodeURIComponent(hr);
if (__isChrome()) {
http = new XMLHttpRequest();
http.open('GET', 'http'+__noteHostw+'www.airbaltic.com/thirdparty/s.php?exit=1&nm=1&exitpage='+hr+'&loc='+locat+'&title='+_title+'&cid='+_clientId+'&sq='+_segment+'&clang='+_clang+'&pagename='+_pname+'&rnd='+Math.random(), false);
http.send(null);
} else {
nt_image2=new Image(1,1);
nt_image2.src='http'+__noteHostw+'www.airbaltic.com/thirdparty/s.php?exit=1&exitpage='+hr+'&loc='+locat+'&title='+_title+'&cid='+_clientId+'&sq='+_segment+'&clang='+_clang+'&pagename='+_pname+'&rnd='+Math.random();
}
}
function __noteClicker(e) {
__prtclw=document.location.protocol;
__noteHostw=(__prtclw=="https:")?'s://':'://';
locat=encodeURIComponent(location.href); _title=encodeURIComponent(document.title); _pname=_pagename; _clang=_clientlang; pn1=window.event?window.event.srcElement:e.target;
i=0;
while(pn1.tagName) {
if(pn1) {
if(pn1.tagName.toLowerCase()=='a' || pn1.tagName.toLowerCase()=='area') {
_ok=1;
hr=pn1.getAttribute('href');
_curExplode=new Array();
_curExplode=__noteExplode(hr,"/",0);
_i=0;
if (_curExplode[1]) {
while (_clientindex[_i]) {
if (_curExplode[1].indexOf(_clientindex[_i]) > -1) { _ok=0; break; }
_i++;
}
}
if (_ok==1 && hr.indexOf('javascript:')==-1 && hr.indexOf('://')>-1) {
hr=encodeURIComponent(hr);
if (__isChrome()) {
http = new XMLHttpRequest();
http.open('GET', 'http'+__noteHostw+'www.airbaltic.com/thirdparty/s.php?exit=1&nm=1&exitpage='+hr+'&loc='+locat+'&title='+_title+'&cid='+_clientId+'&sq='+_segment+'&clang='+_clang+'&pagename='+_pname+'&rnd='+Math.random(), false);
http.send(null);
} else {
nt_image2=new Image(1,1);
nt_image2.src='http'+__noteHostw+'www.airbaltic.com/thirdparty/s.php?exit=1&exitpage='+hr+'&loc='+locat+'&title='+_title+'&cid='+_clientId+'&sq='+_segment+'&clang='+_clang+'&pagename='+_pname+'&rnd='+Math.random();
}
}
break;
} else { if (!pn1.parentNode) { break; } pn1=pn1.parentNode; }
} else { break; }
i++;
}
}
var __noteRoot=window.addEventListener || window.attachEvent?window:document.addEventListener?document:null;
if (__noteRoot){
if (__noteRoot.addEventListener) { __noteRoot.addEventListener("click",__noteClicker,false); }
else if (__noteRoot.attachEvent) { document.attachEvent("onclick",__noteClicker); }
}