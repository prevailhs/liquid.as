package liquid {
  import liquid.errors.SyntaxError;

  /**
   * A drop in liquid is a class which allows you to to export DOM like things to liquid
   * Methods of drops are callable.
   * The main use for liquid drops is the implement lazy loaded objects.
   * If you would like to make data available to the web designers which you don't want loaded unless needed then
   * a drop is a great way to do that
   *
   * Example:
   *
   * class ProductDrop < Liquid::Drop
   *   def top_sales
   *      Shop.current.products.find(:all, :order => 'sales', :limit => 10 )
   *   end
   * end
   *
   * tmpl = Liquid::Template.parse( ' {% for product in product.top_sales %} {{ product.name }} {%endfor%} '  )
   * tmpl.render('product' => ProductDrop.new )  * will invoke top_sales query.
   *
   * Your drop can either implement the methods sans any parameters or implement the before_method(name) method which is a
   * catch all
   */
  public class Drop {
    protected var _context:Context;

    public function set context(value:Context):void { _context = value; }

    public function beforeMethod(method:String):String {
      return '';
    }

    public function invokeDrop(method:String):* {
      if (method in this) {
        // AS3 Getters are different than methods and as such we need to differentiate here
        var res:* = this[method];
        return (res is Function) ? res.call(this) : res;
      } else {
        return beforeMethod(method);
      }
    }

    public function hasKey(name:String):Boolean { return true; }

    public function toLiquid():* { return this; }
  }
}