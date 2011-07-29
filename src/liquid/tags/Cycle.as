package liquid.tags {
  import liquid.Context;
  import liquid.Tag
  import liquid.errors.SyntaxError;

  /**
   * Cycle is usually used within a loop to alternate between values, like 
   * colors or DOM classes.
   *
   *   {% for item in items %}
   *     <div class="{% cycle 'red', 'green', 'blue' %}"> {{ item }} </div>
   *   {% end %}
   *
   *    <div class="red"> Item one </div>
   *    <div class="green"> Item two </div>
   *    <div class="blue"> Item three </div>
   *    <div class="red"> Item four </div>
   *    <div class="green"> Item five</div>
   *
   */
  public class Cycle extends Tag {
    /* /^#{QuotedFragment}+/ */
    private static const SimpleSyntax:RegExp = Liquid.combineRegExp("^", Liquid.QuotedFragment, "+");
    /* /^(#{QuotedFragment})\s*\:\s*(.*)/ */
    private static const NamedSyntax:RegExp = Liquid.combineRegExp("^(", Liquid.QuotedFragment, ")\\s*\\:\\s*(.*)");

    private var _name:String;
    private var _variables:Array;

    public function Cycle(tagName:String, markup:String, tokens:Array) {
      var success:Boolean = false;
      var matches:Array = markup.match(NamedSyntax);
      if (matches) {
        _variables = variablesFromString(matches[2]);
        _name = matches[1];
        success = true;
      } else {
        matches = markup.match(SimpleSyntax);
        if (matches) {
          _variables = variablesFromString(markup);
          _name = "'" + _variables.toString() + "'";
          success = true;
        }
      }
      
      if (success)
        super(tagName, markup, tokens);
      else
        throw new liquid.errors.SyntaxError("Syntax Error in 'cycle' - Valid syntax: cycle [name :] var [, var2, var3 ...]");
    }
  
    override public function render(context:Context):* {
      if (!context.registers['cycle']) context.registers['cycle'] = {};
    
      return context.stack(null, function():* {
        var key:String = context.getItem(_name);
        var iteration:Number = context.registers['cycle'][key];
        // AS3 can't initialize all missing hash values to 0, so detect and 
        // set to 0 here
        if (isNaN(iteration)) iteration = 0;
        var result:String = context.getItem(_variables[iteration]);
        iteration++;
        if (iteration >= _variables.length) iteration = 0;
        context.registers['cycle'][key] = iteration;
        return result;
      });
    }
      
    private function variablesFromString(markup:String):Array {
      return Liquid.compact(markup.split(',').map(function(item:*, index:int, array:Array):* {
        var matches:Array = item.match(Liquid.combineRegExp("\\s*(", Liquid.QuotedFragment, ")\\s*"));
        return matches ? matches[1] : null;
      }));
    }
  }
}

