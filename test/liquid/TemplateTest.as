package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class TemplateTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;

    //private var instance:Template;

    [Before]
    public function setUp():void {
      //instance = new Template();
    }

    [After]
    public function tearDown():void {
      //instance = null;
    }

    [Test]
    public function shouldTestVariable():void {
      var v:Variable = new Variable('hello');
      assertEquals('hello', v.name);
    }

    [Test]
    public function shouldTestTokenizeStrings():void {
      assertEqualsNestedArrays([' '], new Template().tokenize(' '));
      assertEqualsNestedArrays(['hello world'], new Template().tokenize('hello world'));
    }

    [Test]
    public function shouldTestTokenizeVariables():void {
      assertEqualsNestedArrays(['{{funk}}'], new Template().tokenize('{{funk}}'));
      assertEqualsNestedArrays([' ', '{{funk}}', ' '], new Template().tokenize(' {{funk}} '));
      assertEqualsNestedArrays([' ', '{{funk}}', ' ', '{{so}}', ' ', '{{brother}}', ' '], new Template().tokenize(' {{funk}} {{so}} {{brother}} '));
      assertEqualsNestedArrays([' ', '{{  funk  }}', ' '], new Template().tokenize(' {{  funk  }} '));
    }

    [Test]
    public function shouldTestTokenizeBlocks():void {
      assertEqualsNestedArrays(['{%comment%}'], new Template().tokenize('{%comment%}'));
      assertEqualsNestedArrays([' ', '{%comment%}', ' '], new Template().tokenize(' {%comment%} '));

      assertEqualsNestedArrays([' ', '{%comment%}', ' ', '{%endcomment%}', ' '], new Template().tokenize(' {%comment%} {%endcomment%} '));
      assertEqualsNestedArrays(['  ', '{% comment %}', ' ', '{% endcomment %}', ' '], new Template().tokenize("  {% comment %} {% endcomment %} "));
    }

    [Test]
    public function shouldTestInstanceAssignsPersistOnSameTemplateObjectBetweenParses():void {
      var t:Template = new Template();
      assertEquals('from instance assigns', t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render());
      assertEquals('from instance assigns', t.parse("{{ foo }}").render());
    }

    [Test]
    public function shouldTestInstanceAssignsPersistOnSameTemplateParsingBetweenRenders():void {
      var t:Template = new Template().parse("{{ foo }}{% assign foo = 'foo' %}{{ foo }}");
      assertEquals('foo', t.render());
      assertEquals('foofoo', t.render());
    }

    [Test]
    public function shouldTestCustomAssignsDoNotPersistOnSameTemplate():void {
      var t:Template = new Template();
      assertEquals('from custom assigns', t.parse("{{ foo }}").render({'foo': 'from custom assigns'}));
      assertEquals('', t.parse("{{ foo }}").render());
    }

    [Test]
    public function shouldTestCustomAssignsSquashInstanceAssigns():void {
      var t:Template = new Template();
      assertEquals('from instance assigns', t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render());
      assertEquals('from custom assigns', t.parse("{{ foo }}").render({'foo': 'from custom assigns'}));
    }

    [Test]
    public function shouldTestPersistentAssignsSquashInstanceAssigns():void {
      var t:Template = new Template();
      assertEquals('from instance assigns', t.parse("{% assign foo = 'from instance assigns' %}{{ foo }}").render());
      t.assigns['foo'] = 'from persistent assigns';
      assertEquals('from persistent assigns', t.parse("{{ foo }}").render());
    }

    [Test]
    public function shouldTestLambdaIsCalledOnceFromPersistentAssignsOverMultipleParsesAndRenders():void {
      var t:Template = new Template();
      var global:int = 0;
      t.assigns['number'] = function():* { return (global += 1); };
      assertEquals('1', t.parse("{{number}}").render());
      assertEquals('1', t.parse("{{number}}").render());
      assertEquals('1', t.render());
      global = 0;
    }

    [Test]
    public function shouldTestLambaIsCalledOnceFromCustomAssignsOverMultipleParsesAndRenders():void {
      var t:Template = new Template();
      var global:int = 0;
      var assigns:Object = {'number': function():* { return (global += 1); }};
      assertEquals('1', t.parse("{{number}}").render(assigns));
      assertEquals('1', t.parse("{{number}}").render(assigns));
      assertEquals('1', t.render(assigns));
      global = 0;
    }
  }
}
