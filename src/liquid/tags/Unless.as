package liquid.tags {
  import liquid.Condition;
  import liquid.Context;

  /**
   * Unless is a conditional just like 'if' but works on the inverse logic.
   *
   *   {% unless x < 0 %} x is greater than zero {% end %}
   *
   */
  public class Unless extends If {

    public function Unless(tagName:String, markup:String, tokens:Array) {
      super(tagName, markup, tokens);
    }

    override public function render(context:Context):* {
      return context.stack(null, function():* {
        // First condition is interpreted backwards ( if not )
        var block:Condition = Liquid.first(_blocks);
        if (!block.evaluate(context)) {
          return renderAll(block.attachment, context);
        }
        
        // After the first condition unless works just like if
        for each (block in _blocks.slice(1)) {
          if (block.evaluate(context)) {
            return renderAll(block.attachment, context);
          }
        }

        return '';
      });
    }
  }
}

