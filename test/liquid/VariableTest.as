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

    //private var instance:Variable;

    [Before]
    public function setUp():void {
      //instance = new Variable();
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
    // TODO Consider splitting up this into smaller unit tests
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

//class VariableResolutionTest < Test::Unit::TestCase
  //include Liquid
//
  //def test_simple_variable
    //template = Template.parse(%|{{test}}|)
    //assert_equal 'worked', template.render('test' => 'worked')
    //assert_equal 'worked wonderfully', template.render('test' => 'worked wonderfully')
  //end
//
  //def test_simple_with_whitespaces
    //template = Template.parse(%|  {{ test }}  |)
    //assert_equal '  worked  ', template.render('test' => 'worked')
    //assert_equal '  worked wonderfully  ', template.render('test' => 'worked wonderfully')
  //end
//
  //def test_ignore_unknown
    //template = Template.parse(%|{{ test }}|)
    //assert_equal '', template.render
  //end
//
  //def test_hash_scoping
    //template = Template.parse(%|{{ test.test }}|)
    //assert_equal 'worked', template.render('test' => {'test' => 'worked'})
  //end
//
  //def test_preset_assigns
    //template = Template.parse(%|{{ test }}|)
    //template.assigns['test'] = 'worked'
    //assert_equal 'worked', template.render
  //end
//
  //def test_reuse_parsed_template
    //template = Template.parse(%|{{ greeting }} {{ name }}|)
    //template.assigns['greeting'] = 'Goodbye'
    //assert_equal 'Hello Tobi', template.render('greeting' => 'Hello', 'name' => 'Tobi')
    //assert_equal 'Hello ', template.render('greeting' => 'Hello', 'unknown' => 'Tobi')
    //assert_equal 'Hello Brian', template.render('greeting' => 'Hello', 'name' => 'Brian')
    //assert_equal 'Goodbye Brian', template.render('name' => 'Brian')
    //assert_equal({'greeting'=>'Goodbye'}, template.assigns)
  //end
//
  //def test_assigns_not_polluted_from_template
    //template = Template.parse(%|{{ test }}{% assign test = 'bar' %}{{ test }}|)
    //template.assigns['test'] = 'baz'
    //assert_equal 'bazbar', template.render
    //assert_equal 'bazbar', template.render
    //assert_equal 'foobar', template.render('test' => 'foo')
    //assert_equal 'bazbar', template.render
  //end
//
  //def test_hash_with_default_proc
    //template = Template.parse(%|Hello {{ test }}|)
    //assigns = Hash.new { |h,k| raise "Unknown variable '#{k}'" }
    //assigns['test'] = 'Tobi'
    //assert_equal 'Hello Tobi', template.render!(assigns)
    //assigns.delete('test')
    //e = assert_raises(RuntimeError) {
      //template.render!(assigns)
    //}
    //assert_equal "Unknown variable 'test'", e.message
  //end
//end # VariableTest
  //
}