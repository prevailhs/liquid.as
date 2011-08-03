package liquid {

//require 'cgi'
  import flash.utils.getQualifiedClassName;
  
  import liquid.errors.LiquidError;


  public class StandardFilters {
    internal static const TableForEscapeHTML:Object = { '&': '&amp;', '"': '&quot;', '<': '&lt;', '>': '&gt;' };
    internal static const HTMLEscape:Object = { '&': '&amp;',  '>': '&gt;',   '<': '&lt;', '"': '&quot;' };

    // Return the size of an array or of an string
    public static function size(input:*):* {
      return input ? ('size' in input) ? input.size : ('length' in input) ? input.length : 0 : 0;
    }

    // convert a input string to DOWNCASE
    public static function downcase(input:*):* {
      return input ? input.toString().toLowerCase() : '';
    }

    // convert a input string to UPCASE
    public static function upcase(input:*):* {
      return input ? input.toString().toUpperCase() : '';
    }

    // capitalize words in the input centence
    public static function capitalize(input:*):* {
      return Liquid.capitalize(input.toString());
    }

    public static function escape(input:*):* {
      return input.toString().replace(/[&\"<>]/g, function():String { return TableForEscapeHTML[arguments[0]]; });
    }

    public static function escape_once(input:*):* {
      // TODO Do whatever ActiveSupport::Multibyte.clean does
      return input.toString().replace(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/g, function():String { return HTMLEscape[arguments[0]]; });
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
      var wordlist:Array = input.toString().split(' ');
      var l:int = words - 1;
      if (l < 0) l = 0;
      return (wordlist.length > l) ? wordlist.slice(0, l+1).join(' ') + truncateString : input;
    }

    public static function strip_html(input:*):* {
      return input ? input.toString().replace(/<script.*?<\/script>/g, '').replace(/<.*?>/g, '') : '';
    }

    // Remove all newlines from the string
    public static function strip_newlines(input:*):* {
      return input.toString().replace(/\n/g, '');
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
      } else if (property in Liquid.first(ary) && Liquid.first(ary)[property]) {
        return ary.sortOn(property);
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
      // Use split/join cause we don't want to turn '.' into a regexp
      return input.toString().split(string).join(replacement);
    }

    // Replace the first occurrences of a string with another
    public static function replace_first(input:*, string:String, replacement:String = ''):* {
      return input.toString().replace(string, replacement);
    }

    // remove a substring
    public static function remove(input:*, string:String):* {
      // Use split/join cause we don't want to turn '.' into a regexp
      return input.toString().split(string).join('');
    }

    // remove the first occurrences of a substring
    public static function remove_first(input:*, string:String):* {
      return input.toString().replace(string, '');
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
      return input.toString().replace(/\n/g, "<br />\n");
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
      var a:* = toNumber(input);
      var b:* = toNumber(operand);
      return a + b;
    }

    // subtraction
    public static function minus(input:*, operand:*):* {
      var a:* = toNumber(input);
      var b:* = toNumber(operand);
      return a - b;
    }

    // multiplication
    public static function times(input:*, operand:*):* {
      var a:* = toNumber(input);
      var b:* = toNumber(operand);
      return a * b;
    }

    // division
    public static function divided_by(input:*, operand:*):* {
      var a:* = toNumber(input);
      var b:* = toNumber(operand);
      var n:Number = (a is int && b is int) ? Math.floor(a/b) : a/b;
      if (!isFinite(n)) throw new liquid.errors.LiquidError("divided by 0");
      return n;
    }

    private static function toNumber(obj:*):* {
      if (obj is Number) {
        return obj;
      } else if (obj is String) {
        var isFloat:Boolean = /^\d+\.\d+$/.test(Liquid.trim(obj));
        // FIXME parseFloat('2.0') returns type int, when we want type float
        var n:Number = isFloat ? parseFloat(obj) : parseInt(obj);
        return isNaN(n) ? 0 : n;
      } else {
        return 0;
      }
    }
  }
}

