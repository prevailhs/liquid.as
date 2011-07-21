package liquid {

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

    public static function get tags():Object { return _tags; }

    //# Pass a module with filter methods which should be available
      //# to all liquid views. Good for registering the standard library
      //def register_filter(mod)
        //Strainer.global_filter(mod)
      //end
//
    /**
     * creates a new <tt>Template</tt> object from liquid source code
     */
    public static function parse(source:String):Template {
      var template:Template = new Template();
      template.parse(source);
      return template;
    }
    //end
//

    public function get root():Document { return _root; }

    //# creates a new <tt>Template</tt> from an array of tokens. Use <tt>Template.parse</tt> instead
    //def initialize
    //end
//

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

    //def registers
      //@registers ||= {}
    //end
//
    //def assigns
      //@assigns ||= {}
    //end
//
    //def instance_assigns
      //@instance_assigns ||= {}
    //end
//
    //def errors
      //@errors ||= []
    //end
//
    //# Render takes a hash with local variables.
    //#
    //# if you use the same filters over and over again consider registering them globally
    //# with <tt>Template.register_filter</tt>
    //#
    //# Following options can be passed:
    //#
    //#  * <tt>filters</tt> : array with local filters
    //#  * <tt>registers</tt> : hash with register variables. Those can be accessed from
    //#    filters and tags and might be useful to integrate liquid more with its host application
    //#
    //def render(*args)
      //return '' if @root.nil?
//
      //context = case args.first
      //when Liquid::Context
        //args.shift
      //when Hash
        //Context.new([args.shift, assigns], instance_assigns, registers, @rethrow_errors)
      //when nil
        //Context.new(assigns, instance_assigns, registers, @rethrow_errors)
      //else
        //raise ArgumentError, "Expect Hash or Liquid::Context as parameter"
      //end
//
      //case args.last
      //when Hash
        //options = args.pop
//
        //if options[:registers].is_a?(Hash)
          //self.registers.merge!(options[:registers])
        //end
//
        //if options[:filters]
          //context.add_filters(options[:filters])
        //end
//
      //when Module
        //context.add_filters(args.pop)
      //when Array
        //context.add_filters(args.pop)
      //end
//
      //begin
        //# render the nodelist.
        //# for performance reasons we get a array back here. join will make a string out of it
        //@root.render(context).join
      //ensure
        //@errors = context.errors
      //end
    //end
//
    //def render!(*args)
      //@rethrow_errors = true; render(*args)
    //end
//
    //private
//

    /**
     * Uses the <tt>Liquid::TemplateParser</tt> regexp to tokenize the passed source
     */
    private function tokenize(source:*):Array {
      // TODO Want to do this ruby:
      //source = source.source if source.respond_to?(:source)
      if ('source' in source) source = source.source();
      if (source.toString() == '') return [];
      var tokens:Array = source.split(Liquid.TemplateParser);

      // removes the rogue empty element at the beginning of the array
      if (tokens.length > 0 && (tokens[0] == null || tokens[0] == '')) tokens.shift();

      return tokens;
    }
  }
}