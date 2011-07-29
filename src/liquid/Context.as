package liquid {
  import liquid.errors.ArgumentError;
  import liquid.errors.ContextError;
  import liquid.errors.StackLevelError;

  import flash.utils.getQualifiedClassName;

  /**
   * Context keeps the variable stack and resolves variables, as well as keywords
   *
   *   context.setItem('variable', 'testing')
   *   context.getItem('variable')  *=> 'testing'
   *   context.getItem('true')      *=> true
   *   context.getItem('10.2232')   *=> 10.2232
   *
   *   context.stack do
   *      context.setItem('bob', 'bobsen');
   *   end
   *
   *   context.getItem('bob')   *=> nil
   */
  public class Context {
    // TODO Should any of these be dictionaries?
    private var _scopes:Array;
    private var _errors:Array;
    private var _registers:Object;
    private var _environments:Array;
    private var _rethrowErrors:Boolean;
    private var _strainer:Strainer;

    public function Context(environments:Object = null, outerScope:Object = null, registers:Object = null, rethrowErrors:Boolean = false) {
      if (!environments) environments = { };
      if (!outerScope) outerScope = { };
      if (!registers) registers = { };

      _environments   = Liquid.flatten([environments]);
      _scopes         = [outerScope];
      _registers      = registers;
      _errors         = [];
      _rethrowErrors  = rethrowErrors;
      squashInstanceAssignsWithEnvironments();
    }

    public function get strainer():Strainer {
      if (!_strainer) _strainer = Strainer.create(this);
      return _strainer;
    }

    /**
     * Adds filters to this context.
     *
     * Note that this does not register the filters with the main Template object. see <tt>Template.register_filter</tt>
     * for that
     */
    public function addFilters(filters:Object):void {
      filters = Liquid.compact(Liquid.flatten([filters]));

      for each (var f:* in filters) {
        if (!(f is Object)) throw new liquid.errors.ArgumentError("Expected module but got: " + getQualifiedClassName(f));
        strainer.extend(f);
      }
    }

    public function get scopes():Array { return _scopes; }
    public function get errors():Array { return _errors; }
    public function get registers():Object { return _registers; }

    public function handleError(e:Error):String {
      errors.push(e);
      if (_rethrowErrors) throw e;

      if (e is liquid.errors.SyntaxError) {
        return "Liquid syntax error: " + e.message;
      } else {
        return "Liquid error: " + e.message;
      }
    }

    public function invoke(method:String, ... args):* {
      if (method in strainer) {
        // TODO Is using this correct here for apply
        return strainer[method].apply(this, args);
      } else {
        return Liquid.first(args);
      }
    }

    /**
     * Push new local scope on the stack. use <tt>Context#stack</tt> instead
     */
    public function push(newScope:Object=null):void {
      if (!newScope) newScope = {};
      if (_scopes.length > 100) throw new StackLevelError("Nesting too deep");
      _scopes.unshift(newScope);
    }

    /**
     * Merge a hash of variables in the current local scope
     */
    public function merge(newScopes:Object):void {
      Liquid.mergeBang(_scopes[0], newScopes);
    }

    /**
     * Pop from the stack. use <tt>Context#stack</tt> instead
     */
    public function pop():Object {
      if (_scopes.length == 1) throw new ContextError();
      return _scopes.shift();
    }

    /**
     * Pushes a new local scope on the stack, pops it at the end of the block
     *
     * Example:
     *   context.stack do
     *      context['var'] = 'hi'
     *   end
     *
     *   context['var]  #=> nil
     */
    public function stack(newScope:Object, f:Function):* {
      if (!newScope) newScope = { };
      try {
        push(newScope);
        return f.call();
      } finally {
        pop();
      }
    }

    //def clear_instance_assigns
      //@scopes[0] = {}
    //end
//
    // Only allow String, Numeric, Hash, Array, Proc, Boolean or <tt>Liquid::Drop</tt>
    public function setItem(key:String, value:*):void {
      _scopes[0][key] = value;
    }

    public function getItem(key:String):* {
      return resolve(key);
    }

    public function hasItem(key:String):Boolean {
      return resolve(key) != null;
    }

    private static const LITERALS:Object = {
      //null: null, // TODO Is this one necessary?
      'nil': null, 'null': null, '': null,
      'true': true,
      'false': false,
      'blank': function(other:*):Boolean { 
        if (other is Array) return other.length == 0;
        if (other is String) return !other || other == '';
        if ('blank' in other) return other.blank();
        return false;
      },
      'empty': function(other:*):Boolean {
        if (other is Array) return other.length == 0;
        if (other is String) return !other || other == '';
        if ('empty' in other) return other.empty();
        return false;
      }
    }

    internal const SingleQuotedString:RegExp = /^'(.*)'$/;
    internal const DoubleQuotedString:RegExp = /^"(.*)"$/;
    internal const Integer:RegExp = /^(\d+)$/;
    internal const Range:RegExp = /^\((\S+)\.\.(\S+)\)$/;
    internal const Float:RegExp = /^(\d[\d\.]+)$/;
    /**
      * Look up variable, either resolve directly after considering the name. We can directly handle
      * Strings, digits, floats and booleans (true,false).
      * If no match is made we lookup the variable in the current scope and
      * later move up to the parent blocks to see if we can resolve the variable somewhere up the tree.
      * Some special keywords return symbols. Those symbols are to be called on the rhs object in expressions
      *
      * Example:
      *   products == empty #=> products.empty?
      */
    private function resolve(key:String):* {
      if (LITERALS.hasOwnProperty(key)) {
        return LITERALS[key];
      } else if (SingleQuotedString.test(key)) {
        return key.match(SingleQuotedString)[1];
      } else if (DoubleQuotedString.test(key)) {
        return key.match(DoubleQuotedString)[1];
      } else if (Integer.test(key)) {
        return parseInt(key.match(Integer)[1]);
      } else if (Range.test(key)) {
        var range:Array = key.match(Range);
        range[1] = resolve(range[1]);
        range[2] = resolve(range[2]);
        var left:Number = parseInt(range[1]);
        var right:Number = parseInt(range[2]);
        var arr:Array = [];
        var limit:int;
        var i:int;

        if (isNaN(left) || isNaN(right)) { // assume character range
          // TODO Add in error checking to make sure ranges are single 
          // character, A-Z or a-z, etc.
          left = range[0].charCodeAt(0);
          right = range[1].charCodeAt(0);

          limit = right-left+1;
          for (i=0; i<limit; i++) arr.push(String.fromCharCode(i+left)); 
        } else { // numeric range
          limit = right-left+1;
          for (i=0; i < limit; i++) arr.push(left+i);
        }
        return arr;
      } else if (Float.test(key)) {
        return parseFloat(key.match(Float)[1]);
      } else {
        return variable(key);
      }
    }

    // Fetches an object starting at the local scope and then moving up the 
    // hierachy
    private function findVariable(key:String):* {
      // TODO What type is scope?
      var scope:Object = Liquid.first(_scopes.filter(function(s:*, index:int, array:Array):Boolean {
        return s.hasOwnProperty(key);
      }));

      if (!scope) {
        // TODO What type is environment?
        for each (var e:Object in _environments) {
          var v:* = lookupAndEvaluate(e, key);
          if (v) {
            scope = e;
            break;
          }
        }
      }

      if (!scope) scope = Liquid.last(_environments);
      if (!scope) scope = Liquid.first(_scopes);
      if (!v) v = lookupAndEvaluate(scope, key);

      v = toLiquid(v);
      if (v && 'context' in v) v.context = this;

      return v;
    }

    /**
      * Resolves namespaced queries gracefully.
      *
      * Example
      *  @context.getItem('hash') = {"name" => 'tobi'}
      *  assert_equal 'tobi', @context.getItem('hash.name')
      *  assert_equal 'tobi', @context.getItem('hash["name"]')
      */
    private function variable(markup:String):* {
      var parts:Array = Liquid.scan(markup, Liquid.VariableParser);
      var squareBracketed:RegExp = /^\[(.*)\]$/;

      var firstPart:String = parts.shift();

      var matches:Array = firstPart.match(squareBracketed);
      if (matches) {
        firstPart = resolve(matches[1]);
      }

      var object:* = findVariable(firstPart);
      if (object) {
        for each (var part:String in parts) {
          var partResolved:Array = part.match(squareBracketed);
          if (partResolved) part = resolve(partResolved[1]);

          // If object is a hash- or array-like object we look for the
          // presence of the key and if its available we return it
          if (object is Object && (part in object || object is Drop || (object is Array && part is int))) {

            // if its a proc we will replace the entry with the proc
            var res:* = lookupAndEvaluate(object, part);
            object = toLiquid(res);

            // Some special cases. If the part wasn't in square brackets and
            // no key with the same name was found we interpret following
            // calls as commands and call them on the current object.
            // AS3 doesn't have size, first and last so do the mapping if
            // necessary for Array
            // TODO Consider if we need to allow Object either
          } else if (!partResolved && (['size', 'first', 'last'].indexOf(part) >= 0) && ((part in object) || (object is Array))) {
            if (part in object) {
              object = toLiquid(object[part]);
            } else if (object is Array) { // Array
              switch(part) {
                case 'size': {
                  object = toLiquid(object.length);
                  break;
                }
                case 'first': {
                  object = toLiquid(Liquid.first(object));
                  break;
                }
                case 'last': {
                  object = toLiquid(Liquid.last(object));
                  break;
                }
              }
            }

            // No key was present with the desired value and it wasn't one
            // of the directly supported keywords either. The only thing we
            // got left is to return nil
          } else {
            return null;
          }

          // If we are dealing with a drop here we have to
          if ('context' in object) object.context = this;
        }
      }

      return object;
    }

    private function lookupAndEvaluate(obj:Object, key:String):* {
      // AS3 doesn't support :[] method, so need to detect drop and use invokeDrop
      var value:* = (obj is Drop) ? obj.invokeDrop(key) : obj[key];
      // TODO Verify its okay not to do the obj check, since all obj respond to []?
      //if (value = obj[key]).is_a?(Proc) && obj.respond_to?(:[]=)
      if (value is Function) {
        obj[key] = (value.length == 0) ? value.call(this) : value.call(this, this);
        return obj[key];
      } else {
        return value;
      }
    }

    private function squashInstanceAssignsWithEnvironments():void {
      // TODO What type is scope?
      var lastScope:Object = Liquid.last(_scopes);
      for (var k:String in lastScope) {
        // TODO What type is environment?
        for each (var env:Object in _environments) {
          if (env.hasOwnProperty(k)) {
            lastScope[k] = lookupAndEvaluate(env, k);
            break;
          }
        }
      }
    }

    private static function toLiquid(obj:*):* {
      if (obj && 'toLiquid' in obj) return obj.toLiquid();
      return obj;
    }
  }
}
