package liquid  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;
  import flash.utils.getDefinitionByName;
  import flash.utils.getQualifiedClassName;

  import support.phs.asserts.*;

  import liquid.errors.*;

  public class ErrorHandlingTest {

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
    public function shouldTestStandardError():void {
      assertDoesNotThrow(function():void {
        var template:Template = liquid.Template.parse(' {{ errors.standardError }} ');
        assertEquals(' Liquid error: standard error ', template.render( { 'errors': new ErrorDrop() } ));

        assertEquals(1, template.errors.length);
        assertEquals(liquid.errors.StandardError, getDefinitionByName(getQualifiedClassName(Liquid.first(template.errors))));
      });
    }

    [Test]
    public function shouldTestSyntax():void {
      assertDoesNotThrow(function():void {
        var template:Template = liquid.Template.parse(' {{ errors.syntaxError }} ')
        assertEquals(' Liquid syntax error: syntax error ', template.render( { 'errors': new ErrorDrop() } ));

        assertEquals(1, template.errors.length);
        assertEquals(liquid.errors.SyntaxError, getDefinitionByName(getQualifiedClassName(Liquid.first(template.errors))));
      });
    }

    [Test]
    public function shouldTestArgument():void {
      assertDoesNotThrow(function():void {
        var template:Template = liquid.Template.parse(' {{ errors.argumentError }} ')
        assertEquals(' Liquid error: argument error ', template.render( { 'errors': new ErrorDrop() } ));

        assertEquals(1, template.errors.length);
        assertEquals(liquid.errors.ArgumentError, getDefinitionByName(getQualifiedClassName(Liquid.first(template.errors))));
      });
    }

    [Test]
    public function shouldTestMissingEndtagParseTimeError():void {
      assertThrows(liquid.errors.SyntaxError, function():void {
        var template:Template = liquid.Template.parse(' {% for a in b %} ... ');
      });
    }

// TODO Enable when if is implemented
/*
    [Test]
    public function shouldTestUnrecognizedOperator():void {
      assertDoesNotThrow(function():void {
        var template:Template = liquid.Template.parse(' {% if 1 =! 2 %}ok{%   }if %} ')
        assertEquals(' Liquid error: Unknown operator =! ', template.render());
        assertEquals(1, template.errors.length);
        assertEquals(liquid.errors.ArgumentError, getDefinitionByName(getQualifiedClassName(Liquid.first(template.errors))));
      });
    }
*/

    // Liquid should not catch Errors that are not subclasses of LiquidError, like Interrupt and NoMemoryError
    [Test]
    public function shouldTestExceptionsPropagate():void {
      assertThrows(Error, function():void {
        var template:Template = liquid.Template.parse(' {{ errors.error }} ');
        template.render( { 'errors': new ErrorDrop() } );
      });
    }
  }
}

class ErrorDrop extends liquid.Drop {
  public function get standardError():liquid.errors.StandardError {
    throw new liquid.errors.StandardError('standard error');
  }

  public function get argumentError():liquid.errors.ArgumentError {
    throw new liquid.errors.ArgumentError('argument error');
  }

  public function get syntaxError():liquid.errors.SyntaxError {
    throw new liquid.errors.SyntaxError('syntax error');
  }

  public function get error():Error {
    throw new Error('error');
  }
}
