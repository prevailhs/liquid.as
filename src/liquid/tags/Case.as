package liquid.tags {
  import liquid.Block;
  import liquid.Condition;
  import liquid.Context;
  import liquid.ElseCondition;
  import liquid.errors.SyntaxError;

  public class Case extends Block {
    /* /(#{QuotedFragment})/ */
    private static const Syntax:RegExp = Liquid.combineRegExp("(", Liquid.QuotedFragment, ")");
    /* /(#{QuotedFragment})(?:(?:\s+or\s+|\s*\,\s*)(#{QuotedFragment}.*))?/ */
    private static const WhenSyntax:RegExp = Liquid.combineRegExp("(", Liquid.QuotedFragment, ")(?:(?:\\s+or\\s+|\\s*\\,\\s*)(", Liquid.QuotedFragment, ".*))?");

    private var _left:String;
    private var _blocks:Array;

    public function Case(tagName:String, markup:String, tokens:Array) {
      _blocks = [];

      var matches:Array = markup.match(Syntax);
      if (matches) {
        _left = matches[1];
        super(tagName, markup, tokens);
      } else {
        throw new liquid.errors.SyntaxError("Syntax Error in tag 'case' - Valid syntax: case [condition]");
      }
    }

    override public function unknownTag(tag:String, markup:String, tokens:Array):void {
      _nodelist = [];
      switch(tag) {
        case 'when': {
          recordWhenCondition(markup);
          break;
        }
        case 'else': {
          recordElseCondition(markup);
          break;
        }
        default: {
          super.unknownTag(tag, markup, tokens);
          break;
        }
      }
    }

    override public function render(context:Context):* {
      return context.stack(null, function():* {
        var executeElseBlock:Boolean = true;

        var output:Array = [];
        for each (var block:Condition in _blocks) {
          if (block.isElse) {
            if (executeElseBlock) return renderAll(block.attachment, context);
          } else if (block.evaluate(context)) {
            executeElseBlock = false;
            output += renderAll(block.attachment, context);
          }
        }

        return output;
      });
    }

    
    private function recordWhenCondition(markup:String):void {
      while (markup) {
        // Create a new nodelist and assign it to the new block
        var matches:Array = markup.match(WhenSyntax);
        if (!matches) {
          throw new liquid.errors.SyntaxError("Syntax Error in tag 'case' - Valid when condition: {% when [condition] [or condition2...] %} ");
        }

        markup = matches[2];

        var block:Condition = new Condition(_left, '==', matches[1]);
        block.attach(_nodelist);
        _blocks.push(block);
      }
    }

    private function recordElseCondition(markup:String):void {
      if (!Liquid.empty(Liquid.trim(markup))) {
        throw new liquid.errors.SyntaxError("Syntax Error in tag 'case' - Valid else condition: {% else %} (no parameters) ");
      }
         
      var block:Condition = new ElseCondition();
      block.attach(_nodelist);
      _blocks.push(block);
    }
  }
}

