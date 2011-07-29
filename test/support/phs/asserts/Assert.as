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
     */
    static public function assertEqualsNestedArrays(...args:Array):void {
      var message:String;
      var expected:Array;
      var actual:Array;

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
      if (expected.length != actual.length) {
        failNotEquals(message, expected, actual);
      }
      for (var i : int = 0; i < expected.length; i++) {
        var expectedIsArray:Boolean = expected[i] is Array;
        var actualIsArray:Boolean = actual[i] is Array;

        if (!expectedIsArray && !actualIsArray) {
          assertEquals(expected[i], actual[i]);
        }
        if (expectedIsArray && !actualIsArray) {
          failNotEquals(message, expected[i], actual[i]);
        }
        if (!expectedIsArray && actualIsArray) {
          failNotEquals(message, expected[i], actual[i]);
        }
        if (expectedIsArray && actualIsArray) {
          assertEqualsNestedArrays(expected[i], actual[i]);
        }
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

