package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  import liquid.StandardFilters;

  public class StandardFilterTest {

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
    public function shouldTestSize():void {
      assertEquals(3, StandardFilters.size([1,2,3]));
      assertEquals(0, StandardFilters.size([]));
      assertEquals(0, StandardFilters.size(null));
    }

    [Test]
    public function shouldTestDowncase():void {
      assertEquals('testing', StandardFilters.downcase("Testing"));
      assertEquals('', StandardFilters.downcase(null));
    }

    [Test]
    public function shouldTestUpcase():void {
      assertEquals('TESTING', StandardFilters.upcase("Testing"));
      assertEquals('', StandardFilters.upcase(null));
    }

    [Test]
    public function shouldTestTruncate():void {
      assertEquals('1234...', StandardFilters.truncate('1234567890', 7));
      assertEquals('1234567890', StandardFilters.truncate('1234567890', 20));
      assertEquals('...', StandardFilters.truncate('1234567890', 0));
      assertEquals('1234567890', StandardFilters.truncate('1234567890'));
    }

    [Test]
    public function shouldTestEscape():void {
      assertEquals('&lt;strong&gt;', StandardFilters.escape('<strong>'));
      assertEquals('&lt;strong&gt;', StandardFilters.h('<strong>'));
    }

    [Test]
    public function shouldTestEscapeOnce():void {
      assertEquals('&lt;strong&gt;', StandardFilters.escape_once(StandardFilters.escape('<strong>')));
    }

    [Test]
    public function shouldTestTruncateWords():void {
      assertEquals('one two three', StandardFilters.truncatewords('one two three', 4));
      assertEquals('one two...', StandardFilters.truncatewords('one two three', 2));
      assertEquals('one two three', StandardFilters.truncatewords('one two three'));
      assertEquals('Two small (13&#8221; x 5.5&#8221; x 10&#8221; high) baskets fit inside one large basket (13&#8221;...', StandardFilters.truncatewords('Two small (13&#8221; x 5.5&#8221; x 10&#8221; high) baskets fit inside one large basket (13&#8221; x 16&#8221; x 10.5&#8221; high) with cover.', 15));
    }
    
    [Test]
    public function shouldTestStripHtml():void {
      assertEquals('test', StandardFilters.strip_html("<div>test</div>"));
      assertEquals('test', StandardFilters.strip_html("<div id='test'>test</div>"));
      assertEquals('', StandardFilters.strip_html("<script type='text/javascript'>document.write('some stuff');</script>"));
      assertEquals('', StandardFilters.strip_html(null));
    }

    [Test]
    public function shouldTestJoin():void {
      assertEquals('1 2 3 4', StandardFilters.join([1,2,3,4]));
      assertEquals('1 - 2 - 3 - 4', StandardFilters.join([1,2,3,4], ' - '));
    }

    [Test]
    public function shouldTestSort():void {
      assertEqualsNested([1,2,3,4], StandardFilters.sort([4,3,2,1]));
      assertEqualsNested([{"a": 1}, {"a": 2}, {"a": 3}, {"a": 4}], StandardFilters.sort([{"a": 4}, {"a": 3}, {"a": 1}, {"a": 2}], "a"));
    }

    [Test]
    public function shouldTestMap():void {
      assertEqualsNested([1,2,3,4], StandardFilters.map([{"a": 1}, {"a": 2}, {"a": 3}, {"a": 4}], 'a'));
      assertTemplateResult('abc', "{{ ary | map:'foo' | map:'bar' }}",
        {'ary': [{'foo': {'bar': 'a'}}, {'foo': {'bar': 'b'}}, {'foo': {'bar': 'c'}}]});
    }

    // FIXME Implement date formatting
    //[Test]
    public function shouldTestDate():void {
      assertEquals('May', StandardFilters.date(new Date(Date.parse("2006-05-05 10:00:00")), "%B"));
      assertEquals('June', StandardFilters.date(new Date(Date.parse("2006-06-05 10:00:00")), "%B"));
      assertEquals('July', StandardFilters.date(new Date(Date.parse("2006-07-05 10:00:00")), "%B"));

      assertEquals('May', StandardFilters.date("2006-05-05 10:00:00", "%B"));
      assertEquals('June', StandardFilters.date("2006-06-05 10:00:00", "%B"));
      assertEquals('July', StandardFilters.date("2006-07-05 10:00:00", "%B"));

      assertEquals('2006-07-05 10:00:00', StandardFilters.date("2006-07-05 10:00:00", ""));
      assertEquals('2006-07-05 10:00:00', StandardFilters.date("2006-07-05 10:00:00", ""));
      assertEquals('2006-07-05 10:00:00', StandardFilters.date("2006-07-05 10:00:00", ""));
      assertEquals('2006-07-05 10:00:00', StandardFilters.date("2006-07-05 10:00:00", null));

      assertEquals('07/05/2006', StandardFilters.date("2006-07-05 10:00:00", "%m/%d/%Y"));

      assertEquals("07/16/2004", StandardFilters.date("Fri Jul 16 01:00:00 2004", "%m/%d/%Y"));

      assertEquals(null, StandardFilters.date(null, "%B"));
    }


    [Test]
    public function shouldTestFirstLast():void {
      assertEquals(1, StandardFilters.first([1,2,3]));
      assertEquals(3, StandardFilters.last([1,2,3]));
      assertEquals(null, StandardFilters.first([]));
      assertEquals(null, StandardFilters.last([]));
    }

    [Test]
    public function shouldTestReplace():void {
      assertEquals('b b b b', StandardFilters.replace("a a a a", 'a', 'b'));
      assertEquals('b a a a', StandardFilters.replace_first("a a a a", 'a', 'b'));
      assertTemplateResult('b a a a', "{{ 'a a a a' | replace_first: 'a', 'b' }}");
    }

    [Test]
    public function shouldTestRemove():void {
      assertEquals('   ', StandardFilters.remove("a a a a", 'a'));
      assertEquals('a a a', StandardFilters.remove_first("a a a a", 'a '));
      assertTemplateResult('a a a', "{{ 'a a a a' | remove_first: 'a ' }}");
    }

    [Test]
    public function shouldTestPipesInStringArguments():void {
      assertTemplateResult('foobar', "{{ 'foo|bar' | remove: '|' }}");
    }

    [Test]
    public function shouldTestStringNewlines():void {
      assertTemplateResult('abc', "{{ source | strip_newlines }}", {'source': "a\nb\nc"});
    }

    [Test]
    public function shouldTestNewlinesToBr():void {
      assertTemplateResult("a<br />\nb<br />\nc", "{{ source | newline_to_br }}", {'source': "a\nb\nc"});
    }

    // FIXME How to get AS3 to force float type?
    //[Test]
    public function shouldTestPlus():void {
      assertTemplateResult("2", "{{ 1 | plus:1 }}");
      assertTemplateResult("2.0", "{{ '1' | plus:'1.0' }}");
    }

    [Test]
    public function shouldTestMinus():void {
      assertTemplateResult("4", "{{ input | minus:operand }}", {'input': 5, 'operand': 1});
      assertTemplateResult("2.3", "{{ '4.3' | minus:'2' }}");
    }

    [Test]
    public function shouldTestTimes():void {
      assertTemplateResult("12", "{{ 3 | times:4 }}");
      assertTemplateResult("0", "{{ 'foo' | times:4 }}");

      // Ruby v1.9.2-rc1, or higher, backwards compatible Float test
      assertMatches(/(6\.3)|(6\.(0{13})1)/, Template.parse("{{ '2.1' | times:3 }}").render());

      assertTemplateResult("6", "{{ '2.1' | times:3 | replace: '.','-' | plus:0}}");
    }

    // FIXME How to get AS3 to force float type
    //[Test]
    public function shouldTestDividedBy():void {
      assertTemplateResult("4", "{{ 12 | divided_by:3 }}");
      assertTemplateResult("4", "{{ 14 | divided_by:3 }}");

      // Ruby v1.9.2-rc1, or higher, backwards compatible Float test
      assertMatches(/4\.(6{13,14})7/, Template.parse("{{ 14 | divided_by:'3.0' }}").render());

      assertTemplateResult("5", "{{ 15 | divided_by:3 }}");
      assertTemplateResult("Liquid error: divided by 0", "{{ 5 | divided_by:0 }}");
    }

    [Test]
    public function shouldTestAppend():void {
      var assigns:Object = {'a': 'bc', 'b': 'd' };
      assertTemplateResult('bcd',"{{ a | append: 'd'}}",assigns);
      assertTemplateResult('bcd',"{{ a | append: b}}",assigns);
    }

    [Test]
    public function shouldTestPrepend():void {
      var assigns:Object = {'a': 'bc', 'b': 'a' };
      assertTemplateResult('abc',"{{ a | prepend: 'a'}}",assigns);
      assertTemplateResult('abc',"{{ a | prepend: b}}",assigns);
    }

    [Test]
    public function shouldTestCannotAccessPrivateMethods():void {
      assertTemplateResult('a',"{{ 'a' | to_number }}");
    }
  }
}

