
/* Thanks to http://simonwillison.net/2004/May/26/addLoadEvent/ */
/* for this code that allows the assignment of multiple scripts */
/* (in order!) to the onLoad event                              */
function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

/*
 * Thanks to http://www.howtocreate.co.uk/tutorials/javascript/domcss
 * for the stylesheet switching code
 */

function getAllSheets() {
  //if you want ICEbrowser's limited support, do it this way
  if( !window.ScriptEngine && navigator.__ice_version ) {
    //IE errors if it sees navigator.__ice_version when a window is closing
    //window.ScriptEngine hides it from that
    return document.styleSheets; }
  if( document.getElementsByTagName ) {
    //DOM browsers - get link and style tags
    var Lt = document.getElementsByTagName('link');
    var St = document.getElementsByTagName('style');
  } else if( document.styleSheets && document.all ) {
    //not all browsers that supply document.all supply document.all.tags
    //but those that do and can switch stylesheets will also provide
    //document.styleSheets (checking for document.all.tags produces errors
    //in IE [WHY?!], even though it does actually support it)
    var Lt = document.all.tags('LINK'), St = document.all.tags('STYLE');
  } else { return []; } //lesser browser - return a blank array
  //for all link tags ...
  for( var x = 0, os = []; Lt[x]; x++ ) {
    //check for the rel attribute to see if it contains 'style'
    if( Lt[x].rel ) { var rel = Lt[x].rel;
    } else if( Lt[x].getAttribute ) { var rel = Lt[x].getAttribute('rel');
    } else { var rel = ''; }
    if( typeof( rel ) == 'string' && rel.toLowerCase().indexOf('style') + 1 ) {
      //fill os with linked stylesheets
      os[os.length] = Lt[x];
    }
  }
  //include all style tags too and return the array
  for( var x = 0; St[x]; x++ ) { os[os.length] = St[x]; } return os;
}
function changeStyle() {
  for( var x = 0, ss = getAllSheets(); ss[x]; x++ ) {
    //for each stylesheet ...
    if( ss[x].title ) {
      //disable the stylesheet if it is switchable
      ss[x].disabled = true;
    }
    for( var y = 0; y < arguments.length; y++ ) {
      //check each title ...
      if( ss[x].title == arguments[y] ) {
        //and re-enable the stylesheet if it has a chosen title
        ss[x].disabled = false;
      }
    }
  }
  //if( !ss.length ) { alert( 'Your browser cannot change stylesheets' ); }
}

/*
 * Thanks to http://www.quirksmode.org/js/detect.html for BrowserDetect code
 */

var BrowserDetect = {
    init: function () {
        this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
        this.version = this.searchVersion(navigator.userAgent)
            || this.searchVersion(navigator.appVersion)
            || "an unknown version";
        this.OS = this.searchString(this.dataOS) || "an unknown OS";
    },
    searchString: function (data) {
        for (var i=0;i<data.length;i++) {
            var dataString = data[i].string;
            var dataProp = data[i].prop;
            this.versionSearchString = data[i].versionSearch || data[i].identity;
            if (dataString) {
                if (dataString.indexOf(data[i].subString) != -1)
                    return data[i].identity;
            }
            else if (dataProp)
                return data[i].identity;
        }
    },
    searchVersion: function (dataString) {
        var index = dataString.indexOf(this.versionSearchString);
        if (index == -1) return;
        return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
    },
    dataBrowser: [
        {   string: navigator.userAgent,
            subString: "OmniWeb",
            versionSearch: "OmniWeb/",
            identity: "OmniWeb"
        },
        {
            string: navigator.vendor,
            subString: "Apple",
            identity: "Safari"
        },
        {
            prop: window.opera,
            identity: "Opera"
        },
        {
            string: navigator.vendor,
            subString: "iCab",
            identity: "iCab"
        },
        {
            string: navigator.vendor,
            subString: "KDE",
            identity: "Konqueror"
        },
        {
            string: navigator.userAgent,
            subString: "Firefox",
            identity: "Firefox"
        },
        {
            string: navigator.vendor,
            subString: "Camino",
            identity: "Camino"
        },
        {       // for newer Netscapes (6+)
            string: navigator.userAgent,
            subString: "Netscape",
            identity: "Netscape"
        },
        {
            string: navigator.userAgent,
            subString: "MSIE",
            identity: "Explorer",
            versionSearch: "MSIE"
        },
        {
            string: navigator.userAgent,
            subString: "Gecko",
            identity: "Mozilla",
            versionSearch: "rv"
        },
        {       // for older Netscapes (4-)
            string: navigator.userAgent,
            subString: "Mozilla",
            identity: "Netscape",
            versionSearch: "Mozilla"
        }
    ],
    dataOS : [
        {
            string: navigator.platform,
            subString: "Win",
            identity: "Windows"
        },
        {
            string: navigator.platform,
            subString: "Mac",
            identity: "Mac"
        },
        {
            string: navigator.platform,
            subString: "Linux",
            identity: "Linux"
        }
    ]

};

