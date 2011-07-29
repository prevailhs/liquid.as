package liquid.tags {
  import liquid.Block;
  import liquid.Context;

  public class Comment extends Block {

    public function Comment(tagName:String, markup:String, tokens:Array) {
      super(tagName, markup, tokens);
    }

    override public function render(context:Context):* {
      return '';
    }
  }
}

