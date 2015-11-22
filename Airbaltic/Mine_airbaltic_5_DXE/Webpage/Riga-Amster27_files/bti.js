function getId( id)
{
  if( document.getElementById( id)) {
    return document.getElementById( id);
  } else {
    return null;
  }
}

function getElement( id)
{
  if( document.getElementById( 'id_' + id)) {
    return document.getElementById( 'id_' + id);
  }

  return null;
}

function initializeObjects()
{
  objlist = document.getElementsByTagName("object");
  for ( var thisobj = 0; thisobj < objlist.length; thisobj++) {
    objlist[thisobj].outerHTML = objlist[thisobj].outerHTML;
  }
}

function getSelectedRadio( x)
{
  var value = '';

  // now get the new selection
  if( x && x.length) {
    // loop over all radios
    for( i = 0; i < x.length; i++) {
      if( x[i].checked) {
        value = x[i].value;
        // break;
      }
    }
  } else if( x) {
    // only single radio
    if( x.checked) {
      value = x.value;
    }
  }

  return value;
}

// returns the associative kex at index position x
function getArrayKey( arr, ix)
{

  var i = 0;
  for( key in arr) {
    if( i == ix) {
      return key;
    }
    i++;
  }

  return '';
}

// necessary for associative arrays
function arrayLength( arr)
{

  var i = 0;
  for( key in arr) {
    i++;
  }

  return i;
}

// currency conversion
function convertCurrency( amount, roe, rrule, rbase)
{
  var convamount = amount * roe;
  switch ( rrule) {
  case 'UP TO':
    convamount = convamount + rbase - 0.0001;
    convamount = parseInt( convamount / rbase) * rbase;
    break;
  case 'DOWN TO':
    convamount = parseInt( convamonut);
    break;
  case 'ACTUAL':
    break;
  case 'NEAREST':
  default:
    convamount = convamount + rbase / 2;
    convamount = parseInt( convamount / rbase) * rbase;
    break;
  }

  return convamount;
}

function getXmlObj()
{
  var resObj = null;
  try {
    // first try to create an Internet Explorer Object (new Version)
    resObj = new ActiveXObject( 'Msxml2.XMLHTTP');
  } catch( error) {
    try {
      // if this failes try to create an Internet Explorer Object (old Version)
      resObj = new ActiveXObject( 'Microsoft.XMLHTTP');
    } catch( error) {
      try {
        // if this also failes try to create an object for all non IE browsers
        resObj = new XMLHttpRequest();
      } catch( error) {
        // if this also failes we have a problem
        resObj = null;
      }
    }
  }

  return resObj;
}

// remove leading and trailing whitespaces
function trim (zeichenkette) {
  return zeichenkette.replace (/^\s+/, '').replace (/\s+$/, '');
}

