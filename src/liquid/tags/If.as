package liquid.tags {
  import liquid.Block;
  import liquid.Condition
  import liquid.Context;
  import liquid.ElseCondition
  import liquid.errors.SyntaxError;

  /**
   * If is the conditional block
   *
   *   {% if user.admin %}
   *     Admin user!
   *   {% else %}
   *     Not admin user
   *   {% endif %}
   *
   *    There are {% if count < 5 %} less {% else %} more {% endif %} items than you need.
   *
   */
  public class If extends Block {
    private static const SyntaxHelp:String = "Syntax Error in tag 'if' - Valid syntax: if [expression]";
    /* /(#{QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{QuotedFragment})?/ */
    private static const Syntax:RegExp = Liquid.combineRegExp("(", Liquid.QuotedFragment, ")\\s*([=!<>a-z_]+)?\\s*(", Liquid.QuotedFragment, ")?");
    /* /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{QuotedFragment}|\S+)\s*)+)/ */
    private static const ExpressionsAndOperators:RegExp = Liquid.combineRegExp("(?:\\b(?:\\s?and\\s?|\\s?or\\s?)\\b|(?:\\s*(?!\\b(?:\\s?and\\s?|\\s?or\\s?)\\b)(?:", Liquid.QuotedFragment, "|\\S+)\\s*)+)");

    private var _blocks:Array;

    public function If(tagName:String, markup:String, tokens:Array) {
      _blocks = [];
      pushBlock('if', markup);
      super(tagName, markup, tokens);
    }

    override public function unknownTag(tag:String, markup:String, tokens:Array):void {
      if (['elsif', 'else'].indexOf(tag) >= 0) {
        pushBlock(tag, markup);
      } else {
        super.unknownTag(tag, markup, tokens);
      }
    }

    override public function render(context:Context):* {
      return context.stack(null, function():* {
        for each (var block:Condition in _blocks) {
          if (block.evaluate(context)) {
            return renderAll(block.attachment, context);
          }
        }
        return '';
      });
    }


    // TODO DRY up this code into a do-while loop or something
    private function pushBlock(tag:String, markup:String):void {
      var block:Condition;
      if (tag == 'else') {
        block = new ElseCondition();
      } else {
        var expressions:Array = Liquid.scan(markup, ExpressionsAndOperators).reverse();
        var expression:String = expressions.shift();
        var matches:Array = expression ? expression.match(Syntax) : null;
        if (!matches) throw new liquid.errors.SyntaxError(SyntaxHelp);

        var condition:Condition = new Condition(matches[1], matches[2], matches[3]);

        while (expressions.length > 0) {
          expression = expressions.shift();
          expression = expression ? expression.toString() : '';
          var operator:String = Liquid.trim(expression);

          expression = expressions.shift();
          expression = expression ? expression.toString() : '';
          matches = expression.match(Syntax);
          if (!matches) throw new liquid.errors.SyntaxError(SyntaxHelp);

          var newCondition:Condition = new Condition(matches[1], matches[2], matches[3]);
          newCondition[operator](condition);
          condition = newCondition;
        }

        block = condition;
      }

      _blocks.push(block);
      _nodelist = block.attach([]);
    }
  }
}
