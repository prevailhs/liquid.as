package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class CaptureTest {

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
    public function shouldTestCaptureBlockContentInVariable():void {
      assertTemplateResult("test string", "{% capture 'var' %}test string{% endcapture %}{{var}}", {});
    }

    [Test]
    public function shouldTestCaptureToVariableFromOuterScopeIfExisting():void {
      var templateSource:String = ( <![CDATA[
                                    {% assign var = '' %}
                                    {% if true %}
                                    {% capture var %}first-block-string{% endcapture %}
                                    {% endif %}
                                    {% if true %}
                                    {% capture var %}test-string{% endcapture %}
                                    {% endif %}
                                    {{var}}
                                  ]]> ).toString();


      var template:Template = Template.parse(templateSource);
      var rendered:String = template.render();
      assertEquals("test-string", rendered.replace(/\s/g, ''));
    }

    [Test]
    public function shouldTestAssigningFromCapture():void {
      var templateSource:String = ( <![CDATA[
                                    {% assign first = '' %}
                                    {% assign second = '' %}
                                    {% for number in (1..3) %}
                                    {% capture first %}{{number}}{% endcapture %}
                                    {% assign second = first %}
                                    {% endfor %}
                                    {{ first }}-{{ second }}
                                  ]]> ).toString();

      var template:Template = Template.parse(templateSource);
      var rendered:String = template.render();
      assertEquals("3-3", rendered.replace(/\s/g, ''));
    }
  }
}
