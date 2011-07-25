package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class AssignTest {

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
    public function shouldTestAssignedVariable():void {
      assertTemplateResult('.foo.',
                           '{% assign foo = values %}.{{ foo[0] }}.',
                           {'values': ['foo', 'bar', 'baz'] } );

      assertTemplateResult('.bar.',
                           '{% assign foo = values %}.{{ foo[1] }}.',
                           {'values': ['foo', 'bar', 'baz'] } );
    }
  }
}

