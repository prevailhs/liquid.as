package liquid {

  import liquid.errors.FilterNotFound;

  /**
   * Holds variables. Variables are only loaded "just in time"
   * and are not evaluated as part of the render stage
   *
   *   {{ monkey }}
   *   {{ user.name }}
   *
   * Variables can be combined with filters:
   *
   *   {{ user | link }}
   *
   */
  public class Variable {
    private const FilterParser:RegExp = Liquid.combineRegExp("(?:", Liquid.FilterSeparator, "|(?:\\s*(?!(?:", Liquid.FilterSeparator, "))(?:", Liquid.QuotedFragment, "|\\S+)\\s*)+)");
    private var _markup:String;
    private var _name:String;
    private var _filters:Array;

    public function get name():String { return _name; }
    public function get filters():Array { return _filters; }

    public function Variable(markup:String) {
      _markup = markup;
      _name = null;
      _filters = [];
      var match:Array = markup.match(Liquid.combineRegExp("\\s*(", Liquid.QuotedFragment, ")(.*)"));
      if (match) {
        _name = match[1];
        var match2:Array = match[2].match(Liquid.combineRegExp(Liquid.FilterSeparator.source, "\\s*(.*)"));
        if (match2) {
          var filters:Array = Liquid.scan(match2[1], FilterParser);
          for each (var filter:String in filters) {
            var matches:Array = filter.match(/\s*(\w+)/);
            if (matches) {
              var filtername:String = matches[1];
              var argRegExp:RegExp = Liquid.combineRegExp("(?:", Liquid.FilterArgumentSeparator, "|", Liquid.ArgumentSeparator, ")\\s*(", Liquid.QuotedFragment, ")");
              var filterargs:Array = Liquid.flatten(Liquid.scan(filter, argRegExp));
              // TODO Ruby does filtername.to_sym, consider if we should trim it?
              _filters.push([filtername, filterargs]);
            }
          }
        }
      }
    }

    public function render(context:Object):Object {
      if (!_name) return '';
      // emulate @filters.inject(context[@name])
      var output:Object = context.getItem(_name);
      for each (var filter:Array in _filters) {
        var filterargs:Array = filter[1].map(function(item:*, index:int, array:Array):Object {
          return context.getItem(item);
        });
        try {
          output = context.invoke.apply(context, [filter[0], output].concat(filterargs));
        } catch (error:FilterNotFound) {
          throw new FilterNotFound("Error - filter '" + filter[0] + "' in '" + Liquid.trim(_markup) + "' could not be found.");
        }
      }
      return output;
    }
  }
}