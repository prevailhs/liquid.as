package liquid {
  import flash.utils.getQualifiedClassName;

  import liquid.errors.ArgumentError;

  /**
   * Container for liquid nodes which conveniently wraps decision making logic
   *
   * Example:
   *
   *   c = Condition.new('1', '==', '1')
   *   c.evaluate  *=> true
   *
   */
  public class Condition {
    // TODO Should this be a Dictionary?
    private static var _operators:Object = {
      "==": function(cond:Condition, left:*, right:*):Boolean { return cond.equalVariables(left, right); },
      "!=": function(cond:Condition, left:*, right:*):Boolean { return !cond.equalVariables(left, right); },
      "<>": function(cond:Condition, left:*, right:*):Boolean { return !cond.equalVariables(left, right); },
      // For AS3 just sending the symbol/string '<' doesn't work, so we define explicit functions; see interpretConditions
      '<': function(cond:Condition, left:*, right:*):Boolean { return (left == null || right == null) ? false : left < right; },
      '>': function(cond:Condition, left:*, right:*):Boolean { return (left == null || right == null) ? false : left > right; },
      '>=': function(cond:Condition, left:*, right:*):Boolean { return (left == null || right == null) ? false : left >= right; },
      '<=': function(cond:Condition, left:*, right:*):Boolean { return (left == null || right == null) ? false : left <= right; },
      'contains': function(cond:Condition, left:*, right:*):Boolean { return left && right ? left.indexOf(right) >= 0 : false; }
    }

    public static function get operators():Object { return _operators; }

    private var _left:String;
    private var _operator:String;
    private var _right:String;
    private var _childRelation:String;
    private var _childCondition:Condition;
    private var _attachment:Array;

    public function get attachment():Array { return _attachment; }

    public function Condition(left:String = null, operator:String = null, right:String = null) {
      _left = left;
      _operator = operator;
      _right = right;
      _childRelation = null;
      _childCondition = null;
    }

    public function evaluate(context:Context = null):Boolean {
      if (!context) context = new Context();

      var result:Boolean = interpretCondition(_left, _right, _operator, context);

      switch(_childRelation) {
        case 'or': {
          return result || _childCondition.evaluate(context);
        }
        case 'and': {
          return result && _childCondition.evaluate(context);
        }
        default: {
          return result;
        }
      }
    }

    public function or(condition:Condition):void {
      _childRelation = 'or';
      _childCondition = condition;
    }

    public function and(condition:Condition):void {
      _childRelation = 'and';
      _childCondition = condition;
    }

    public function attach(attachment:Array):Array {
      _attachment = attachment;
      return _attachment
    }

    public function get isElse():Boolean { return false; }

    public function toString():String {
      // TODO Format this object like toString instead of ruby's inspect
      return "#<Condition " + Liquid.compact([_left, _operator, _right]).join(' ') + ">";
    }

    private function equalVariables(left:*, right:*):Boolean {

      // Check if we're a function to apply, like empty
      // NOTE This replaces symbols for ruby, see Context::LITERALS
      if (left is Function) {
        return left.call(this, right);
      }

      if (right is Function) {
        return right.call(this, left);
      }

      return left == right;
    }

    private function interpretCondition(left:*, right:*, op:String, context:Context):* {
      // If the operator is empty this means that the decision statement is 
      // just
      // a single variable. We can just poll this variable from the context and
      // return this as the result.
      if (!op) return context.getItem(left);

      left = context.getItem(left);
      right = context.getItem(right);

      var operation:* = _operators[op];
      if (!operation) throw new liquid.errors.ArgumentError("Unknown operator " + op);

      if (operation is Function) {
        return operation(this, left, right);
        // NOTE This doesn't work in AS3 for things like '<';
        // leave here for other custom functions, but above we have explicit functions for those operators
      } else if (left && operation in left && right && operation in right) {
        return left[operation](right);
      } else {
        return null;
      }
    }
  }
}
