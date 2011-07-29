package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;
  import liquid.Template;
  import liquid.errors.SyntaxError;

  public class ParsingQuirksTest {

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
    public function shouldTestErrorWithCss():void {
      var text:String = " div { font-weight: bold; } ";
      var template:Template = Template.parse(text);

      assertEquals(text, template.render());
      assertEqualsNestedArrays([String], template.root.nodelist.map(function(item:*, index:int, arr:Array):Class {
        return Liquid.getClass(item);
      }));
    }

    [Test]
    public function shouldTestRaiseOnSingleCloseBracket():void {
      assertThrows(liquid.errors.SyntaxError, function():void {
        Template.parse("text {{method} oh nos!");
      });
    }

    [Test]
    public function shouldTestRaiseOnLabelAndNoCloseBrackets():void {
      assertThrows(liquid.errors.SyntaxError, function():void {
        Template.parse("TEST {{ ");
      });
    }

    [Test]
    public function shouldTestRaiseOnLabelAndNoCloseBracketsPercent():void {
      assertThrows(liquid.errors.SyntaxError, function():void {
        Template.parse("TEST {% ");
      });
    }

    [Test]
    public function shouldTestErrorOnEmptyFilter():void {
      assertDoesNotThrow(function():void {
        Template.parse("{{test |a|b|}}");
        Template.parse("{{test}}");
        Template.parse("{{|test|}}");
      });
    }

    [Test]
    public function shouldTestMeaninglessParens():void {
      var assigns:Object = { 'b': 'bar', 'c': 'baz' };
      var markup:String = "a == 'foo' or (b == 'bar' and c == 'baz') or false";
      assertTemplateResult(' YES ', "{% if " + markup + " %} YES {% endif %}", assigns);
    }

    [Test]
    public function shouldTestUnexpectedCharactersSilentlyEatLogic():void {
      var markup:String;
      markup = "true && false";
      assertTemplateResult(' YES ', "{% if " + markup + " %} YES {% endif %}");
      markup = "false || true";
      assertTemplateResult('', "{% if " + markup + " %} YES {% endif %}");
    }
  }
}
