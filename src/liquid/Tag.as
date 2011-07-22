package liquid {
  import flash.utils.getQualifiedClassName;

  public class Tag {
    protected var _tagName:String;
    private var _markup:String;
    protected var _nodelist:Array;

    public function get nodelist():Array { return _nodelist; }

    // NOTE Added in defaults so that we can have empty constructor for sub-classes
    public function Tag(tagName:String=null, markup:String=null, tokens:Array=null) {
      _tagName = tagName;
      _markup = markup;
      if (tokens) parse(tokens);
    }

    public function parse(tokens:Array):void {
    }

    public function get name():String {
      // FIXME Downcase this
      return getQualifiedClassName(this);
    }

    public function render(context:Context):* {
      return '';
    }
  }
}
