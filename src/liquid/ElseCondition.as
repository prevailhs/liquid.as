package liquid {

  public class ElseCondition extends Condition {

    override public function get isElse():Boolean { return true; }

    override public function evaluate(context:Context = null):Boolean {
      return true;
    }
  }
}
