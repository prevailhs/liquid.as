package liquid.tags {
  import liquid.Context;
  import liquid.Tag;

  import liquid.errors.SyntaxError;

  /**
   * Assign sets a variable in your template.
   *
   *   {% assign foo = 'monkey' %}
   *
   * You can then use the variable later in the page.
   *
   *  {{ foo }}
   *
   */
  public class Assign extends Tag {
    /* /(#{VariableSignature}+)\s*=\s*(#{QuotedFragment}+)/ */
    private const Syntax:RegExp = Liquid.combineRegExp("(", Liquid.VariableSignature, "+)\\s*=\\s*(", Liquid.QuotedFragment, "+)");

    private var _to:String;
    private var _from:String;

    public function Assign(tagName:String, markup:String, tokens:Array) {
      var matches:Array = markup.match(Syntax);
      if (matches) {
        _to = matches[1];
        _from = matches[2];
        super(tagName, markup, tokens);
      } else {
        throw new liquid.errors.SyntaxError("Syntax Error in 'assign' - Valid syntax: assign [var] = [source]");
      }
    }

    override public function render(context:Context):* {
      Liquid.last(context.scopes)[_to] = context.getItem(_from);
      return '';
    }
  }
}

