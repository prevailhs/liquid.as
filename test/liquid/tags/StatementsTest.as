package liquid.tags  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  import liquid.Template;

  public class StatementsTest {

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
    public function shouldTestTrueEqlTrue():void {
      var text:String = ' {% if true == true %} true {% else %} false {% endif %} ';
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestTrueNotEqlTrue():void {
      var text:String = ' {% if true != true %} true {% else %} false {% endif %} ';
      var expected:String = '  false  ';
      var t:Template = Template.parse(text);
      var out:String = t.render()
      assertEquals(expected, out);
    }

    [Test]
    public function shouldTestTrueLqTrue():void {
      var text:String = ' {% if 0 > 0 %} true {% else %} false {% endif %} ';
      var expected:String = '  false  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestOneLqZero():void {
      var text:String = ' {% if 1 > 0 %} true {% else %} false {% endif %} ';
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestZeroLqOne():void {
      var text:String = ' {% if 0 < 1 %} true {% else %} false {% endif %} ';
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestZeroLqOrEqualOne():void {
      var text:String = ' {% if 0 <= 0 %} true {% else %} false {% endif %} ';
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestZeroLqOrEqualOneInvolvingNull():void {
      var text:String;
      var expected:String;

      text = ' {% if null <= 0 %} true {% else %} false {% endif %} ';
      expected = '  false  ';
      assertEquals(expected, Template.parse(text).render());

      text = ' {% if 0 <= null %} true {% else %} false {% endif %} ';
      expected = '  false  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestZeroLqqOrEqualOne():void {
      var text:String = ' {% if 0 >= 0 %} true {% else %} false {% endif %} ';
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestStrings():void {
      var text:String = " {% if 'test' == 'test' %} true {% else %} false {% endif %} ";
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestStringsNotEqual():void {
      var text:String = " {% if 'test' != 'test' %} true {% else %} false {% endif %} ";
      var expected:String = '  false  ';
      assertEquals(expected, Template.parse(text).render());
    }

    [Test]
    public function shouldTestVarStringsEqual():void {
      var text:String = ' {% if var == "hello there!" %} true {% else %} false {% endif %} ';
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'var': 'hello there!' } ));
    }

    [Test]
    public function shouldTestVarStringsAreNotEqual():void {
      var text:String = ' {% if "hello there!" == var %} true {% else %} false {% endif %} ';
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'var': 'hello there!' } ));
    }

    [Test]
    public function shouldTestVarAndLongStringAreEqual():void {
      var text:String = " {% if var == 'hello there!' %} true {% else %} false {% endif %} ";
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'var': 'hello there!' } ));
    }


    [Test]
    public function shouldTestVarAndLongStringAreEqualBackwards():void {
      var text:String = " {% if 'hello there!' == var %} true {% else %} false {% endif %} ";
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'var': 'hello there!' } ));
    }

//    [Test]
//    public function shouldTestIsNull():void {
//      var text:String = ' {% if var != null %} true {% else %} false {% end %} ';
//      @template.assigns = { 'var': 'hello there!'};
//      var expected:String = '  true  ';
//      assertEquals(expected, @template.parse(text));
//    }

    [Test]
    public function shouldTestIsCollectionEmpty():void {
      var text:String = ' {% if array == empty %} true {% else %} false {% endif %} ';
      var expected:String = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'array': [] } ));
    }

    [Test]
    public function shouldTestIsNotCollectionEmpty():void {
      var text:String = ' {% if array == empty %} true {% else %} false {% endif %} ';
      var expected:String = '  false  ';
      assertEquals(expected, Template.parse(text).render( { 'array': [1, 2, 3] } ));
    }

    [Test]
    public function shouldTestNull():void {
      var text:String;
      var expected:String;

      text = ' {% if var == null %} true {% else %} false {% endif %} ';
      expected = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'var': null } ));

      text = ' {% if var == null %} true {% else %} false {% endif %} ';
      expected = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'var': null } ));
    }

    [Test]
    public function shouldTestNotNull():void {
      var text:String;
      var expected:String;

      text = ' {% if var != null %} true {% else %} false {% endif %} ';
      expected = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'var': 1 } ));

      text = ' {% if var != null %} true {% else %} false {% endif %} ';
      expected = '  true  ';
      assertEquals(expected, Template.parse(text).render( { 'var': 1 } ));
    }
  }
}
