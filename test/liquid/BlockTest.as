package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class BlockTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;

    //private var instance:Block;

    [Before]
    public function setUp():void {
      //instance = new Block();
    }

    [After]
    public function tearDown():void {
      //instance = null;
    }

    [Test]
    public function shouldTestBlankspace():void {
      var template:Template = Template.parse("  ");
      assertEqualsNestedArrays(["  "], template.root.nodelist);
    }

    [Test]
    public function shouldTestVariableBeginning():void {
      var template:Template = Template.parse("{{funk}}  ");
      assertEquals(2, template.root.nodelist.length);
      assertEquals(Variable, Liquid.getClass(template.root.nodelist[0]));
      assertEquals(String, Liquid.getClass(template.root.nodelist[1]));
    }

    [Test]
    public function shouldTestVariableEnd():void {
      var template:Template = Template.parse("  {{funk}}");
      assertEquals(2, template.root.nodelist.length);
      assertEquals(String, Liquid.getClass(template.root.nodelist[0]));
      assertEquals(Variable, Liquid.getClass(template.root.nodelist[1]));
    }

    [Test]
    public function shouldTestVariableMiddle():void {
      var template:Template = Template.parse("  {{funk}}  ");
      assertEquals(3, template.root.nodelist.length);
      assertEquals(String, Liquid.getClass(template.root.nodelist[0]));
      assertEquals(Variable, Liquid.getClass(template.root.nodelist[1]));
      assertEquals(String, Liquid.getClass(template.root.nodelist[2]));
    }

    [Test]
    public function shouldTestVariableManyEmbeddedFragments():void {
      var template:Template = Template.parse("  {{funk}} {{so}} {{brother}} ");
      assertEquals(7, template.root.nodelist.length);
      assertEqualsNestedArrays([String, Variable, String, Variable, String, Variable, String],
        blockTypes(template.root.nodelist));
    }

    // TODO Enable when Comment is supported
    //[Test]
    //public function shouldTestWithBlock():void {
      //var template:Template = Template.parse("  {% comment %} {% endcomment %} ");
      //assertEqualsNestedArrays([String, Comment, String], blockTypes(template.root.nodelist));
      //assertEquals(3, template.root.nodelist.length);
    //}

    // TODO Enable when registerTag is supported
    //[Test]
    //public function shouldTestWithCustomTag():void {
      //Template.registerTag("testtag", Class(Block));
      //assertDoesNotThrow(function():void {
        //var template:Template = Template.parse("{% testtag %} {% endtesttag %}");
      //});
    //}

    private function blockTypes(nodelist:Array):Array {
      return nodelist.map(function(item:*, index:int, array:Array):Object {
        return Liquid.getClass(item);
      });
    }
  }
}