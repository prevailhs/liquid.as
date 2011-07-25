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

    //private var instance:Strainer;

    [Before]
    public function setUp():void {
      //instance = new Strainer();
    }

    [After]
    public function tearDown():void {
      //instance = null;
    }

    [Test]
    public function shouldTestStrainer():void {
      var strainer:Strainer = Strainer.create(null);
      assertEquals(false, strainer.respondTo('__test__'));
      assertEquals(false, strainer.respondTo('test'));
      assertEquals(false, strainer.respondTo('instance_eval'));
      assertEquals(false, strainer.respondTo('__send__'));
      // FIXME Size not present on Object for AS3
      //assertEquals(true, strainer.respondTo('size')); // from the standard 
      //lib
    }

    [Test]
    public function shouldTestShouldRespondToTwoParameters():void {
      var strainer:Strainer = Strainer.create(null);
      // FIXME Size not present on Object for AS3
      //assertEquals(true, strainer.respondTo('size', false));
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
