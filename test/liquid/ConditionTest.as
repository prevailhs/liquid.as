package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class ConditionTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;

    //private var instance:Condition;
    private var _sharedContext:Context;

    [Before]
    public function setUp():void {
      //instance = new Condition();
    }

    [After]
    public function tearDown():void {
      //instance = null;
      if (_sharedContext) _sharedContext = null;
    }

    [Test]
    public function shouldTestBasicCondition():void {
      assertFalse(new Condition('1', '==', '2').evaluate());
      assertTrue(new Condition('1', '==', '1').evaluate());
    }

    [Test]
    public function shouldTestDefaultOperatorsEvaluateTrue():void {
      assertEvaluatesTrue('1', '==', '1');
      assertEvaluatesTrue('1', '!=', '2');
      assertEvaluatesTrue('1', '<>', '2');
      assertEvaluatesTrue('1', '<', '2');
      assertEvaluatesTrue('2', '>', '1');
      assertEvaluatesTrue('1', '>=', '1');
      assertEvaluatesTrue('2', '>=', '1');
      assertEvaluatesTrue('1', '<=', '2');
      assertEvaluatesTrue('1', '<=', '1');
    }

    [Test]
    public function shouldTestDefaultOperatorsEvaluateFalse():void {
      assertEvaluatesFalse('1', '==', '2');
      assertEvaluatesFalse('1', '!=', '1');
      assertEvaluatesFalse('1', '<>', '1');
      assertEvaluatesFalse('1', '<', '0');
      assertEvaluatesFalse('2', '>', '4');
      assertEvaluatesFalse('1', '>=', '3');
      assertEvaluatesFalse('2', '>=', '4');
      assertEvaluatesFalse('1', '<=', '0');
      assertEvaluatesFalse('1', '<=', '0');
    }

    [Test]
    public function shouldTestContainsWorksOnStrings():void {
      assertEvaluatesTrue("'bob'", 'contains', "'o'");
      assertEvaluatesTrue("'bob'", 'contains', "'b'");
      assertEvaluatesTrue("'bob'", 'contains', "'bo'");
      assertEvaluatesTrue("'bob'", 'contains', "'ob'");
      assertEvaluatesTrue("'bob'", 'contains', "'bob'");

      assertEvaluatesFalse("'bob'", 'contains', "'bob2'");
      assertEvaluatesFalse("'bob'", 'contains', "'a'");
      assertEvaluatesFalse("'bob'", 'contains', "'---'");
    }

    [Test]
    public function shouldTestContainsWorksOnArrays():void {
      _sharedContext = new Context();
      _sharedContext.setItem('array', [1, 2, 3, 4, 5]);

      assertEvaluatesFalse("array",  'contains', '0');
      assertEvaluatesTrue("array",   'contains', '1');
      assertEvaluatesTrue("array",   'contains', '2');
      assertEvaluatesTrue("array",   'contains', '3');
      assertEvaluatesTrue("array",   'contains', '4');
      assertEvaluatesTrue("array",   'contains', '5');
      assertEvaluatesFalse("array",  'contains', '6');
      assertEvaluatesFalse("array",  'contains', '"1"');
    }

    [Test]
    public function shouldTestContainsReturnsFalseForNilOperands():void {
      _sharedContext = new Context();
      assertEvaluatesFalse("not_assigned", 'contains', '0');
      assertEvaluatesFalse("0", 'contains', 'not_assigned');
    }

    [Test]
    public function shouldTestOrCondition():void {
      var condition:Condition;

      condition = new Condition('1', '==', '2');
      assertFalse(condition.evaluate());

      condition.or(new Condition('2', '==', '1'));
      assertFalse(condition.evaluate());

      condition.or(new Condition('1', '==', '1'));
      assertTrue(condition.evaluate());
    }

    [Test]
    public function shouldTestAndCondition():void {
      var condition:Condition;

      condition = new Condition('1', '==', '1');
      assertTrue(condition.evaluate());

      condition.and(new Condition('2', '==', '2'));
      assertTrue(condition.evaluate());

      condition.and(new Condition('2', '==', '1'));
      assertFalse(condition.evaluate());
    }

    [Test]
    public function shouldTestShouldAllowCustomProcOperator():void {
      try {
        Condition.operators['starts_with'] = function(cond:Condition, left:*, right:*):Boolean {
          return left.match(new RegExp("^" + right));
        }

        assertEvaluatesTrue("'bob'",   'starts_with', "'b'");
        assertEvaluatesFalse("'bob'",  'starts_with', "'o'");
      } finally {
        delete Condition.operators['starts_with']
      }
    }

    [Test]
    public function shouldTestLeftOrRightMayContainOperators():void {
      _sharedContext = new Context();
      _sharedContext.setItem('one', "gnomeslab-and-or-liquid");
      _sharedContext.setItem('another', "gnomeslab-and-or-liquid");

      assertEvaluatesTrue("one", '==', "another");
    }


    private function assertEvaluatesTrue(left:String, op:String, right:String):void {
      assertTrue("Evaluated false: " + left + " " + op + " " + right,
        new Condition(left, op, right).evaluate(_sharedContext ? _sharedContext : new Context()));
    }

    private function assertEvaluatesFalse(left:String, op:String, right:String):void {
      assertFalse("Evaluated true: " + left + " " + op + " " + right,
        new Condition(left, op, right).evaluate(_sharedContext ? _sharedContext : new Context()));

    }
  }
}
