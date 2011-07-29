package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class VariableResolutionTest {

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
    public function shouldTestSimpleVariable():void {
      var template:Template = Template.parse("{{test}}");;
      assertEquals('worked', template.render({'test': 'worked'}));
      assertEquals('worked wonderfully', template.render({'test': 'worked wonderfully'}));
    }

    [Test]
    public function shouldTestSimpleWithWhitespace():void {
      var template:Template = Template.parse("  {{ test }}  ");
      assertEquals('  worked  ', template.render({'test': 'worked'}));
      assertEquals('  worked wonderfully  ', template.render({'test': 'worked wonderfully'}));
    }

    [Test]
    public function shouldTestIgnoreUnknown():void {
      var template:Template = Template.parse("{{ test }}");
      assertEquals('', template.render());
    }

    [Test]
    public function shouldTestHashScoping():void {
      var template:Template = Template.parse("{{ test.test }}");
      assertEquals('worked', template.render({'test': {'test': 'worked'}));
    }

    [Test]
    public function shouldTestPresetAssigns():void {
      var template:Template = Template.parse("{{ test }}");
      template.assigns['test'] = 'worked';
      assertEquals('worked', template.render());
    }

    [Test]
    public function shouldTestReuseParsedTemplate():void {
      var template:Template = Template.parse("{{ greeting }} {{ name }}");
      template.assigns['greeting'] = 'Goodbye';
      assertEquals('Hello Tobi', template.render({'greeting': 'Hello', 'name': 'Tobi'}));
      assertEquals('Hello ', template.render({'greeting': 'Hello', 'unknown': 'Tobi'}));
      assertEquals('Hello Brian', template.render({'greeting': 'Hello', 'name': 'Brian'}));
      assertEquals('Goodbye Brian', template.render({'name': 'Brian'}));
      assertEquals({'greeting': 'Goodbye'}, template.assigns);
    }

    [Test]
    public function shouldTestAssignsNotPollutedFromTemplate():void {
      var template:Template = Template.parse("{{ test }}{% assign test = 'bar' %}{{ test }}");
      template.assigns['test'] = 'baz';
      assertEquals('bazbar', template.render();
      assertEquals('bazbar', template.render();
      assertEquals('foobar', template.render({'test': 'foo'}));
      assertEquals('bazbar', template.render();
    }

    [Test]
    public function shouldTestHashWithDefaultProc():void {
      var template:Template = Template.parse("Hello {{ test }}");
      assigns = Hash.new { |h,k| raise "Unknown variable '#{k}'" };
      assigns['test'] = 'Tobi';
      assertEquals('Hello Tobi', template.renderBang(assigns));
      delete assigns['test'];
      var e:Error = assertThrows(RuntimeError, function():void {
        template.renderBang(assigns);
      });
      assertEquals("Unknown variable 'test'", e.message);
    }
  }
}
