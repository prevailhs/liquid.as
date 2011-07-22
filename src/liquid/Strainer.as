package liquid {
  import liquid.errors.ArgumentError;

  /**
   * Strainer is the parent class for the filters system.
   * New filters are mixed into the strainer class which is then instanciated for each liquid template render run.
   *
   * One of the strainer's responsibilities is to keep malicious method calls out
   */
  public dynamic class Strainer extends Object {
    private static const InternalMethod:RegExp = /^__/;

    private static var _requiredMethods:Array = ['__id__', '__send__', 'respondTo', 'extend', 'methods', 'class', 'objectId'];

    private static var _filters:Object = {};
    private var _context:Context;

    public function Strainer(context:Context) {
      _context = context;
    }

    public static function globalFilter(filter:*):void {
      if (!(filter is Object)) throw new liquid.errors.ArgumentError("Passed filter is not a module");
      _filters[filter.name] = filter;
    }

    public static function create(context:Context):Strainer {
      var strainer:Strainer = new Strainer(context);
      for (var k:String in _filters) {
        strainer.extend(_filters[k]);
      }
      return strainer;
    }

    public function respondTo(method:String, includePrivate:Boolean=false):Boolean {
      var methodName:String = method.toString();
      if (InternalMethod.test(methodName)) return false
      if (_requiredMethods.indexOf(methodName) >= 0) return false;
      return hasOwnProperty(method);
    }


    public function extend(f:Object):void {
      for (var k:String in f) {
        this[k] = f[k];
      }
    }

    // Returns the methods (i.e. properties) that could be called on this strainer;
    //  used mainly for test
    public function get methods():Array {
      var m:Array = [];
      for (var k:String in this) {
        m.push(k);
      }
      return m;
    }

    // FIXME Figure out if we need to do this
    // remove all standard methods from the bucket so circumvent security
    // problems
//    instance_methods.each do |m|
//      unless @@required_methods.include?(m.to_sym)
//        undef_method m
//      end
//    end
  }
}
