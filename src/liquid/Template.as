package liquid {
  import liquid.errors.ArgumentError;
  import liquid.tags.*;

  /**
   * Templates are central to liquid.
   * Interpretating templates is a two step process. First you compile the
   * source code you got. During compile time some extensive error checking is performed.
   * your code should expect to get some SyntaxErrors.
   *
   * After you have a compiled template you can then <tt>render</tt> it.
   * You can use a compiled template over and over again and keep it cached.
   *
   * Example:
   *
   *   template = Liquid::Template.parse(source)
   *   template.render('user_name' => 'bob')
   */
  public class Template {
    private var _root:Document;
    private var _registers:Object = {};
    private var _assigns:Object = {};
    private var _instanceAssigns:Object = { };
    private var _errors:Array = [];
    private var _rethrowErrors:Boolean = false;

    // TODO Should this be a dictionary?
    private static var _tags:Object = { };

    //@@file_system = BlankFileSystem.new
//
    //class << self
      //def file_system
        //@@file_system
      //end
//
      //def file_system=(obj)
        //@@file_system = obj
      //end
//
    public static function registerTag(name:String, klass:Class):void {
      tags[name] = klass;
    }

    // TODO Should this be a dictionary?
    public static function get tags():Object { return _tags; }

    /**
     * Pass a module with filter methods which should be available
     * to all liquid views. Good for registering the standard library
     */
    public static function registerFilter(mod:Object):void {
      Strainer.globalFilter(mod);
    }

    /**
     * creates a new <tt>Template</tt> object from liquid source code
     */
    public static function parse(source:String):Template {
      var template:Template = new Template();
      template.parse(source);
      return template;
    }


    public function get root():Document { return _root; }

    private static var _tagsInitialized:Boolean = false;

    public function Template() {
      if (!_tagsInitialized) {
        // TODO Want to do this globally but it breaks there, why?
        trace('Registering tags');
        Template.registerTag('assign', liquid.tags.Assign);
        Template.registerTag('if', liquid.tags.If);
        Template.registerTag('unless', liquid.tags.Unless);
        Template.registerTag('for', liquid.tags.For);
        Template.registerTag('capture', liquid.tags.Capture);
        Template.registerTag('ifchanged', liquid.tags.Ifchanged);
        Template.registerTag('comment', liquid.tags.Comment);
        Template.registerTag('cycle', liquid.tags.Cycle);
        Template.registerTag('case', liquid.tags.Case);

        _tagsInitialized = true;
      }
    }

    /**
     * Parse source code.
     * Returns self for easy chaining
     */
    public function parse(source:String):Template {
      // TODO Verify this, newer code for liquid omits the Literal.from_shorthand
      //@root = Document.new(tokenize(Liquid::Literal.from_shorthand(source)))
      _root = new Document(tokenize(source));
      return this;
    }

    // TODO Should these be Dictionaries?
    public function get registers():Object { return _registers; }
    public function get assigns():Object { return _assigns; }
    public function set assigns(value:Object):void { _assigns = value; }
    public function get instanceAssigns():Object { return _instanceAssigns; }
    public function get errors():Array { return _errors; }

    /**
     * Render takes a hash with local variables.
     *
     * if you use the same filters over and over again consider registering them globally
     * with <tt>Template.register_filter</tt>
     *
     * Following options can be passed:
     * @param filters     Array with local filters
     * @param registers   Hash with register variables. Those can be accessed from
     *                    filters and tags and might be useful to integrate liquid more with its host application
     */
    public function render(... args):* {
      if (!_root) return '';

      var context:Context;
      var firstObj:* = Liquid.first(args);
      if (firstObj is Context) {
        context = args.shift();
      } else if (firstObj is Object) { // TODO Should this be a Dictionary? Ruby object is a Hash
        context = new Context([args.shift(), assigns], instanceAssigns, registers, _rethrowErrors);
      } else if (!firstObj) { // null
        context = new Context(assigns, instanceAssigns, registers, _rethrowErrors);
      } else {
        throw new liquid.errors.ArgumentError("Expect Hash or liquid.Context as parameter");
      }

      var lastObj:* = Liquid.last(args);
      if (lastObj is Object) { // TODO Should this be a Dictionary? Ruby object is a Hash
        // TODO Should this be a dictionary?
        var options:Object = args.pop();

        if (options['registers'] is Object) {
          this.registers.mergeBang(options['registers']);
        }

        if (options['filters']) {
          context.addFilters(options['filters']);
        }

        // TODO Is this okay to do this, seems like it always skips array, but
        // does the same thing anyway?
      } else if (lastObj is Object) {
        context.addFilters(args.pop());
      } else if (lastObj is Array) {
        context.addFilters(args.pop());
      }

      try {
        // render the nodelist.
        // for performance reasons we get a array back here. join will make a string out of it
        var result:* = _root.render(context);
        return ('join' in result) ? result.join('') : result;
      } finally {
        _errors = context.errors;
      }
    }

    //def render!(*args)
      //@rethrow_errors = true; render(*args)
    //end
//
    //private
//

    /**
     * Uses the <tt>Liquid::TemplateParser</tt> regexp to tokenize the passed source
     *
     * NOTE This was private in ruby, but we make it public to test it.
     */
    public function tokenize(source:*):Array {
      // TODO Want to do this ruby:
      //source = source.source if source.respond_to?(:source)
      if ('source' in source) source = source.source();
      if (source.toString() == '') return [];
      var tokens:Array = source.split(Liquid.TemplateParser);

      // removes the rogue empty element at the beginning of the array
      if (tokens.length > 0 && (tokens[0] == null || tokens[0] == '')) tokens.shift();
      // TODO Why is this necessary for AS3?
      // removes the rogue empty element at the end of the array
      if (tokens.length > 0 && (tokens[tokens.length-1] == null || tokens[tokens.length-1] == '')) tokens.pop();

      return tokens;
    }
  }
}
