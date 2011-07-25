package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  public class DropTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;

    //private var instance:Drop;

    [Before]
    public function setUp():void {
      //instance = new Drop();
    }

    [After]
    public function tearDown():void {
      //instance = null;
    }

    [Test]
    public function shouldTestProductDrop():void {
      assertDoesNotThrow(function():void {
        var tpl:Template = Template.parse('  ');
        tpl.render( { 'product': new ProductDrop() } );
      });
    }

    [Test]
    public function shouldTestTextDrop():void {
      var output:String = Template.parse(' {{ product.texts.text }} ').render( { 'product': new CatchallDrop() } );
      assertEquals(' text1 ', output);
    }

    [Test]
    public function shouldTestUnknownMethod():void {
      var output:String = Template.parse(' {{ product.catchall.unknown }} ').render( { 'product': new CatchallDrop() } );
      assertEquals(' method: unknown ', output);
    }

// TODO Enable when For tag is implemented
/*
    [Test]
    public function shouldTestTextArrayDrop():void {
      var output:String = Template.parse('{% for text in product.texts.array %} {{text}} {% endfor %}').render( { 'product': new CatchallDrop() } );
      assertEquals(' text1  text2 ', output);
    }
*/

    [Test]
    public function shouldTestContextDrop():void {
      var output:String = Template.parse(' {{ context.bar }} ').render( { 'context': new ContextDrop(), 'bar': "carrot" } );
      assertEquals(' carrot ', output);
    }

// FIXME Not sure why this one isn't working?
/*
    [Test]
    public function shouldTestNestedContextDrop():void {
      var output:String = Template.parse(' {{ product.context.foo }} ').render( { 'product': new ContextDrop(), 'foo': "monkey" } );
      assertEquals(' monkey ', output);
    }
*/

    [Test]
    public function shouldTestProtected():void {
      var output:String = Template.parse(' {{ product.callmenot }} ').render( { 'product': new ProductDrop() } );
      assertEquals('  ', output);
    }

// TODO Enable when For tag is implemented
/*
    [Test]
    public function shouldTestScope():void {
      assertEquals('1', Template.parse('{{ context.scopes }}').render( { 'context': new ContextDrop() } ));
      assertEquals('2', Template.parse('{%for i in dummy%}{{ context.scopes }}{%endfor%}').render( { 'context': new ContextDrop(), 'dummy': [1] } ));
      assertEquals('3', Template.parse('{%for i in dummy%}{%for i in dummy%}{{ context.scopes }}{%endfor%}{%endfor%}').render( { 'context': new ContextDrop(), 'dummy': [1] } ));
    }

    [Test]
    public function shouldTestScopeThroughProc():void {
      assertEquals('1', Template.parse('{{ s }}').render( { 'context': new ContextDrop(), 's': function(c:Object):Array { return c['context.scopes']; } } ));
      assertEquals('2', Template.parse('{%for i in dummy%}{{ s }}{%endfor%}').render( { 'context': new ContextDrop(), 's': function(c:Object):Array { return c['context.scopes']; }, 'dummy': [1] } ));
      assertEquals('3', Template.parse('{%for i in dummy%}{%for i in dummy%}{{ s }}{%endfor%}{%endfor%}').render( { 'context': new ContextDrop(), 's': function(c:Object):Array { return c['context.scopes']; }, 'dummy': [1] } ));
    }

    [Test]
    public function shouldTestScopeWithAssigns():void {
      assertEquals('variable', Template.parse('{% assign a = "variable"%}{{a}}').render( { 'context': new ContextDrop() } ));
      assertEquals('variable', Template.parse('{% assign a = "variable"%}{%for i in dummy%}{{a}}{%endfor%}').render( { 'context': new ContextDrop(), 'dummy': [1] } ));
      assertEquals('test', Template.parse('{% assign header_gif = "test"%}{{header_gif}}').render( { 'context': new ContextDrop() } ));
      assertEquals('test', Template.parse("{% assign header_gif = 'test'%}{{header_gif}}").render( { 'context': new ContextDrop() } ));
    }

    [Test]
    public function shouldTestScopeFromTags():void {
      assertEquals('1', Template.parse('{% for i in context.scopes_as_array %}{{i}}{% endfor %}').render( { 'context': new ContextDrop(), 'dummy': [1] } ));
      assertEquals('12', Template.parse('{%for a in dummy%}{% for i in context.scopes_as_array %}{{i}}{% endfor %}{% endfor %}').render( { 'context': new ContextDrop(), 'dummy': [1] } ));
      assertEquals('123', Template.parse('{%for a in dummy%}{%for a in dummy%}{% for i in context.scopes_as_array %}{{i}}{% endfor %}{% endfor %}{% endfor %}').render( { 'context': new ContextDrop(), 'dummy': [1] } ));
    }

    [Test]
    public function shouldTestAccessContextFromDrop():void {
      assertEquals('123', Template.parse('{%for a in dummy%}{{ context.loop_pos }}{% endfor %}').render( { 'context': new ContextDrop(), 'dummy': [1, 2, 3] } ));
    }

    [Test]
    public function shouldTestEnumerableDrop():void {
      assertEquals('123', Template.parse('{% for c in collection %}{{c}}{% endfor %}').render( { 'collection': new EnumerableDrop() } ));
    }
*/

    [Test]
    public function shouldTestEnumerableDropSize():void {
      assertEquals('3', Template.parse('{{collection.size}}').render( { 'collection': new EnumerableDrop() } ));
    }
  }
}

class ContextDrop extends liquid.Drop {
  // TODO Should this be in liquid.Drop?
  public function get context():liquid.Context { return _context; }
  public function get scopes():int { return _context.scopes.length; }

  public function get scopesAsArray():Array {
    var arr:Array = new Array(_context.scopes.length);
    for (var i:int = 0; i < arr.length; i++) {
      arr[i] = i;
    }
    return arr;
  }

  public function get loopPos():int {
    return _context.getItem('forloop.index');
  }

  //public function break():void {
    //Breakpoint.breakpoint();
  //}

  override public function beforeMethod(method:String):String {
    return _context.getItem(method);
  }
}

class ProductDrop extends liquid.Drop {
  protected function get callmenot():* { return "protected"; }
}

class TextDrop extends liquid.Drop {
  public function get array():Array { return ['text1', 'text2']; }
  public function get text():String { return 'text1'; }
}

class CatchallDrop extends liquid.Drop {
  override public function beforeMethod(method:String):String {
    return 'method: ' + method;
  }

  public function get texts():TextDrop { return new TextDrop(); }
  public function get catchall():CatchallDrop { return new CatchallDrop(); }
  //public function get context():ContextDrop { return new ContextDrop(); }
}

class EnumerableDrop extends liquid.Drop {
  public function get size():int { return 3; }

  public function each(f:Function):void {
    f.call(1);
    f.call(2);
    f.call(3);
  }
}
