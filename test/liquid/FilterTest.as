package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class FilterTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;

    private var _context:Context;

    [Before]
    public function setUp():void {
      _context = new Context();
    }

    [After]
    public function tearDown():void {
      _context = null;
    }

    [Test]
    public function shouldTestLocalFilter():void {
      _context.setItem('var', 1000);
      _context.addFilters(MoneyFilter);

      assertEquals(' 1000$ ', new Variable("var | money").render(_context));
    }

    [Test]
    public function shouldTestUnderscoreInFilterName():void {
      _context.setItem('var', 1000);
      _context.addFilters(MoneyFilter);
      assertEquals(' 1000$ ', new Variable("var | money_with_underscore").render(_context));
    }

    [Test]
    public function shouldTestSecondFilterOverwritesFirst():void {
      _context.setItem('var', 1000);
      _context.addFilters(MoneyFilter);
      _context.addFilters(CanadianMoneyFilter);

      assertEquals(' 1000$ CAD ', new Variable("var | money").render(_context));
    }

    [Test]
    public function shouldTestSize():void {
      _context.setItem('var', 'abcd');
      _context.addFilters(MoneyFilter);

      assertEquals(4, new Variable("var | size").render(_context));
    }

    [Test]
    public function shouldTestJoin():void {
      _context.setItem('var', [1, 2, 3, 4]);

      assertEquals("1 2 3 4", new Variable("var | join").render(_context));
    }

    [Test]
    public function shouldTestSort():void {
      _context.setItem('value', 3);
      _context.setItem('numbers', [2, 1, 4, 3]);
      _context.setItem('words', ['expected', 'as', 'alphabetic']);
      _context.setItem('arrays', [['flattened'], ['are']]);

      assertEqualsNestedArrays([1, 2, 3, 4], new Variable("numbers | sort").render(_context));
      assertEqualsNestedArrays(['alphabetic', 'as', 'expected'], new Variable("words | sort").render(_context));
      assertEqualsNestedArrays([3], new Variable("value | sort").render(_context));
      assertEqualsNestedArrays(['are', 'flattened'], new Variable("arrays | sort").render(_context));
    }

    [Test]
    public function shouldTestStripHtml():void {
      _context.setItem('var', "<b>bla blub</a>");

      assertEquals("bla blub", new Variable("var | strip_html").render(_context));
    }

    [Test]
    public function shouldTestCapitalize():void {
      _context.setItem('var', "blub");

      assertEquals("Blub", new Variable("var | capitalize").render(_context));
    }

    [Test]
    public function shouldTestNonexistentFilterIsIgnored():void {
      _context.setItem('var', 1000);

      assertEquals(1000, new Variable("var | xyzzy").render(_context));
    }

    [Test]
    public function shouldTestLocalGlobal():void {
      Template.registerFilter(MoneyFilter);

      assertEquals(" 1000$ ", Template.parse("{{1000 | money}}").render(null, null));
      assertEquals(" 1000$ CAD ", Template.parse("{{1000 | money}}").render(null, { "filters": CanadianMoneyFilter } ));
      assertEquals(" 1000$ CAD ", Template.parse("{{1000 | money}}").render(null, { "filters": [CanadianMoneyFilter] } ));
    }

// TODO Consider if we want to support deprecated syntax
/*
    [Test]
    public function shouldTestLocalFilterWithDeprecatedSyntax():void {
      assertEquals(" 1000$ CAD ", Template.parse("{{1000 | money}}").render(null, CanadianMoneyFilter));
      assertEquals(" 1000$ CAD ", Template.parse("{{1000 | money}}").render(null, [CanadianMoneyFilter]));
    }
*/
  }
}

class MoneyFilter {
  public static function money(input:*):String {
    return ' ' + input + '$ ';
  }

  public static function money_with_underscore(input:*):String {
    return ' ' + input + '$ ';
  }
};

class CanadianMoneyFilter {
  public static function money(input:*):String {
    return ' ' + input + '$ CAD ';
  }
};
