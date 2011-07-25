package liquid.tags  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  import liquid.Condition;
  import liquid.errors.SyntaxError;
  
  public class IfElseTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;


    [Before]
    public function setUp():void {
    }

    [After]
    public function tearDown():void {
    }

    [Test]
    public function shouldTestIf():void {
      assertTemplateResult('  ', ' {% if false %} this text should not go into the output {% endif %} ');
      assertTemplateResult('  this text should go into the output  ',
                           ' {% if true %} this text should go into the output {% endif %} ');
      assertTemplateResult('  you rock ?', '{% if false %} you suck {% endif %} {% if true %} you rock {% endif %}?');
    }

    [Test]
    public function shouldTestIfElse():void {
      assertTemplateResult(' YES ', '{% if false %} NO {% else %} YES {% endif %}');
      assertTemplateResult(' YES ', '{% if true %} YES {% else %} NO {% endif %}');
      assertTemplateResult(' YES ', '{% if "foo" %} YES {% else %} NO {% endif %}');
    }

    [Test]
    public function shouldTestIfBoolean():void {
      assertTemplateResult(' YES ', '{% if var %} YES {% endif %}', {'var': true});
    }

    [Test]
    public function shouldTestIfOr():void {
      assertTemplateResult(' YES ', '{% if a or b %} YES {% endif %}', {'a': true, 'b': true});
      assertTemplateResult(' YES ', '{% if a or b %} YES {% endif %}', {'a': true, 'b': false});
      assertTemplateResult(' YES ', '{% if a or b %} YES {% endif %}', {'a': false, 'b': true});
      assertTemplateResult('',     '{% if a or b %} YES {% endif %}', {'a': false, 'b': false});

      assertTemplateResult(' YES ', '{% if a or b or c %} YES {% endif %}', {'a': false, 'b': false, 'c': true});
      assertTemplateResult('',     '{% if a or b or c %} YES {% endif %}', {'a': false, 'b': false, 'c': false});
    }

    [Test]
    public function shouldTestIfOrWithOperators():void {
      assertTemplateResult(' YES ', '{% if a == true or b == true %} YES {% endif %}', {'a': true, 'b': true});
      assertTemplateResult(' YES ', '{% if a == true or b == false %} YES {% endif %}', {'a': true, 'b': true});
      assertTemplateResult('', '{% if a == false or b == false %} YES {% endif %}', {'a': true, 'b': true});
    }

    [Test]
    public function shouldTestComparsionOfStringsContainingAndOrOr():void {
      var awfulMarkup:String = "a == 'and' and b == 'or' and c == 'foo and bar' and d == 'bar or baz' and e == 'foo' and foo and bar";
      var assigns:Object = {'a': 'and', 'b': 'or', 'c': 'foo and bar', 'd': 'bar or baz', 'e': 'foo', 'foo': true, 'bar': true};
      assertTemplateResult(' YES ', "{% if " + awfulMarkup + " %} YES {% endif %}", assigns);
    }

    [Test]
    public function shouldTestComparisonOfExpressionStartingWithAndOrOr():void {
      var assigns:Object = {'order': {'items_count': 0}, 'android': {'name': 'Roy'}};
      assertDoesNotThrow(function():void {
        assertTemplateResult( "YES", "{% if android.name == 'Roy' %}YES{% endif %}", assigns);
      });
      assertDoesNotThrow(function():void {
        assertTemplateResult( "YES", "{% if order.items_count == 0 %}YES{% endif %}", assigns);
      });
    }

    [Test]
    public function shouldTestIfAnd():void {
      assertTemplateResult(' YES ', '{% if true and true %} YES {% endif %}');
      assertTemplateResult('', '{% if false and true %} YES {% endif %}');
      assertTemplateResult('', '{% if false and true %} YES {% endif %}');
    }


    [Test]
    public function shouldTestHashMissGeneratesFalse():void {
      assertTemplateResult('', '{% if foo.bar %} NO {% endif %}', {'foo': {}});
    }

    [Test]
    public function shouldTestIfFromVariable():void {
      assertTemplateResult('', '{% if var %} NO {% endif %}', {'var': false});
      assertTemplateResult('', '{% if var %} NO {% endif %}', {'var': null});
      assertTemplateResult('', '{% if foo.bar %} NO {% endif %}', {'foo': {'bar': false}});
      assertTemplateResult('', '{% if foo.bar %} NO {% endif %}', {'foo': {}});
      assertTemplateResult('', '{% if foo.bar %} NO {% endif %}', {'foo': null});
      assertTemplateResult('', '{% if foo.bar %} NO {% endif %}', {'foo': true});

      assertTemplateResult(' YES ', '{% if var %} YES {% endif %}', {'var': "text"});
      assertTemplateResult(' YES ', '{% if var %} YES {% endif %}', {'var': true});
      assertTemplateResult(' YES ', '{% if var %} YES {% endif %}', {'var': 1});
      assertTemplateResult(' YES ', '{% if var %} YES {% endif %}', {'var': {}});
      assertTemplateResult(' YES ', '{% if var %} YES {% endif %}', {'var': []});
      assertTemplateResult(' YES ', '{% if "foo" %} YES {% endif %}');
      assertTemplateResult(' YES ', '{% if foo.bar %} YES {% endif %}', {'foo': {'bar': true}});
      assertTemplateResult(' YES ', '{% if foo.bar %} YES {% endif %}', {'foo': {'bar': "text"}});
      assertTemplateResult(' YES ', '{% if foo.bar %} YES {% endif %}', {'foo': {'bar': 1 }});
      assertTemplateResult(' YES ', '{% if foo.bar %} YES {% endif %}', {'foo': {'bar': {} }});
      assertTemplateResult(' YES ', '{% if foo.bar %} YES {% endif %}', {'foo': {'bar': [] }});

      assertTemplateResult(' YES ', '{% if var %} NO {% else %} YES {% endif %}', {'var': false});
      assertTemplateResult(' YES ', '{% if var %} NO {% else %} YES {% endif %}', {'var': null});
      assertTemplateResult(' YES ', '{% if var %} YES {% else %} NO {% endif %}', {'var': true});
      assertTemplateResult(' YES ', '{% if "foo" %} YES {% else %} NO {% endif %}', {'var': "text"});

      assertTemplateResult(' YES ', '{% if foo.bar %} NO {% else %} YES {% endif %}', {'foo': {'bar': false}});
      assertTemplateResult(' YES ', '{% if foo.bar %} YES {% else %} NO {% endif %}', {'foo': {'bar': true}});
      assertTemplateResult(' YES ', '{% if foo.bar %} YES {% else %} NO {% endif %}', {'foo': {'bar': "text"}});
      assertTemplateResult(' YES ', '{% if foo.bar %} NO {% else %} YES {% endif %}', {'foo': {'notbar': true}});
      assertTemplateResult(' YES ', '{% if foo.bar %} NO {% else %} YES {% endif %}', {'foo': {}});
      assertTemplateResult(' YES ', '{% if foo.bar %} NO {% else %} YES {% endif %}', {'notfoo': {'bar': true}});
    }

    [Test]
    public function shouldTestNestedIf():void {
      assertTemplateResult('', '{% if false %}{% if false %} NO {% endif %}{% endif %}');
      assertTemplateResult('', '{% if false %}{% if true %} NO {% endif %}{% endif %}');
      assertTemplateResult('', '{% if true %}{% if false %} NO {% endif %}{% endif %}');
      assertTemplateResult(' YES ', '{% if true %}{% if true %} YES {% endif %}{% endif %}');

      assertTemplateResult(' YES ', '{% if true %}{% if true %} YES {% else %} NO {% endif %}{% else %} NO {% endif %}');
      assertTemplateResult(' YES ', '{% if true %}{% if false %} NO {% else %} YES {% endif %}{% else %} NO {% endif %}');
      assertTemplateResult(' YES ', '{% if false %}{% if true %} NO {% else %} NONO {% endif %}{% else %} YES {% endif %}');

    }

    [Test]
    public function shouldTestComparisonsOnNull():void {
      assertTemplateResult('', '{% if null < 10 %} NO {% endif %}');
      assertTemplateResult('', '{% if null <= 10 %} NO {% endif %}');
      assertTemplateResult('', '{% if null >= 10 %} NO {% endif %}');
      assertTemplateResult('', '{% if null > 10 %} NO {% endif %}');

      assertTemplateResult('', '{% if 10 < null %} NO {% endif %}');
      assertTemplateResult('', '{% if 10 <= null %} NO {% endif %}');
      assertTemplateResult('', '{% if 10 >= null %} NO {% endif %}');
      assertTemplateResult('', '{% if 10 > null %} NO {% endif %}');
    }

    [Test]
    public function shouldTestElseIf():void {
      assertTemplateResult('0', '{% if 0 == 0 %}0{% elsif 1 == 1%}1{% else %}2{% endif %}');
      assertTemplateResult('1', '{% if 0 != 0 %}0{% elsif 1 == 1%}1{% else %}2{% endif %}');
      assertTemplateResult('2', '{% if 0 != 0 %}0{% elsif 1 != 1%}1{% else %}2{% endif %}');

      assertTemplateResult('elsif', '{% if false %}if{% elsif true %}elsif{% endif %}');
    }

    [Test]
    public function shouldTestSyntaxErrorNoVariable():void {
      assertThrows(liquid.errors.SyntaxError, function():void { assertTemplateResult('', '{% if jerry == 1 %}'); });
    }

    [Test]
    public function shouldTestSyntaxErrorNoExpression():void {
      assertThrows(liquid.errors.SyntaxError, function():void { assertTemplateResult('', '{% if %}'); });
    }

    [Test]
    public function shouldTestIfWithCustomCondition():void {
      Condition.operators['contains'] = function(cond:Condition, left:*, right:*):Boolean {
        if (left is String || left is Array) return left.indexOf(right) >= 0;
        if ('contains' in left) return left.contains(right);
        return false;
      }

      try {
        assertTemplateResult('yes', "{% if 'bob' contains 'o' %}yes{% endif %}");
        assertTemplateResult('no', "{% if 'bob' contains 'f' %}yes{% else %}no{% endif %}");
      } finally {
        delete Condition.operators['contains'];
      }
    }

    [Test]
    public function shouldTestOperatorsAreIgnoredUnlessIsolated():void {
      Condition.operators['contains'] = function(cond:Condition, left:*, right:*):Boolean {
        if (left is String || left is Array) return left.indexOf(right) >= 0;
        if ('contains' in left) return left.contains(right);
        return false;
      }

      assertTemplateResult('yes', "{% if 'gnomeslab-and-or-liquid' contains 'gnomeslab-and-or-liquid' %}yes{% endif %}");
    }
  }
}
