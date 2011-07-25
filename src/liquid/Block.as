package liquid {
  import flash.utils.getQualifiedClassName;

  import liquid.errors.LiquidError;
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

    public function Block(tagName:String = null, markup:String = null, tokens:Array = null) {
      super(tagName, markup, tokens);
    }

    override public function parse(tokens:Array):void {
      // NOTE Don't just blindly re-initialize nodelist; inherited classes may 
      // share this through pointers; specifically If points _nodelist at the 
      // blocks attachment, so we need to leave that pointer to pickup stuff.
      if (!_nodelist) _nodelist = [];
      Liquid.clear(_nodelist);

      while (tokens.length > 0) {
        var token:String = tokens.shift();
        if (IsTag.test(token)) {
          var matches:Array = token.match(FullToken);
          if (matches) {
            // if we found the proper block delimitor just end parsing here and let the outer block
            // proceed
            if (blockDelimiter == matches[1]) {
              endTag();
              return;
            }

            // fetch the tag from registered blocks
            var tag:Class = Template.tags[matches[1]];
            if (tag) {
              _nodelist.push(new tag(matches[1], matches[2], tokens));
            } else {
              // this tag is not registered with the system
              // pass it to the current block for special handling or error reporting
              unknownTag(matches[1], matches[2], tokens);
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

    public function unknownTag(tag:String, markup:String, tokens:Array):void {
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
      if (vars.length == 1) return new Variable(Liquid.first(vars));

      throw new liquid.errors.SyntaxError("Variable '" + token + "' was not properly terminated with regexp: " + Liquid.VariableEnd.source);
    }

    override public function render(context:Context):* {
      return renderAll(_nodelist, context);
    }


    protected function assertMissingDelimitation():void {
      throw new liquid.errors.SyntaxError(blockName +" tag was never closed");
    }

    protected function renderAll(list:Array, context:Context):* {
      return list.map(function(token:*, index:int, array:Array):Object {
        try {
          return ('render' in token) ? token.render(context) : token;
        } catch (e:liquid.errors.LiquidError) {
          return context.handleError(e);
        }
        return 'ASSERT: Should not get here';
      }).join('');
    }
  }
}
