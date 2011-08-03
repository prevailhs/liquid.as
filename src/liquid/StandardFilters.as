package liquid {

//require 'cgi'


  public class StandardFilters {

    // Return the size of an array or of an string
    public static function size(input:*):* {
      return ('size' in input) ? input.size : ('length' in input) ? input.length : 0;
    }

    // convert a input string to DOWNCASE
    public static function downcase(input:*):* {
      return input.toString.toLowerCase();
    }

    // convert a input string to UPCASE
    public static function upcase(input:*):* {
      return input.toString().toUpperCase();
    }

    // capitalize words in the input centence
    public static function capitalize(input:*):* {
      return Liquid.capitalize(input.toString());
    }

    public static function escape(input:*):* {
      //CGI.escapeHTML(input:*) rescue input
      return escape(input);
    }

    public static function escape_once(input:*):* {
      //ActionView::Helpers::TagHelper.escape_once(input:*) rescue input
    }

    public static function h(input:*): * { return escape(input); }

    // Truncate a string down to x characters
    public static function truncate(input:*, length:int = 50, truncateString:String = "..."):* {
      if (!input) return null;
      var l:int = length - truncateString.length;
      if (l < 0) l = 0;
      return (input.length > length) ? input.slice(0, l) + truncateString : input;
    }

    public static function truncatewords(input:*, words:int = 15, truncateString:String = "..."):* {
      if (!input) return null;
      var wordlist:Array = input.toString().split();
      var l:int = words - 1;
      if (l < 0) l = 0;
      return (wordlist.length > l) ? wordlist.slice(0, l).join(' ') + truncateString : input;
    }

    public static function strip_html(input:*):* {
      return input.toString().replace(/<script.*?<\/script>/g, '').replace(/<.*?>/g, '');
    }

    // Remove all newlines from the string
    public static function strip_newlines(input:*):* {
      return input.toString().replace(/\n/, '');
    }

    // Join elements of the array with certain character between them
    public static function join(input:*, glue:String = ' '):* {
      return Liquid.flatten([input]).join(glue);
    }

    // Sort elements of the array
    // provide optional property with which to sort an array of hashes or drops
    public static function sort(input:*, property:String = null):* {
      var ary:Array = Liquid.flatten([input]);
      if (!property) {
        return ary.sort();
      //elsif ary.first.respond_to?('[]') and !ary.first[property].null?
      } else if (property in Liquid.first(ary) && Liquid.first(ary)[property]) {
        // FIXME Implement
        //ary.sort {|a,b| a[property] <=> b[property] }
      //elsif ary.first.respond_to?(property)
      } else if (property in Liquid.first(ary)) {
        // FIXME Implement
        //ary.sort {|a,b| a.send(property) <=> b.send(property) }
      }
    }

    // map/collect on a given property
    public static function map(input:*, property:String):* {
      var ary:Array = Liquid.flatten([input]);
      //if ary.first.respond_to?('[]') and !ary.first[property].null?
      if (property in Liquid.first(ary) && Liquid.first(ary)[property]) {
        return ary.map(function(e:*, index:int, array:Array):* { return e[property]; });
      //elsif ary.first.respond_to?(property)
      } else if (property in Liquid.first(ary)) {
        //ary.map {|e| e.send(property) }
        return ary.map(function(e:*, index:int, array:Array):* { return e[property]; });
      }
    }

    // Replace occurrences of a string with another
    public static function replace(input:*, string:String, replacement:String = ''):* {
      return input.toString().replace(string, replacement);
    }

    // Replace the first occurrences of a string with another
    public static function replace_first(input:*, string:String, replacement:String = ''):* {
      return input.toString().sub(string, replacement);
    }

    // remove a substring
    public static function remove(input:*, string:String):* {
      return input.toString().replace(string, '');
    }

    // remove the first occurrences of a substring
    public static function remove_first(input:*, string:String):* {
      return input.toString().sub(string, '');
    }

    // add one string to another
    public static function append(input:*, string:String):* {
      return input.toString() + string.toString();
    }

    // prepend a string to another
    public static function prepend(input:*, string:String):* {
      return string.toString() + input.toString();
    }

    // Add <br /> tags in front of all newlines in input string
    public static function newline_to_br(input:*):* {
      return input.toString().replace(/\n/, "<br />\n");
    }

    /**
     * Reformat a date
     *
     *   %a - The abbreviated weekday name (``Sun'')
     *   %A - The  full  weekday  name (``Sunday'')
     *   %b - The abbreviated month name (``Jan'')
     *   %B - The  full  month  name (``January'')
     *   %c - The preferred local date and time representation
     *   %d - Day of the month (01..31)
     *   %H - Hour of the day, 24-hour clock (00..23)
     *   %I - Hour of the day, 12-hour clock (01..12)
     *   %j - Day of the year (001..366)
     *   %m - Month of the year (01..12)
     *   %M - Minute of the hour (00..59)
     *   %p - Meridian indicator (``AM''  or  ``PM'')
     *   %S - Second of the minute (00..60)
     *   %U - Week  number  of the current year,
     *           starting with the first Sunday as the first
     *           day of the first week (00..53)
     *   %W - Week  number  of the current year,
     *           starting with the first Monday as the first
     *           day of the first week (00..53)
     *   %w - Day of the week (Sunday is 0, 0..6)
     *   %x - Preferred representation for the date alone, no time
     *   %X - Preferred representation for the time alone, no date
     *   %y - Year without a century (00..99)
     *   %Y - Year with century
     *   %Z - Time zone name
     *   %% - Literal ``%'' character
     */
    public static function date(input:*, format:String):* {
      try {
        if (Liquid.empty(format.toString())) {
          return input.toString();
        }

        var date:Date;
        if (input is String) {
          date = new Date(Date.parse(input));
        } else if (input is Date) {
          date = input;
        } else {
          return input;
        }

        // FIXME How to format this here
        return '';
        //return date.strftime(format.toString());
      } catch (e:Error) {
        return input;
      }
    }

    /**
     * Get the first element of the passed in array
     *
     * Example:
     *    {{ product.images | first | to_img }}
     *
     */
    public static function first(array:Array):* {
      return (array is Array) ? Liquid.first(array) : null;
    }

    /**
     * Get the last element of the passed in array
     *
     * Example:
     *    {{ product.images | last | to_img }}
     *
     */
    public static function last(array:Array):* {
      return (array is Array) ? Liquid.last(array) : null;
    }

    // addition
    public static function plus(input:*, operand:*):* {
      return toNumber(input) + toNumber(operand);
    }

    // subtraction
    public static function minus(input:*, operand:*):* {
      return toNumber(input) - toNumber(operand);
    }

    // multiplication
    public static function times(input:*, operand:*):* {
      return toNumber(input) * toNumber(operand);
    }

    // division
    public static function divided_by(input:*, operand:*):* {
      return toNumber(input) / toNumber(operand);
    }

    private static function toNumber(obj:*):* {
      if (obj is Number) {
        return obj;
      } else if (obj is String) {
        return (/^\d+\.\d+$/.test(Liquid.trim(obj))) ? parseFloat(obj) : parseInt(obj);
      } else {
        return 0;
      }
    }
  }
}

