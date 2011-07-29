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


    [Before]
    public function setUp():void {
    }

    [After]
    public function tearDown():void {
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
      var output:String = Template.parse(' {{ product.texts.text }} ').render( { 'product': new ProductDrop() } );
      assertEquals(' text1 ', output);
    }

    [Test]
    public function shouldTestUnknownMethod():void {
      var output:String = Template.parse(' {{ product.catchall.unknown }} ').render( { 'product': new ProductDrop() } );
      assertEquals(' method: unknown ', output);
    }

    [Test]
    public function shouldTestTextArrayDrop():void {
      var output:String = Template.parse('{% for text in product.texts.array %} {{text}} {% endfor %}').render( { 'product': new ProductDrop() } );
      assertEquals(' text1  text2 ', output);
    }

    [Test]
    public function shouldTestContextDrop():void {
      var output:String = Template.parse(' {{ context.bar }} ').render( { 'context': new ContextDrop(), 'bar': "carrot" } );
      assertEquals(' carrot ', output);
    }

    // TODO Is this test misnamed?  Shouldn't it be 
    // shouldTestNestedProductDrop
    [Test]
    public function shouldTestNestedContextDrop():void {
      var output:String = Template.parse(' {{ product.context.foo }} ').render( { 'product': new ProductDrop(), 'foo': "monkey" } );
      assertEquals(' monkey ', output);
    }

    [Test]
    public function shouldTestProtected():void {
      var output:String = Template.parse(' {{ product.callmenot }} ').render( { 'product': new ProductDrop() } );
      assertEquals('  ', output);
    }

    [Test]
    public function shouldTestScope():void {
      assertEquals('1', Template.parse('{{ context.scopes }}').render( { 'context': new ContextDrop() } ));
      assertEquals('2', Template.parse('{%for i in dummy%}{{ context.scopes }}{%endfor%}').render( { 'context': new ContextDrop(), 'dummy': [1] } ));
      assertEquals('3', Template.parse('{%for i in dummy%}{%for i in dummy%}{{ context.scopes }}{%endfor%}{%endfor%}').render( { 'context': new ContextDrop(), 'dummy': [1] } ));
    }

    [Test]
    public function shouldTestScopeThroughProc():void {
      assertEquals('1', Template.parse('{{ s }}').render( { 'context': new ContextDrop(), 's': function(c:Object):* { return c.getItem('context.scopes'); } } ));
      assertEquals('2', Template.parse('{%for i in dummy%}{{ s }}{%endfor%}').render( { 'context': new ContextDrop(), 's': function(c:Object):* { return c.getItem('context.scopes'); }, 'dummy': [1] } ));
      assertEquals('3', Template.parse('{%for i in dummy%}{%for i in dummy%}{{ s }}{%endfor%}{%endfor%}').render( { 'context': new ContextDrop(), 's': function(c:Object):* { return c.getItem('context.scopes'); }, 'dummy': [1] } ));
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

    [Test]
    public function shouldTestEnumerableDropSize():void {
      assertEquals('3', Template.parse('{{collection.size}}').render( { 'collection': new EnumerableDrop() } ));
    }
  }
}

class ContextDrop extends liquid.Drop {
  public function get scopes():int { return _context.scopes.length; }

  public function get scopes_as_array():Array {
    var arr:Array = new Array(_context.scopes.length);
    for (var i:int = 0; i < arr.length; i++) {
      arr[i] = i+1;
    }
    return arr;
  }

  public function get loop_pos():int {
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

  public function get texts():TextDrop { return new TextDrop(); }
  public function get catchall():CatchallDrop { return new CatchallDrop(); }
  public function get context():* { return new ContextDrop(); }
}

class TextDrop extends liquid.Drop {
  public function get array():Array { return ['text1', 'text2']; }
  public function get text():String { return 'text1'; }
}

class CatchallDrop extends liquid.Drop {
  override public function beforeMethod(method:String):String {
    return 'method: ' + method;
  }
}

class EnumerableDrop extends liquid.Drop {
  public function get size():int { return 3; }

  public function forEach(f:Function):void {
    new Array(1,2,3).forEach(f);
  }
}
