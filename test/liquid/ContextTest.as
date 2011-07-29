package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;

  import liquid.errors.ContextError;

  public class ContextTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;

    private var instance:Context;

    [Before]
    public function setUp():void {
      instance = new Context();
    }

    [After]
    public function tearDown():void {
      instance = null;
    }

    // TODO Consider splitting into sub-tests
    [Test]
    public function shouldTestVariables():void {
      instance.setItem('string', 'string');
      assertEquals('string', instance.getItem('string'));

      instance.setItem('num', 5);
      assertEquals(5, instance.getItem('num'));

      instance.setItem('time', Date.parse('2006/06/06 12:00:00'));
      assertEquals(Date.parse('2006/06/06 12:00:00'), instance.getItem('time'));

      // TODO Is this necessary, just Date on AS3
      //instance.setItem('date', Date.today);
      //assertEquals(Date.today, instance.getItem('date'));

      var now:Date = new Date();
      instance.setItem('datetime', now);
      assertEquals(now, instance.getItem('datetime'));

      instance.setItem('bool', true);
      assertEquals(true, instance.getItem('bool'));

      instance.setItem('bool', false);
      assertEquals(false, instance.getItem('bool'));

      instance.setItem('null', null);
      assertEquals(null, instance.getItem('null'));
      assertEquals(null, instance.getItem('null'));
    }

    [Test]
    public function shouldTestVariablesNotExisting():void {
      assertEquals(null, instance.getItem('does_not_exist'));
    }

    [Test]
    public function shouldTestScoping():void {
      assertDoesNotThrow(function():void {
        instance.push();
        instance.pop();
      });

      assertThrows(liquid.errors.ContextError, function():void {
        instance.pop();
      });

      assertThrows(liquid.errors.ContextError, function():void {
        instance.push();
        instance.pop();
        instance.pop();
      });
    }

    [Test]
    public function shouldTestLengthQuery():void {
      instance.setItem('numbers', [1, 2, 3, 4]);
      assertEquals(4, instance.getItem('numbers.size'));

      // TODO Enable when we put in support for counting properties on objects
      //instance.setItem('numbers', {1: 1, 2: 2, 3: 3, 4: 4});
      //assertEquals(4, instance.getItem('numbers.size'));

      instance.setItem('numbers', {1: 1, 2: 2, 3: 3, 4: 4, 'size': 1000});
      assertEquals(1000, instance.getItem('numbers.size'));
    }

    [Test]
    public function shouldTestHyphenatedVariable():void {
      instance.setItem('oh-my', 'godz');
      assertEquals('godz', instance.getItem('oh-my'));
    }

    [Test]
    public function shouldTestAddFilter():void {
      var filter:Object = {
        'hi': function(output:String):String {
          return output + ' hi!';
        }
      }

      var context:Context = new Context();
      context.addFilters(filter);
      assertEquals('hi? hi!', context.invoke('hi', 'hi?'));

      context = new Context();
      assertEquals('hi?', context.invoke('hi', 'hi?'));

      context.addFilters(filter);
      assertEquals('hi? hi!', context.invoke('hi', 'hi?'));
    }

    [Test]
    public function shouldTestOverrideGlobalFilter():void {
      var global:Object = {
        "notice": function(output:String):String {
          return "Global " + output;
        }
      }

      var local:Object = {
        "notice": function(output:String):String {
          return "Local " + output;
        }
      }

      Template.registerFilter(global);
      assertEquals('Global test', Template.parse("{{'test' | notice }}").render());
      assertEquals('Local test', Template.parse("{{'test' | notice }}").render({}, {'filters': [local]}));
    }

    [Test]
    public function shouldTestOnlyIntendedFiltersMakeItThere():void {
      var filter:Object = {
        "hi":  function(output:String):String {
          return output + ' hi!';
        }
      }

      var context:Context = new Context();
      var methodsBefore:Array = context.strainer.methods.map(function(method:*, index:int, array:Array):String {
        return method.toString();
      });
      context.addFilters(filter);
      var methodsAfter:Array = context.strainer.methods.map(function(method:*, index:int, array:Array):String {
        return method.toString();
      });
      assertEqualsNestedArrays(methodsBefore.concat(["hi"]).sort(), methodsAfter.sort());
    }

    [Test]
    public function shouldTestAddItemInOuterScope():void {
      instance.setItem('test', 'test');
      instance.push();
      assertEquals('test', instance.getItem('test'));
      instance.pop();
      assertEquals('test', instance.getItem('test'));
    }

    [Test]
    public function shouldTestAddItemInInnerScope():void {
      instance.push();
      instance.setItem('test', 'test');
      assertEquals('test', instance.getItem('test'));
      instance.pop();
      assertEquals(null, instance.getItem('test'));
    }

    [Test]
    public function shouldTestHierachicalData():void {
      instance.setItem('hash', { "name": 'tobi' } );
      assertEquals('tobi', instance.getItem('hash.name'));
      assertEquals('tobi', instance.getItem('hash["name"]'));
    }

    [Test]
    public function shouldTestKeywords():void {
      assertEquals(true, instance.getItem('true'));
      assertEquals(false, instance.getItem('false'));
    }

    [Test]
    public function shouldTestDigits():void {
      assertEquals(100, instance.getItem('100'));
      assertEquals(100.00, instance.getItem('100.00'));
    }

    [Test]
    public function shouldTestStrings():void {
      assertEquals("hello!", instance.getItem('"hello!"'));
      assertEquals("hello!", instance.getItem("'hello!'"));
    }

    [Test]
    public function shouldTestMerge():void {
      instance.merge( { "test": "test" } );
      assertEquals('test', instance.getItem('test'));
      instance.merge( { "test": "newvalue", "foo": "bar" } );
      assertEquals('newvalue', instance.getItem('test'));
      assertEquals('bar', instance.getItem('foo'));
    }

    [Test]
    public function shouldTestArrayNotation():void {
      instance.setItem('test', [1, 2, 3, 4, 5]);

      assertEquals(1, instance.getItem('test[0]'));
      assertEquals(2, instance.getItem('test[1]'));
      assertEquals(3, instance.getItem('test[2]'));
      assertEquals(4, instance.getItem('test[3]'));
      assertEquals(5, instance.getItem('test[4]'));
    }

    [Test]
    public function shouldTestRecursiveArrayNotation():void {
      instance.setItem('test', { 'test': [1, 2, 3, 4, 5] } );
      assertEquals(1, instance.getItem('test.test[0]'));

      instance.setItem('test', [ { 'test': 'worked' } ]);
      assertEquals('worked', instance.getItem('test[0].test'));
    }

    [Test]
    public function shouldTestHashToArrayTransition():void {
      instance.setItem('colors', {
        'Blue':     ['003366','336699', '6699CC', '99CCFF'],
        'Green':    ['003300','336633', '669966', '99CC99'],
        'Yellow':   ['CC9900','FFCC00', 'FFFF99', 'FFFFCC'],
        'Red':      ['660000','993333', 'CC6666', 'FF9999']
      });

      assertEquals('003366', instance.getItem('colors.Blue[0]'));
      assertEquals('FF9999', instance.getItem('colors.Red[3]'));
    }

    [Test]
    public function shouldTestTryFirst():void {
      instance.setItem('test', [1, 2, 3, 4, 5]);
      assertEquals(1, instance.getItem('test.first'));
      assertEquals(5, instance.getItem('test.last'));

      instance.setItem('test', { 'test': [1, 2, 3, 4, 5] } );
      assertEquals(1, instance.getItem('test.test.first'));
      assertEquals(5, instance.getItem('test.test.last'));

      instance.setItem('test', [1]);
      assertEquals(1, instance.getItem('test.first'));
      assertEquals(1, instance.getItem('test.last'));
    }

    [Test]
    public function shouldTestAccessHashesWithHashNotation():void {
      instance.setItem('products', { 'count': 5, 'tags': ['deepsnow', 'freestyle'] } );
      instance.setItem('product', { 'variants': [ { 'title': 'draft151cm' }, { 'title': 'element151cm' }  ] } );

      assertEquals(5, instance.getItem('products["count"]'));
      assertEquals('deepsnow', instance.getItem('products["tags"][0]'));
      assertEquals('deepsnow', instance.getItem('products["tags"].first'));
      assertEquals('draft151cm', instance.getItem('product["variants"][0]["title"]'));
      assertEquals('element151cm', instance.getItem('product["variants"][1]["title"]'));
      assertEquals('draft151cm', instance.getItem('product["variants"][0]["title"]'));
      assertEquals('element151cm', instance.getItem('product["variants"].last["title"]'));
    }

    [Test]
    public function shouldTestAccessVariableWithHashNotation():void {
      instance.setItem('foo', 'baz');
      instance.setItem('bar', 'foo');

      assertEquals('baz', instance.getItem('["foo"]'));
      assertEquals('baz', instance.getItem('[bar]'));
    }

    [Test]
    public function shouldTestAccessHashesWithHashAccessVariables():void {
      instance.setItem('var', 'tags');
      instance.setItem('nested', { 'var': 'tags' } );
      instance.setItem('products', { 'count': 5, 'tags': ['deepsnow', 'freestyle'] } );

      assertEquals('deepsnow', instance.getItem('products[var].first'));
      assertEquals('freestyle', instance.getItem('products[nested.var].last'));
    }

    [Test]
    public function shouldTestHashNotationOnlyForHashAccess():void {
      instance.setItem('array', [1, 2, 3, 4, 5]);
      instance.setItem('hash', { 'first': 'Hello' } );

      assertEquals(1, instance.getItem('array.first'));
      assertEquals(null, instance.getItem('array["first"]'));
      assertEquals('Hello', instance.getItem('hash["first"]'));
    }

    [Test]
    public function shouldTestFirstCanAppearInMiddleOfCallchain():void {
      instance.setItem('product', { 'variants': [ { 'title': 'draft151cm' }, { 'title': 'element151cm' } ] } );

      assertEquals('draft151cm', instance.getItem('product.variants[0].title'));
      assertEquals('element151cm', instance.getItem('product.variants[1].title'));
      assertEquals('draft151cm', instance.getItem('product.variants.first.title'));
      assertEquals('element151cm', instance.getItem('product.variants.last.title'));
    }

    [Test]
    public function shouldTestCents():void {
      instance.merge( { "cents": new HundredCents() } );
      assertEquals(100, instance.getItem('cents'));
    }

    [Test]
    public function shouldTestNestedCents():void {
      instance.merge( { "cents": { 'amount': new HundredCents() } } );
      assertEquals(100, instance.getItem('cents.amount'));

      instance.merge( { "cents": { 'cents': { 'amount': new HundredCents() } } } );
      assertEquals(100, instance.getItem('cents.cents.amount'));
    }

    [Test]
    public function shouldTestCentsThroughDrop():void {
      instance.merge({"cents": new CentsDrop() });
      assertEquals(100, instance.getItem('cents.amount'));
    }

    [Test]
    public function shouldTestNestedCentsThroughDrop():void {
      instance.merge({"vars": {"cents": new CentsDrop()} });
      assertEquals(100, instance.getItem('vars.cents.amount'));
    }

    [Test]
    public function shouldTestDropMethodsWithQuestionMarks():void {
      instance.merge({"cents": new CentsDrop() });
      assertNotNull(instance.getItem('cents.non_zero?'));
    }

    [Test]
    public function shouldTestContextFromWithinDrop():void {
      instance.merge({"test": '123', "vars": new ContextSensitiveDrop() });
      assertEquals('123', instance.getItem('vars.test'));
    }

    [Test]
    public function shouldTestNestedContextFromWithinDrop():void {
      instance.merge({"test": '123', "vars": {"local": new ContextSensitiveDrop() }  });
      assertEquals('123', instance.getItem('vars.local.test'));
    }

    [Test]
    public function shouldTestRanges():void {
      instance.merge( { "test": '5' } );
      // NOTE AS3 doesn't have ranges, so emulate with array
      assertEqualsNestedArrays([1,2,3,4,5], instance.getItem('(1..5)'));
      assertEqualsNestedArrays([1,2,3,4,5], instance.getItem('(1..test)'));
      assertEqualsNestedArrays([5], instance.getItem('(test..test)'));
    }

    [Test]
    public function shouldTestCentsThroughDropNestedly():void {
      instance.merge({"cents": {"cents": new CentsDrop()}});
      assertEquals(100, instance.getItem('cents.cents.amount'));

      instance.merge({"cents": { "cents": {"cents": new CentsDrop()}}});
      assertEquals(100, instance.getItem('cents.cents.cents.amount'));
    }

    [Test]
    public function shouldTestDropWithVariableCalledOnlyOnce():void {
      instance.setItem('counter', new CounterDrop());

      assertEquals(1, instance.getItem('counter.count'));
      assertEquals(2, instance.getItem('counter.count'));
      assertEquals(3, instance.getItem('counter.count'));
    }

    [Test]
    public function shouldTestDropWithKeyCalledOnlyOnce():void {
      instance.setItem('counter', new CounterDrop());

      assertEquals(1, instance.getItem('counter["count"]'));
      assertEquals(2, instance.getItem('counter["count"]'));
      assertEquals(3, instance.getItem('counter["count"]'));
    }

    // AS3 doesn't have lambda and procs so just test Function
    [Test]
    public function shouldTestFunctionAsVariable():void {
      instance.setItem('dynamic', function():String { return 'Hello'; } );
      assertEquals('Hello', instance.getItem('dynamic'));
    }

    [Test]
    public function shouldTestNestedLambdaAsVariable():void {
      instance.setItem('dynamic', { "lambda": function():String { return 'Hello'; } } );
      assertEquals('Hello', instance.getItem('dynamic.lambda'));
    }

    [Test]
    public function shouldTestArrayContainingLambdaAsVariable():void {
      instance.setItem('dynamic', [1, 2, function():String { return 'Hello'; } , 4, 5]);
      assertEquals('Hello', instance.getItem('dynamic[2]'));
    }

    [Test]
    public function shouldTestLambdaIsCalledOnce():void {
      var global:int = 0;
      instance.setItem('callcount', function():String { global++; return global.toString(); } );

      assertEquals('1', instance.getItem('callcount'));
      assertEquals('1', instance.getItem('callcount'));
      assertEquals('1', instance.getItem('callcount'));

      global = 0;
    }

    [Test]
    public function shouldTestNestedLambdaIsCalledOnce():void {
      var global:int = 0;
      instance.setItem('callcount', { "lambda": function():String { global++; return global.toString(); }} );

      assertEquals('1', instance.getItem('callcount.lambda'));
      assertEquals('1', instance.getItem('callcount.lambda'));
      assertEquals('1', instance.getItem('callcount.lambda'));

      global = 0;
    }

    [Test]
    public function shouldTestLambdaInArrayIsCalledOnce():void {
      var global:int = 0;
      instance.setItem('callcount', [1, 2, function():String { global++; return global.toString(); } , 4, 5]);

      assertEquals('1', instance.getItem('callcount[2]'));
      assertEquals('1', instance.getItem('callcount[2]'));
      assertEquals('1', instance.getItem('callcount[2]'));

      global = 0;
    }

    [Test]
    public function shouldTestAccessToContextFromProc():void {
      instance.registers['magic'] = 345392;
      instance.setItem('magic', function():int { return instance.registers['magic']; } );

      assertEquals(345392, instance.getItem('magic'));
    }

    // FIXME CategoryDrop is defined local to this file, so class comparison 
    // can't instantiate it to test for equivalence.
    //[Test]
    public function shouldTestToLiquidAndContextAtFirstLevel():void {
      instance.setItem('category', new Category("foobar"));
      assertEqualsClass(CategoryDrop, instance.getItem('category'));
      assertEquals(instance, instance.getItem('category').context);
    }
  }
}

class HundredCents {
  public function toLiquid():int {
    return 100;
  }
}

class CentsDrop extends liquid.Drop {
  public function get amount():HundredCents { return new HundredCents(); }
  public function get nonZero():Boolean { return true; }
}

class ContextSensitiveDrop extends liquid.Drop {
  public function get test():* { return _context.getItem('test'); }
}

class Category extends liquid.Drop {
  private var _name:String;

  public function Category(name:String) {
    _name = name;
  }

  override public function toLiquid():* {
    new CategoryDrop(this);
  }
}

class CategoryDrop {
  private var _category:Category;
  
  public function CategoryDrop(category:Category) {
    _category = category
  }
}

class CounterDrop extends liquid.Drop {
  private var _count:int = 0;
  public function get count():int { return _count += 1; }
}

class ArrayLike {
  public function fetch(index:int):void { }
}