BrowserDetect.init();

addLoadEvent(function() {
  var o = BrowserDetect.OS
  var b = BrowserDetect.browser
  var v = BrowserDetect.version
  if( (b == "Explorer" && v < 6) ||
      (b == "Netscape" && (v < 7 || v == "an unknown version")) ||
      (b == "Mozilla" && v < 1.7)
    )
  {
    changeStyle('basic')
  }
});

function popup(src, extras, x, y) {
  url = src.getAttribute('href')
  target = src.getAttribute('target') || '_blank'
  features = 'menubar=0,resizable=1,scrollbars=yes,statusbar=0,location=0'
  if (extras != '') { features += ', ' + extras }
  if (x > 0) { features += ', width=' + (x + 20) }
  if (y > 0) { features += ', height=' + (y + 20) }
  var theWindow =
    window.open(url, target, features);
  theWindow.focus();
  return theWindow;
}

function showhide(obj) {
    var el = document.getElementById(obj);
    if ( el.style.display != 'none' ) {
        new Effect.BlindUp(el, {duration:0.3});
    }
    else {
        new Effect.BlindDown(el, {duration:0.3});
    }
}

// This function takes the id of a form
// and looks for 'validate' attributes on each of its fields
// If the value of the element doesn't match the validation regexp,
// it pops up an error and adds an "error" class to the field
function validate(formName) {
	form = $(formName)
	var x = form.elements
	var errors = new Array()
	for(var i=0; i<x.length; i++) {
		validate = x[i].getAttribute('validate')
		if(validate) {
			var re = new RegExp('^'+validate+'$');
			if(!x[i].value.match(re)) {
				$(x[i].id).addClassName('error')
				message = x[i].getAttribute('error')
				if(message) { errors.push(message) }
				else        { errors.push('There was an error with '+x[i].name) }
			}
		}
	}
	if(errors.length > 0) {
		if(errors.length == 1) {
			var error_text = errors[0]
		}
		else {
			error_text = '<ul>'
			for(var i=0; i<errors.length; i++) {
				error_text += '<li>'+errors[i]+'</li>'
			}
			error_text += '</ul>'
		}
		$('errors').replace('<div id="errors" style="display:none">'+error_text+'</div>')
		new Effect.BlindDown($('errors'), {duration:0.3})
		return false
	}
	return true
}

// This function takes the id of a form and looks for 'enabled_when_checked' attributes
// on each of its fields.  For those fields that have dependents
// it adds a listener to ensure that updateDependents runs each time the value
// of these fields changes
function registerDependencies(formName) {
	var x = document.forms[formName].elements
	for(var i=0; i<x.length; i++) {
		parentID = x[i].getAttribute('enabled_when_checked')
		if(parentID != null) {
			ids = parentID.split(' ')
			for(var j=0; j<ids.length; j++) {
				parentObj = $(ids[j])
				var groupName = parentObj.name
				if(groupName) {
					group = document.getElementsByName(groupName)
					for(var k=0; k<group.length; k++) {
						group[k].onclick = function() { updateDependents(this) }
						updateDependents(group[k])
					}
				}
			}
		}
	}
}

// This function takes the id of a form element and looks for form elements on the page
// with enabled_when_checked="[parent]".  For each of these, it checks to
// see whether the parent is 'checked' and disables/enables the children
// appropriately.  
function updateDependents(object) {
	groupName = object.name
	types = new Array('input','select','textarea')
	for(var n=0; n<types.length; n++) {
		elements = document.getElementsByTagName(types[n])
		if(groupName) {
			group = document.getElementsByName(groupName)
			for(var i=0; i<group.length; i++) {
				for(var j=0; j<elements.length; j++) {
					elem = elements[j]
					parentID = elem.getAttribute('enabled_when_checked')
					if(parentID == group[i].id) {
						if($F(group[i].id)) { Form.Element.enable(elem) }
						else { Form.Element.disable(elem) }
					}
				}
			}
		}
	}
}

/**
/* TAKEN FROM http://xavisys.com/blog/2007/03/01 */
/* Many thanks, Aaron! */
/**
 * Returns the value of the selected radio button in the radio group
 *
 * @param {radio Object} or {radio id} el
 * OR
 * @param {form Object} or {form id} el
 * @param {radio group name} radioGroup
 */
function $RF(el, radioGroup) {
    if($(el).type == 'radio') {
        var el = $(el).form;
        var radioGroup = $(el).name;
    } else if ($(el).tagName.toLowerCase() != 'form') {
        return false;
    }
    return $F($(el).getInputs('radio', radioGroup).find(
        function(re) {return re.checked;}
    ));
}

