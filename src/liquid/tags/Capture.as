package liquid.tags {
  import liquid.Block;
  import liquid.Context;
  import liquid.errors.SyntaxError;

  /**
   * Capture stores the result of a block into a variable without rendering it 
   * inplace.
   *
   *   {% capture heading %}
   *     Monkeys!
   *   {% endcapture %}
   *   ...
   *   <h1>{{ heading }}</h1>
   *
   * Capture is useful for saving content for use later in your template, such as
   * in a sidebar or footer.
   *
   */
  public class Capture extends Block {
    private static const Syntax:RegExp = /(\w+)/;

    private var _to:String;

    public function Capture(tagName:String, markup:String, tokens:Array) {
      var matches:Array = markup.match(Syntax);
      if (matches) {
        _to = matches[1];
        super(tagName, markup, tokens);
      } else {
        throw new liquid.errors.SyntaxError("Syntax Error in 'capture' - Valid syntax: capture [var]");
      }
    }

    override public function render(context:Context):* {
      var output:String = super.render(context);
      Liquid.last(context.scopes)[_to] = output;
      return '';
    }
  }
}
