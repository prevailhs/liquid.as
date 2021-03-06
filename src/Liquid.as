/**
 * Copyright (c) 2005 Tobias Luetke
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package {
  import flash.display.Sprite;
  import flash.utils.getDefinitionByName;
  import flash.utils.getQualifiedClassName;

  import liquid.Template;
  import liquid.tags.*;

  public class Liquid extends Sprite {
    public static const FilterSeparator:RegExp            = /\|/;
    public static const ArgumentSeparator:String          = ',';
    public static const FilterArgumentSeparator:String    = ':';
    public static const VariableAttributeSeparator:String = '.';
    public static const TagStart:RegExp                   = /\{\%/;
    public static const TagEnd:RegExp                     = /\%\}/;
    public static const VariableSignature:RegExp          = /\(?[\w\-\.\[\]]\)?/;
    public static const VariableSegment:RegExp            = /[\w\-]/;
    public static const VariableStart:RegExp              = /\{\{/;
    public static const VariableEnd:RegExp                = /\}\}/;
    public static const VariableIncompleteEnd:RegExp      = /\}\}?/;
    public static const QuotedString:RegExp               = /"[^"]*"|'[^']*'/;
                                                          /* /#{QuotedString}|(?:[^\s,\|'"]|#{QuotedString})+/ */
    public static const QuotedFragment:RegExp             = combineRegExp(QuotedString, "|(?:[^\\s,\\|'\"]|", QuotedString, ")+");
    public static const StrictQuotedFragment:RegExp       = /"[^"]+"|'[^']+'|[^\s,\|,\:,\,]+/;
                                                          /* /#{FilterArgumentSeparator}(?:#{StrictQuotedFragment})/; */
    public static const FirstFilterArgument:RegExp        = combineRegExp(FilterArgumentSeparator, "(?:", StrictQuotedFragment, ")");
                                                          /* /#{ArgumentSeparator}(?:#{StrictQuotedFragment})/; */
    public static const OtherFilterArgument:RegExp        = combineRegExp(ArgumentSeparator, "(?:", StrictQuotedFragment, ")");
                                                          /* /^(?:'[^']+'|"[^"]+"|[^'"])*#{FilterSeparator}(?:#{StrictQuotedFragment})(?:#{FirstFilterArgument}(?:#{OtherFilterArgument})*)?/; */
    public static const SpacelessFilter:RegExp            = combineRegExp("^(?:'[^']+'|\"[^\"]+\"|[^'\"])*", FilterSeparator, "(?:", StrictQuotedFragment, ")(?:", FirstFilterArgument, "(?:", OtherFilterArgument, ")*)?");
                                                          /* /(?:#{QuotedFragment}(?:#{SpacelessFilter})*)/; */
    public static const Expression:RegExp                 = combineRegExp("(?:", QuotedFragment, "(?:", SpacelessFilter, ")*)");
                                                          /* /(\w+)\s*\:\s*(#{QuotedFragment})/; */
    public static const TagAttributes:RegExp              = combineRegExp("(\\w+)\\s*\\:\\s*(", QuotedFragment, ")");
    public static const AnyStartingTag:RegExp             = /\{\{|\{\%/;
                                                          /* /#{TagStart}.*?#{TagEnd}|#{VariableStart}.*?#{VariableIncompleteEnd}/; */
    public static const PartialTemplateParser:RegExp      = combineRegExp(TagStart, ".*?", TagEnd, "|", VariableStart, ".*?", VariableIncompleteEnd);
                                                          /* /(#{PartialTemplateParser}|#{AnyStartingTag})/; */
    public static const TemplateParser:RegExp             = combineRegExp("(", PartialTemplateParser, "|", AnyStartingTag, ")");
                                                          /* /\[[^\]]+\]|#{VariableSegment}+\??/; */
    public static const VariableParser:RegExp             = combineRegExp("\\[[^\\]]+\\]|", VariableSegment, "+\\??");
    public static const LiteralShorthand:RegExp           = /^(?:\{\{\{\s?)(.*?)(?:\s*\}\}\})$/;

    public function Liquid() {
      trace(">> Liquid Instantiated!");
    }

    // TODO Belongs on RegExp
    // Combines strings and regular expressions in the same way ruby does;
    //  uses (?-mix:{regexp}) when inserting regexps
    public static function combineRegExp(... args):RegExp {
      var regExpString:String = '';
      for each (var item:* in args) {
        if (item is RegExp) {
          regExpString += '(?-mix:' + (item as RegExp).source + ')';
        } else {
          regExpString += new RegExp(item).source;
        }
      }
      return new RegExp(regExpString);
    }

    // TODO Belongs on String
    public static function scan(str:String, regExpOrString:*):Array {
      var regString:String = (regExpOrString is RegExp) ? (regExpOrString as RegExp).source : regExpOrString;
      var globalRegExp:RegExp = new RegExp(regString, "g");

      var results:Array = [];
      var result:Array = globalRegExp.exec(str);
      while (result != null) {
        // TODO Is this the same behavior as ruby?  Make sure it does nested 
        // arrays correctly.
        if (result.length > 1) { // HACK, deeper match, nest arrays to be like ruby
          results.push(result.slice(1));
        } else { // Normal match, just push it
          results.push(result[0]);
        }
        result = globalRegExp.exec(str);
      }

      return results;
    }

    // TODO Belongs on String
    private static const Trim:RegExp = /(\A\s+|\s+\Z)/g;
    public static function trim(str:String):String {
      return str.replace(Liquid.Trim, '');
    }

    // TODO Belongs on String
    public static function capitalize(str:String):String {
      // TODO Consider if we want to trim left first
      return str.replace(/^(\w)/, function(char:String, ... args):String { return char.toUpperCase(); });
    }

    // TODO Belongs on String and Array
    public static function empty(strOrArr:*):Boolean {
      if (strOrArr is String) return !strOrArr || strOrArr.length == 0;
      if (strOrArr is Array) return strOrArr.length == 0;
      throw new Error("Cannot call empty on this item: ", getQualifiedClassName(strOrArr));
    }

    // TODO Belongs on Array
    public static function flatten(arr:Array):Array {
      var flattened:Array = [];
      for each (var item:* in arr) {
        if (item is Array) {
          flattened.push.apply(flattened, flatten(item));
        } else {
          flattened.push(item);
        }
      }
      return flattened;
    }

    // TODO Belongs on Array
    public static function compact(arr:Array):Array {
      return arr.filter(function(item:*, index:int, array:Array):Boolean {
        return !!item;
      });
    }

    // TODO Belongs on Array
    public static function first(arr:Array):* {
      return (arr.length > 0) ? arr[0] : null;
    }

    // TODO Belongs on Array
    public static function last(arr:Array):* {
      return (arr.length > 0) ? arr[arr.length-1] : null;
    }

    // TODO Belongs on Array
    public static function clear(arr:Array):void {
      //while (arr.length > 0) arr.pop();
      arr.length = 0;
    }

    // TODO Belongs on Array
    public static function deepJoin(arr:Array, sep:*=NaN):String {
      return Liquid.flatten(arr).join(sep);
    }

    // TODO Belongs on Object
    public static function merge(obj1:Object, obj2:Object):Object {
      var obj:Object = { };
      var k:String
      for (k in obj1) {
        obj[k] = obj1[k];
      }
      for (k in obj2) {
        obj[k] = obj2[k];
      }
      return obj;
    }

    // TODO Belongs on Object
    public static function mergeBang(obj1:Object, obj2:Object):Object {
      for (var k:String in obj2) {
        obj1[k] = obj2[k];
      }
      return obj1;
    }

    // TODO Belongs where?
    public static function getClass(obj:Object):Class {
      return Class(getDefinitionByName(getQualifiedClassName(obj)));
    }

    // Debug function
    public static function formatObject(obj:Object):String {
      var props:Array = [];
      for (var k:String in obj) {
        props.push(k + ': ' + obj[k]);
      }
      return props.join(', ');
    }
  }

  // TODO Would like to do something like this for all these helper functions
//  String.prototype.scan = function(pattern:*):Array {
//      var patternString:String = (pattern is RegExp) ? (pattern as RegExp).source : pattern;
//      return this.match(new RegExp(patternString, "g"));
//  }
}

  // TODO Why can't I register tags here, it causes wierd class issues
  //trace('Registering tags');
  //liquid.Template.registerTag('assign', liquid.tags.Assign);
  //liquid.Template.registerTag('if', liquid.tags.If);
  //liquid.Template.registerTag('unless', liquid.tags.Unless);
  //liquid.Template.registerTag('for', liquid.tags.For);
  //liquid.Template.registerTag('capture', liquid.tags.Capture);
  //liquid.Template.registerTag('ifchanged', liquid.tags.Ifchanged);
  //liquid.Template.registerTag('comment', liquid.tags.Comment);
  //liquid.Template.registerTag('cycle', liquid.tags.Cycle);
  //liquid.Template.registerTag('case', liquid.tags.Case);
  trace('Registering filters');
  liquid.Template.registerFilter(liquid.StandardFilters);
