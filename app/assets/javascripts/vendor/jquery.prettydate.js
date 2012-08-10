/*
 * jQuery pretty date plug-in 1.0.0
 *
 * http://bassistance.de/jquery-plugins/jquery-plugin-prettydate/
 *
 * Based on John Resig's prettyDate http://ejohn.org/blog/javascript-pretty-date
 *
 * Copyright (c) 2009 Jörn Zaefferer
 *
 * $Id: jquery.validate.js 6096 2009-01-12 14:12:04Z joern.zaefferer $
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */

(function() {

$.prettyDate = {

	template: function(source, params) {
		if ( arguments.length == 1 )
			return function() {
				var args = $.makeArray(arguments);
				args.unshift(source);
				return $.prettyDate.template.apply( this, args );
			};
		if ( arguments.length > 2 && params.constructor != Array  ) {
			params = $.makeArray(arguments).slice(1);
		}
		if ( params.constructor != Array ) {
			params = [ params ];
		}
		$.each(params, function(i, n) {
			source = source.replace(new RegExp("\\{" + i + "\\}", "g"), n);
		});
		return source;
	},

	now: function() {
		return new Date();
	},

	// Takes an ISO time and returns a string representing how
	// long ago the date represents.
	format: function(time) {
		var date = new Date((time || "").replace(/-/g,"/")),
			diff = ($.prettyDate.now().getTime() - date.getTime()) / 1000,
			day_diff = Math.floor(diff / 86400);

		if ( isNaN(day_diff) || day_diff < 0 || day_diff >= 31 )
			return;

		var messages = $.prettyDate.messages;
		return day_diff == 0 && (
				diff < 60 && messages.now ||
				diff < 120 && messages.minute ||
				diff < 3600 && messages.minutes(Math.floor( diff / 60 )) ||
				diff < 7200 && messages.hour ||
				diff < 86400 && messages.hours(Math.floor( diff / 3600 ))) ||
			day_diff == 1 && messages.yesterday ||
			day_diff < 7 && messages.days(day_diff) ||
			day_diff < 31 && messages.weeks(Math.ceil( day_diff / 7 ));
	},

	localise: function(time, format) {

		var shortDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
      shortMonths = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      months  = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

	  var pad = function(num) {
	    var string = num.toString(10);
	    return new Array((2 - string.length) + 1).join('0') + string;
	  };

	  var strftime = function(date, format) {
	    var day = date.getDay(), month = date.getMonth();
	    var hours = date.getHours(), minutes = date.getMinutes();

	    return format.replace(/\%([aAbBcdHImMpSwyY])/g, function(part) {
	      switch(part[1]) {
	        case 'a': return shortDays[day]; break;
	        case 'A': return days[day]; break;
	        case 'b': return shortMonths[month]; break;
	        case 'B': return months[month]; break;
	        case 'c': return date.toString(); break;
	        case 'd': return pad(date.getDate()); break;
	        case 'H': return pad(hours); break;
	        case 'I': return ((hours + 12) % 12); break;
	        case 'm': return pad(month + 1); break;
	        case 'M': return pad(minutes); break;
	        case 'p': return hours > 12 ? 'pm' : 'am'; break;
	        case 'S': return pad(date.getSeconds()); break;
	        case 'w': return day; break;
	        case 'y': return pad(date.getFullYear() % 100); break;
	        case 'Y': return date.getFullYear().toString(); break;
	      }
    	});
	  }

	  if (format) {
   		return strftime(new Date(time), format);
	  } else {
	  	 return new Date(time); //Converting to local time on the client *appears* to be just a matter of creating a new date from a GMT string.
	  }

	}

};

$.prettyDate.messages = {
	now: "just now",
	minute: "1 minute ago",
	minutes: $.prettyDate.template("{0} minutes ago"),
	hour: "1 hour ago",
	hours: $.prettyDate.template("{0} hours ago"),
	yesterday: "Yesterday",
	days: $.prettyDate.template("{0} days ago"),
	weeks: $.prettyDate.template("{0} weeks ago")
};

$.fn.localiseTime	= function(options) {
	options = $.extend({
		format: null
	}, options);

	return this.text(function(){
		return $.prettyDate.localise($(this).text(), options.format);
	});
}

$.fn.prettyDate = function(options) {
	options = $.extend({
		value: function() {
			return $(this).attr("title");
		},
		localise: true,
		interval: 10000,
		format: null
	}, options);
	var elements = this;

	function format(init) {
		var pad = function(n) {
			return ("0" + n).slice(-2);
		}

		elements.each(function() {
			var date;
			if (init && options.localise) {
				var localTime = $.prettyDate.localise(options.value.apply(this), options.format);
				$(this).attr('title', localTime).text(localTime.getDate() + "/" +  localTime.getMonth() + "/" +  localTime.getFullYear() + ', ' + pad(localTime.getHours()) + ':' + pad(localTime.getMinutes())) //Localise the time stored in the attribute on the first pass
				date = $.prettyDate.format(options.value.apply(this));
			} else {
				date = $.prettyDate.format(options.value.apply(this));
			}

			if ( date && $(this).text() != date ) {
				$(this).text( date );
			}
		});
	}

	format(true);

	if (options.interval)
		setInterval(format(false), options.interval);
	return this;
};


})();