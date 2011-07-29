package liquid.tags {
  import liquid.Block;
  import liquid.Context;

  public class Ifchanged extends Block {

    public function Ifchanged(tagName:String, markup:String, tokens:Array) {
      super(tagName, markup, tokens);
    }
            
    override public function render(context:Context):* {
      return context.stack(null, function():* {
        var output:String = renderAll(_nodelist, context);

        if (output != context.registers['ifchanged']) {
          context.registers['ifchanged'] = output;
          return output;
        } else {
          return '';
        }
      });
    }
  }
}

