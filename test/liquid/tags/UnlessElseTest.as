package liquid.tags  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  import liquid.Condition;
  import liquid.errors.SyntaxError;
  
  public class UnlessElseTest {

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
    public function shouldTestUnless():void {
      assertTemplateResult('  ', ' {% unless true %} this text should not go into the output {% endunless %} ')
      assertTemplateResult('  this text should go into the output  ',
                           ' {% unless false %} this text should go into the output {% endunless %} ')
      assertTemplateResult('  you rock ?', '{% unless true %} you suck {% endunless %} {% unless false %} you rock {% endunless %}?')
    }

    [Test]
    public function shouldTestUnlessElse():void {
      assertTemplateResult(' YES ', '{% unless true %} NO {% else %} YES {% endunless %}')
      assertTemplateResult(' YES ', '{% unless false %} YES {% else %} NO {% endunless %}')
      assertTemplateResult(' YES ', '{% unless "foo" %} NO {% else %} YES {% endunless %}')
    }

    [Test]
    public function shouldTestUnlessInLoop():void {
      assertTemplateResult('23', '{% for i in choices %}{% unless i %}{{ forloop.index }}{% endunless %}{% endfor %}', {'choices': [1, null, false]});
    }

    [Test]
    public function shouldTestUnlessElseInLoop():void {
      assertTemplateResult(' TRUE  2  3 ', '{% for i in choices %}{% unless i %} {{ forloop.index }} {% else %} TRUE {% endunless %}{% endfor %}', {'choices': [1, null, false]});
    }
  }
}
