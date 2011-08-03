package support.phs.asserts {
  import asunit.errors.AssertionFailedError;
  import asunit.framework.Assert;

  import flash.utils.getQualifiedClassName;

  import flash.errors.IllegalOperationError;
  import flash.events.EventDispatcher;

  import liquid.Template;

  /**
   * A set of assert methods.  Messages are only displayed when an assert fails.
   */

  public class Assert extends asunit.framework.Assert {
    /**
     * Protect constructor since it is a static only class
     */
    public function Assert() {
    }

    /**
     * Asserts that the provided block does not throw an exception.
     *
     * @param	block
     */
    static public function assertDoesNotThrow(block:Function):void {
      try {
        block.call();
      } catch (e:Error) {
        // We throw AssertionFailedError so that our test shows F instead of E,
        // but we still need the stack trace for the error to debug.
        // TODO The formatting of the stack traces together doesn't look very good.
        throw new AssertionFailedError("expected no error, got " + getQualifiedClassName(e) + "\n" + e.getStackTrace());
      }
    }

    /**
     * Asserts that two arrays have the same length and contain the same
     * objects in the same order. If the arrays are not equal by this
     * definition an AssertionFailedError is thrown with the given message.
     * If the arrays contain arrays the same logic is recursed into those arrays.
     *
     * TODO Obsolete, remove
     */
    static public function assertEqualsNestedArrays(...args:Array):void {
      assertEqualsNested.apply(support.phs.asserts.Assert, args);
    }

    /**
     * Asserts that two objects are the same, handling Arrays, Objects and 
     * other types.
     * For an Array, they are verified to be the same length and all items are 
     * compared recursively.
     * For an Object, all the property names are extracted, they are verified 
     * to be the same, and all values are compared recursively.
     * For any other item they are verified to be equal.
     */
    static public function assertEqualsNested(...args:Array):void {
      var message:String;
      var expected:*;
      var actual:*;

      if(args.length == 2) {
        message = "";
        expected = args[0];
        actual = args[1];
      }
      else if(args.length == 3) {
        message = args[0];
        expected = args[1];
        actual = args[2];
      }
      else {
        throw new IllegalOperationError("Invalid argument count");
      }

      if (expected == null && actual == null) {
        return;
      }
      if ((expected == null && actual != null) || (expected != null && actual == null)) {
        failNotEquals(message, expected, actual);
      }
      
      // from here on: expected != null && actual != null
      if (getQualifiedClassName(expected) != getQualifiedClassName(actual)) {
        failNotEquals(message, expected, actual);
      }

      // from here on: expected same type as actual
      var i:int;
      if (expected is Array) {
        if (expected.length != actual.length) {
          failNotEquals(message, expected, actual);
        }
        for (i = 0; i < expected.length; i++) {
          assertEqualsNested(message, expected[i], actual[i]);
        }
      } else if (expected is Object) {
        var expectedPropNames:Array = [];
        var actualPropNames:Array = [];
        var p:String;
        for (p in expected) expectedPropNames.push(p);
        for (p in actual) actualPropNames.push(p);

        assertEqualsArrays(message, expectedPropNames, actualPropNames);

        for (i = 0; i < expectedPropNames.length; i++) {
          assertEqualsNested(message, expected[expectedPropNames[i]], actual[actualPropNames[i]]);
        }
      } else {
        assertEquals(message, expected, actual);
      }
    }

    /**
     * Asserts that an object is a certain class typpe.
     */
    static public function assertEqualsClass(...args:Array):void {
      var message:String;
      var expected:Class;
      var actual:*;

      if(args.length == 2) {
        message = "";
        expected = args[0];
        actual = args[1];
      }
      else if(args.length == 3) {
        message = args[0];
        expected = args[1];
        actual = args[2];
      }
      else {
        throw new IllegalOperationError("Invalid argument count");
      }

      assertEquals(expected, Liquid.getClass(actual));
    }

    /**
     * Asserts that a given template and assigns generate the expected output.
     *
     * TODO Convert this to use signature similar to other asserts
     */
    static public function assertTemplateResult(expected:String, template:String, assigns:Object = null, message:String = null):void {
      var t:Template = Template.parse(template);
      assertNotNull("Template failed to parse!", t);
      assertEquals(message, expected, t.render(assigns));
    }

    /**
     * Asserts that a given template and assigns match the expected output.
     *
     * TODO Convert this to use signature similar to other asserts
     */
    static public function assertTemplateResultMatches(expected:*, template:String, assigns:Object = null, message:String = null):void {
      if (!(expected is RegExp)) return assertTemplateResult(expected, template, assigns, message);

      var t:Template = Template.parse(template);
      assertNotNull("Template failed to parse!", t);
      assertMatches(message, expected, t.render(assigns));
    }

    // TODO These are copied from asunit.framework.Assert; would like to share, but its private?
    static private function failNotEquals(message:String, expected:Object, actual:Object):void {
      fail(format(message, expected, actual));
    }

    static private function format(message:String, expected:Object, actual:Object):String {
      var formatted:String = "";
      if(message != null) {
        formatted = message + " ";
      }
      return formatted + "expected:<" + expected + "> but was:<" + actual + ">";
    }
  }
}

