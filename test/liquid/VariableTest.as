package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class VariableTest {

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
    public function shouldTestVariable():void {
      var v:Variable = new Variable('hello');
      assertEquals('hello', v.name);
    }

    [Test]
    public function shouldTestFilters():void {
      var v:Variable;

      v = new Variable('hello | textileze');
      assertEquals('hello', v.name);
      assertEqualsNestedArrays([['textileze', []]], v.filters);

      v = new Variable('hello | textileze | paragraph');
      assertEquals('hello', v.name);
      assertEqualsNestedArrays([['textileze', []], ['paragraph', []]], v.filters);

      v = new Variable(" hello | strftime: '%Y'");
      assertEquals('hello', v.name);
      assertEqualsNestedArrays([['strftime', ["'%Y'"]]], v.filters);

      v = new Variable(" 'typo' | link_to: 'Typo', true ");
      assertEquals("'typo'", v.name);
      assertEqualsNestedArrays([['link_to', ["'Typo'", "true"]]], v.filters);

      v = new Variable(" 'typo' | link_to: 'Typo', false ");
      assertEquals("'typo'", v.name);
      assertEqualsNestedArrays([['link_to', ["'Typo'", "false"]]], v.filters);

      v = new Variable(" 'foo' | repeat: 3 ");
      assertEquals("'foo'", v.name);
      assertEqualsNestedArrays([['repeat', ["3"]]], v.filters);

      v = new Variable(" 'foo' | repeat: 3, 3 ");
      assertEquals("'foo'", v.name);
      assertEqualsNestedArrays([['repeat', ["3", "3"]]], v.filters);

      v = new Variable(" 'foo' | repeat: 3, 3, 3 ");
      assertEquals("'foo'", v.name);
      assertEqualsNestedArrays([['repeat', ["3", "3", "3"]]], v.filters);

      v = new Variable(" hello | strftime: '%Y, okay?'");
      assertEquals('hello', v.name);
      assertEqualsNestedArrays([['strftime', ["'%Y, okay?'"]]], v.filters);

      v = new Variable(" hello | things: \"%Y, okay?\", 'the other one'");
      assertEquals('hello', v.name);
      assertEqualsNestedArrays([['things', ["\"%Y, okay?\"", "'the other one'"]]], v.filters);
    }

    [Test]
    public function shouldTestFilterWithDateParameter():void {
      var v:Variable = new Variable(" '2006-06-06' | date: \"%m/%d/%Y\"");
      assertEquals("'2006-06-06'", v.name);
      assertEqualsNestedArrays([['date', ["\"%m/%d/%Y\""]]], v.filters);
    }

    [Test]
    public function shouldTestFiltersWithoutWhitespace():void {
      var v:Variable
      v = new Variable('hello | textileze | paragraph')
      assertEquals('hello', v.name);
      assertEqualsNestedArrays([['textileze', []], ['paragraph', []]], v.filters);

      v = new Variable('hello|textileze|paragraph')
      assertEquals('hello', v.name);
      assertEqualsNestedArrays([['textileze', []], ['paragraph', []]], v.filters);
    }

    [Test]
    public function shouldTestSymbol():void {
      var v:Variable = new Variable("http://disney.com/logo.gif | image: 'med' ")
      assertEquals('http://disney.com/logo.gif', v.name);
      assertEqualsNestedArrays([['image', ["'med'"]]], v.filters);
    }

    [Test]
    public function shouldTestStringSingleQuoted():void {
      var v:Variable = new Variable(" \"hello\" ");
      assertEquals('"hello"', v.name);
    }

    [Test]
    public function shouldTestStringDoubleQuoted():void {
      var v:Variable = new Variable(" 'hello' ");
      assertEquals("'hello'", v.name);
    }

    [Test]
    public function shouldTestInteger():void {
      var v:Variable = new Variable(" 1000 ");
      assertEquals("1000", v.name);
    }

    [Test]
    public function shouldTestFloat():void {
      var v:Variable = new Variable(" 1000.01 ");
      assertEquals("1000.01", v.name);
    }

    [Test]
    public function shouldTestStringWithSpecialChars():void {
      var v:Variable = new Variable(" 'hello! $!@.;\"ddasd\" ' ");
      assertEquals("'hello! $!@.;\"ddasd\" '", v.name);
    }

    [Test]
    public function shouldTestStringDot():void {
      var v:Variable = new Variable(" test.test ");
      assertEquals('test.test', v.name);
    }
  }
}
