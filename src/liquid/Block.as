package liquid {
  import flash.events.ContextMenuEvent;
  import flash.net.URLVariables;
  import liquid.errors.SyntaxError;

  public class Block extends Tag {

    /* /^#{TagStart}/ */
    private static const IsTag:RegExp             = Liquid.combineRegExp("^", Liquid.TagStart);
    /* /^#{VariableStart}/ */
    private static const IsVariable:RegExp        = Liquid.combineRegExp("^", Liquid.VariableStart);
    /* /^#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}$/ */
    private static const FullToken:RegExp         = Liquid.combineRegExp("^", Liquid.TagStart, "\\s*(\\w+)\\s*(.*)?", Liquid.TagEnd, "$");
    /* /^#{VariableStart}(.*)#{VariableEnd}$/ */
    private static const ContentOfVariable:RegExp = Liquid.combineRegExp("^", Liquid.VariableStart, "(.*)", Liquid.VariableEnd, "$");

    override public function parse(tokens:Array):void {
      _nodelist = [];

      var token:String;
      while (token = tokens.shift()) {
        if (IsTag.test(token)) {
          var match:Array = token.match(FullToken);
          if (match) {
            // if we found the proper block delimitor just end parsing here and let the outer block
            // proceed
            if (blockDelimiter == match[0]) {
              endTag();
              return;
            }

            // fetch the tag from registered blocks
            var tag:Class = Template.tags[match[0]];
            if (tag) {
              _nodelist.push(new tag(match[0], match[1], tokens));
            } else {
              // this tag is not registered with the system
              // pass it to the current block for special handling or error reporting
              unknownTag(match[0], match[1], tokens);
            }

          } else {
            throw new liquid.errors.SyntaxError("Tag '" + token + "' was not properly terminated with regexp: " + Liquid.TagEnd.source);
          }
        } else if (IsVariable.test(token)) {
          _nodelist.push(createVariable(token));
        } else if ('' == token) {
          // pass
        } else {
          _nodelist.push(token);
        }
      }

      // Make sure that its ok to end parsing in the current block.
      // Effectively this method will throw and exception unless the current block is
      // of type Document
      assertMissingDelimitation();
    }

    public function endTag():void {
    }

    public function unknownTag(tag:String, params:*, tokens:Array):void {
      switch(tag) {
        case 'else': {
          throw new liquid.errors.SyntaxError(blockName + "tag does not expect else tag");
          break;
        }
        case 'end': {
          throw new liquid.errors.SyntaxError("'end' is not a valid delimiter for " + blockName + " tags. use " + blockDelimiter);
          break;
        }
        default: {
          throw new liquid.errors.SyntaxError("Unknown tag '" + tag + "'");
          break;
        }
      }
    }

    public function get blockDelimiter():* {
      return "end" + blockName;
    }

    public function get blockName():String {
      return _tagName;
    }

    public function createVariable(token:String):Variable {
      // TODO Verify these behave the same
      //token.scan(ContentOfVariable) do |content|
        //return Variable.new(content.first)
      //end
      var vars:Array = Liquid.scan(token, ContentOfVariable);
      if (vars.length == 1) return new Variable(vars[0]);

      throw new liquid.errors.SyntaxError("Variable '" + token + "' was not properly terminated with regexp: " + Liquid.VariableEnd.source);
    }

    // TODO Use Context here when implemented
    // TODO Check return type
    override public function render(context:*):String {
      return renderAll(_nodelist, context);
    }


    protected function assertMissingDelimitation():void {
      throw new liquid.errors.SyntaxError(blockName +" tag was never closed");
    }

    // TODO Use Context here when implemented
    // TODO Check return type
    protected function renderAll(list:Array, context:*):String {
      return list.map(function(token:*, index:int, array:Array):Object {
        try {
          return ('render' in token) ? token.render(context) : token;
        } catch (e:Error) {
          return context.handleError(e);
        }
        return 'ASSERT: Should not get here';
      }).join('');
    }
  }
}
