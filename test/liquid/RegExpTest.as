package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class RegExpTest {

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
    public function shouldTestEmpty():void {
      assertEqualsArrays([], Liquid.scan('', Liquid.QuotedFragment));
    }

    [Test]
    public function shouldTestQuote():void {
      assertEqualsArrays(['"arg 1"'], Liquid.scan('"arg 1"', Liquid.QuotedFragment));
    }

    [Test]
    public function shouldTestWords():void {
      assertEqualsArrays(['arg1', 'arg2'], Liquid.scan('arg1 arg2', Liquid.QuotedFragment));
    }

    [Test]
    public function shouldTestTags():void {
      assertEqualsArrays(['<tr>', '</tr>'], Liquid.scan('<tr> </tr>', Liquid.QuotedFragment));
      assertEqualsArrays(['<tr></tr>'], Liquid.scan('<tr></tr>', Liquid.QuotedFragment));
      assertEqualsArrays(['<style', 'class="hello">', '</style>'], Liquid.scan('<style class="hello">\' </style>', Liquid.QuotedFragment));
    }

    [Test]
    public function shouldTestQuotedWords():void {
      assertEqualsArrays(['arg1', 'arg2', '"arg 3"'], Liquid.scan('arg1 arg2 "arg 3"', Liquid.QuotedFragment));
    }

    [Test]
    public function shouldTestQuotedWords2():void {
      assertEqualsArrays(['arg1', 'arg2', "'arg 3'"], Liquid.scan('arg1 arg2 \'arg 3\'', Liquid.QuotedFragment));
    }

    [Test]
    public function shouldTestQuotedWordsInTheMiddle():void {
      assertEqualsArrays(['arg1', 'arg2', '"arg 3"', 'arg4'], Liquid.scan('arg1 arg2 "arg 3" arg4   ', Liquid.QuotedFragment));
    }

    [Test]
    public function shouldTestVariableParser():void {
      assertEqualsArrays(['var'],                               Liquid.scan('var', Liquid.VariableParser));
      assertEqualsArrays(['var', 'method'],                     Liquid.scan('var.method', Liquid.VariableParser));
      assertEqualsArrays(['var', '[method]'],                   Liquid.scan('var[method]', Liquid.VariableParser));
      assertEqualsArrays(['var', '[method]', '[0]'],            Liquid.scan('var[method][0]', Liquid.VariableParser));
      assertEqualsArrays(['var', '["method"]', '[0]'],          Liquid.scan('var["method"][0]', Liquid.VariableParser));
      assertEqualsArrays(['var', '[method]', '[0]', 'method'],  Liquid.scan('var[method][0].method', Liquid.VariableParser));
    }

    // Not in ruby liquid source anymore, why not?
    //[Test]
    //public function shouldTestLiteralShorthandRegExp():void {
      //trace('expected: [' + "{% if 'gnomeslab' contains 'liquid' %}yes{% endif %}" + ']');
      //trace('actual  : [' + Liquid.scan("{{{ {% if 'gnomeslab' contains 'liquid' %}yes{% endif %} }}}", Liquid.LiteralShorthand)[0] + ']');
      //assertEqualsNestedArrays([["{% if 'gnomeslab' contains 'liquid' %}yes{% endif %}"]],
        //Liquid.scan("{{{ {% if 'gnomeslab' contains 'liquid' %}yes{% endif %} }}}", Liquid.LiteralShorthand));
    //}
  }
}