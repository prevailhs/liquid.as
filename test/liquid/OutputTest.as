package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;
  import liquid.Template;
  import liquid.errors.SyntaxError;

  public class OutputTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;

    private var _assigns:Object;

    [Before]
    public function setUp():void {
      _assigns = {
        'best_cars': 'bmw',
        'car': {'bmw': 'good', 'gm': 'bad'}
        }
    }

    [After]
    public function tearDown():void {
    }

    [Test]
    public function shouldTestVariable():void {
      var text:String = " {{best_cars}} ";

      var expected:String = " bmw ";
      assertEquals(expected, Template.parse(text).render(_assigns));
    }

    [Test]
    public function shouldTestVariableTraversing():void {
      var text:String = " {{car.bmw}} {{car.gm}} {{car.bmw}} ";

      var expected:String = " good bad good ";
      assertEquals(expected, Template.parse(text).render(_assigns));
    }

    [Test]
    public function shouldTestVariablePiping():void {
      var text:String = " {{ car.gm | make_funny }} ";
      var expected:String = " LOL ";

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }

    [Test]
    public function shouldTestVariablePipingWithInput():void {
      var text:String = " {{ car.gm | cite_funny }} ";
      var expected:String = " LOL: bad ";

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }

    [Test]
    public function shouldTestVariablePipingWithArgs():void {
      var text:String = " {{ car.gm | add_smiley : ':-(' }} ";
      var expected:String = " bad :-( ";

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }

    [Test]
    public function shouldTestVariablePipingWithNoArgs():void {
      var text:String = " {{ car.gm | add_smiley }} ";
      var expected:String = " bad :-) ";

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }

    [Test]
    public function shouldTestMultipleVariablePipingWithArgs():void {
      var text:String = " {{ car.gm | add_smiley : ':-(' | add_smiley : ':-('}} ";
      var expected:String = " bad :-( :-( ";

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }

    [Test]
    public function shouldTestVariablePipingWithMultipleArgs():void {
      var text:String = " {{ car.gm | add_tag : 'span', 'bar'}} ";
      var expected:String = ' <span id="bar">bad</span> ';

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }

    [Test]
    public function shouldTestVariablePipingWithVariableArgs():void {
      var text:String = " {{ car.gm | add_tag : 'span', car.bmw}} ";
      var expected:String = ' <span id="good">bad</span> ';

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }

    [Test]
    public function shouldTestMultiplePipings():void {
      var text:String = " {{ best_cars | cite_funny | paragraph }} ";
      var expected:String = " <p>LOL: bmw</p> ";

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }

    [Test]
    public function shouldTestLinkTo():void {
      var text:String = " {{ 'Typo' | link_to: 'http://typo.leetsoft.com' }} ";
      var expected:String = ' <a href="http://typo.leetsoft.com">Typo</a> ';

      assertEquals(expected, Template.parse(text).render(_assigns, { "filters": [FunnyFilter] } ));
    }
  }
}


class FunnyFilter extends Object {
  public static function make_funny(input:String):String {
    return 'LOL';
  }

  public static function cite_funny(input:String):String {
    return "LOL: " + input;
  }

  public static function add_smiley(input:String, smiley:String = ":-)"):String {
    return input + " " + smiley;
  }

  public static function add_tag(input:String, tag:String = "p", id:String = "foo"):String {
    return "<" + tag + " id=\"" + id + "\">" + input + "</" + tag + ">";
  }

  public static function paragraph(input:String):String {
    return "<p>" + input + "</p>"
  }

  public static function link_to(name:String, url:String):String {
    return "<a href=\"" + url + "\">" + name + "</a>";
  }
};
