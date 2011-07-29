package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class StrainerTest {

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
    public function shouldTestStrainer():void {
      var strainer:Strainer = Strainer.create(null);
      assertEquals(false, strainer.respondTo('__test__'));
      assertEquals(false, strainer.respondTo('test'));
      assertEquals(false, strainer.respondTo('instance_eval'));
      assertEquals(false, strainer.respondTo('__send__'));
      assertEquals(true, 'size' in strainer);
    }

    [Test]
    public function shouldTestShouldRespondToTwoParameters():void {
      var strainer:Strainer = Strainer.create(null);
      assertEquals(true, 'size' in strainer);
    }

    // Asserts that Object#respondTo_missing? is not being undefined in Ruby 
    // versions where it has been implemented
    // Currently this method is only present in Ruby v1.9.2, or higher
    // TODO Decide if we need to implement
//    [Test]
//    public function shouldTestObjectRespondToMissing():void {
//      assertEquals(Object.respondTo(:respondTo_missing?), Strainer.create(null).respondTo(:respondTo_missing?)
//    }
  }
}
