package liquid.tags {
  import flash.utils.getQualifiedClassName;

  import liquid.Block;
  import liquid.Context;
  import liquid.errors.SyntaxError;

  /**
   * "For" iterates over an array or collection.  Several useful variables are 
   * available to you within the loop.
   *
   * == Basic usage:
   *    {% for item in collection %}
   *      {{ forloop.index }}: {{ item.name }}
   *    {% endfor %}
   *
   * == Advanced usage:
   *    {% for item in collection %}
   *      <div {% if forloop.first %}class="first"{% endif %}>
   *        Item {{ forloop.index }}: {{ item.name }}
   *      </div>
   *    {% endfor %}
   *
   * You can also define a limit and offset much like SQL.  Remember
   * that offset starts at 0 for the first item.
   *
   *    {% for item in collection limit:5 offset:10 %}
   *      {{ item.name }}
   *    {% end %}             
   *
   *  To reverse the for loop simply use {% for item in collection reversed %}
   *
   * == Available variables:
   *
   * forloop.name:: 'item-collection'
   * forloop.length:: Length of the loop
   * forloop.index:: The current item's position in the collection;
   *                 forloop.index starts at 1. 
   *                 This is helpful for non-programmers who start believe
   *                 the first item in an array is 1, not 0.
   * forloop.index0:: The current item's position in the collection
   *                  where the first item is 0
   * forloop.rindex:: Number of items remaining in the loop
   *                  (length - index) where 1 is the last item.
   * forloop.rindex0:: Number of items remaining in the loop
   *                   where 0 is the last item.
   * forloop.first:: Returns true if the item is the first item.
   * forloop.last:: Returns true if the item is the last item.
   *
   */
  public class For extends Block {
    /* /(\w+)\s+in\s+(#{QuotedFragment}+)\s*(reversed)?/ */
    private static const Syntax:RegExp = Liquid.combineRegExp("(\\w+)\\s+in\\s+(", Liquid.QuotedFragment, "+)\\s*(reversed)?");
  
    private var _variableName:String;
    private var _collectionName:String;
    private var _name:String;
    private var _reversed:Boolean;
    private var _attributes:Object;

    public function For(tagName:String, markup:String, tokens:Array) {
      var matches:Array = markup.match(Syntax);
      if (matches) {
        _variableName = matches[1];
        _collectionName = matches[2];
        _name = matches[1] + '-' + matches[2];
        _reversed = matches[3];
        _attributes = {};
        for each (var pair:Array in Liquid.scan(markup, Liquid.TagAttributes)) {
          _attributes[pair[0]] = pair[1];
        }
        super(tagName, markup, tokens);
      } else {
        throw new liquid.errors.SyntaxError("Syntax Error in 'for loop' - Valid syntax: for [item] in [collection]");
      }
    }

    override public function render(context:Context):* {
      if (!context.registers['for']) context.registers['for'] = {};
      
      var collection:* = context.getItem(_collectionName);
      // TODO Support ranges, perhaps just make them an array
      //collection = collection.to_a if collection.is_a?(Range)
    
      if (!('forEach' in collection)) return '';

      var from:int;
      if (_attributes['offset'] == 'continue') {
        from = parseInt(context.registers['for'][_name]);
      } else {
        from = parseInt(context.getItem(_attributes['offset']));
      }
                                                 
      var limit:* = context.getItem(_attributes['limit']);
      var to:* = limit ? parseInt(limit) + from : null;
          
      var segment:Array = sliceCollectionUsingEach(collection, from, to);                 
      
      if (segment.length == 0) return '';
      
      if (_reversed) segment = segment.reverse();

      var result:Array = [];
        
      var length:int = segment.length;
            
      // Store our progress through the collection for the continue flag
      context.registers['for'][_name] = from + segment.length;
              
      context.stack(null, function():Array {
        for (var index:int = 0; index < segment.length; index++) {
          var item:* = segment[index];
          context.setItem(_variableName, item);
          context.setItem('forloop', {
            'name'    : _name,
            'length'  : length,
            'index'   : index + 1, 
            'index0'  : index, 
            'rindex'  : length - index,
            'rindex0' : length - index -1,
            'first'   : (index == 0),
            'last'    : (index == length - 1) });
          
          result.push(renderAll(_nodelist, context));
        }
        return result;
      });
      return result;
    }
        
    public function sliceCollectionUsingEach(collection:*, from:int, to:*):Array {
      var segments:Array = [];
      var yielded:int = 0;
      // PERF To share functions we just skip items with to > index; however 
      // this means we iterate through the entire array always
      collection.forEach(function(item:*, index:int, array:Array):void {
        if (to && to <= index) return;

        if (from <= index) {
          segments.push(item);
        }
      });

      return segments;
    }
  }
}
