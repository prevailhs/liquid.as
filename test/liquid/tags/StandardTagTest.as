package liquid.tags  {

  import asunit.asserts.*;
  import asunit.framework.IAsync;
  import flash.display.Sprite;

  import support.phs.asserts.*;
  import liquid.Context;
  import liquid.Tag;
  import liquid.Template;
  import liquid.errors.SyntaxError;

  public class StandardTagTest {

    [Inject]
    public var async:IAsync;

    [Inject]
    public var context:Sprite;


    [Before]
    public function setUp():void {
    };

    [After]
    public function tearDown():void {
    };

    [Test]
    public function shouldTestTag():void {
      var tag:Tag = new Tag('tag', null, []);
      assertEquals('liquid::tag', tag.name);
      assertEquals('', tag.render(new Context()));
    };

    [Test]
    public function shouldTestNoTransform():void {
      assertTemplateResult('this text should come out of the template without change...',
                           'this text should come out of the template without change...');

      assertTemplateResult('blah', 'blah');
      assertTemplateResult('<blah>', '<blah>');
      assertTemplateResult('|,.:', '|,.:');
      assertTemplateResult('', '');

      var text:String = ( <![CDATA[this shouldnt see any transformation either but has multiple lines
                            as you can clearly see here ...]]> ).toString();
      assertTemplateResult(text, text);
    };

    [Test]
    public function shouldTestHasABlockWhichDoesNothing():void {
      assertTemplateResult("the comment block should be removed  .. right?",
                           "the comment block should be removed {%comment%} be gone.. {%endcomment%} .. right?");

      assertTemplateResult('', '{%comment%}{%endcomment%}');
      assertTemplateResult('', '{%comment%}{% endcomment %}');
      assertTemplateResult('', '{% comment %}{%endcomment%}');
      assertTemplateResult('', '{% comment %}{% endcomment %}');
      assertTemplateResult('', '{%comment%}comment{%endcomment%}');
      assertTemplateResult('', '{% comment %}comment{% endcomment %}');

      assertTemplateResult('foobar', 'foo{%comment%}comment{%endcomment%}bar');
      assertTemplateResult('foobar', 'foo{% comment %}comment{% endcomment %}bar');
      assertTemplateResult('foobar', 'foo{%comment%} comment {%endcomment%}bar');
      assertTemplateResult('foobar', 'foo{% comment %} comment {% endcomment %}bar');

      assertTemplateResult('foo  bar', 'foo {%comment%} {%endcomment%} bar');
      assertTemplateResult('foo  bar', 'foo {%comment%}comment{%endcomment%} bar');
      assertTemplateResult('foo  bar', 'foo {%comment%} comment {%endcomment%} bar');

      assertTemplateResult('foobar', ( <![CDATA[foo{%comment%};
                                     {%endcomment%}bar]]> ).toString());
    };

    [Test]
    public function shouldTestFor():void {
      assertTemplateResult(' yo  yo  yo  yo ', '{%for item in array%} yo {%endfor%}', {'array': [1,2,3,4]});
      assertTemplateResult('yoyo', '{%for item in array%}yo{%endfor%}', {'array': [1,2]});
      assertTemplateResult(' yo ', '{%for item in array%} yo {%endfor%}', {'array': [1]});
      assertTemplateResult('', '{%for item in array%}{%endfor%}', {'array': [1,2]});
      var expected:String = ( <![CDATA[

  yo

  yo

  yo

]]> ).toString();

      var template:String = ( <![CDATA[
{%for item in array%}
  yo
{%endfor%}
]]> ).toString();
      assertTemplateResult(expected, template, {'array': [1,2,3]});
    };

    [Test]
    public function shouldTestForWithRange():void {
      assertTemplateResult(' 1  2  3 ', '{%for item in (1..3) %} {{item}} {%endfor%}');
    };

    [Test]
    public function shouldTestForWithVariable():void {
      assertTemplateResult(' 1  2  3 ', '{%for item in array%} {{item}} {%endfor%}', {'array': [1,2,3]});
      assertTemplateResult('123', '{%for item in array%}{{item}}{%endfor%}', {'array': [1,2,3]});
      assertTemplateResult('123', '{% for item in array %}{{item}}{% endfor %}', {'array': [1,2,3]});
      assertTemplateResult('abcd', '{%for item in array%}{{item}}{%endfor%}', {'array': ['a', 'b', 'c', 'd']});
      assertTemplateResult('a b c', '{%for item in array%}{{item}}{%endfor%}', {'array': ['a', ' ', 'b', ' ', 'c']});
      assertTemplateResult('abc', '{%for item in array%}{{item}}{%endfor%}', {'array': ['a', '', 'b', '', 'c']});
    };

    [Test]
    public function shouldTestForHelpers():void {
      var assigns:Object = {'array': [1,2,3] };
      assertTemplateResult(' 1/3  2/3  3/3 ',
                           '{%for item in array%} {{forloop.index}}/{{forloop.length}} {%endfor%}',
                           assigns);
      assertTemplateResult(' 1  2  3 ', '{%for item in array%} {{forloop.index}} {%endfor%}', assigns);
      assertTemplateResult(' 0  1  2 ', '{%for item in array%} {{forloop.index0}} {%endfor%}', assigns);
      assertTemplateResult(' 2  1  0 ', '{%for item in array%} {{forloop.rindex0}} {%endfor%}', assigns);
      assertTemplateResult(' 3  2  1 ', '{%for item in array%} {{forloop.rindex}} {%endfor%}', assigns);
      assertTemplateResult(' true  false  false ', '{%for item in array%} {{forloop.first}} {%endfor%}', assigns);
      assertTemplateResult(' false  false  true ', '{%for item in array%} {{forloop.last}} {%endfor%}', assigns);
    };

    [Test]
    public function shouldTestForAndIf():void {
      var assigns:Object = {'array': [1,2,3] };
      assertTemplateResult('+--',
                           '{%for item in array%}{% if forloop.first %}+{% else %}-{% endif %}{%endfor%}',
                           assigns);
    };

    [Test]
    public function shouldTestLimiting():void {
      var assigns:Object = {'array': [1,2,3,4,5,6,7,8,9,0]};
      assertTemplateResult('12', '{%for i in array limit:2 %}{{ i }}{%endfor%}', assigns);
      assertTemplateResult('1234', '{%for i in array limit:4 %}{{ i }}{%endfor%}', assigns);
      assertTemplateResult('3456', '{%for i in array limit:4 offset:2 %}{{ i }}{%endfor%}', assigns);
      assertTemplateResult('3456', '{%for i in array limit: 4 offset: 2 %}{{ i }}{%endfor%}', assigns);
    };

    [Test]
    public function shouldTestDynamicVariableLimiting():void {
      var assigns:Object = {'array': [1,2,3,4,5,6,7,8,9,0]};
      assigns['limit'] = 2;
      assigns['offset'] = 2;

      assertTemplateResult('34', '{%for i in array limit: limit offset: offset %}{{ i }}{%endfor%}', assigns);
    };

    [Test]
    public function shouldTestNestedFor():void {
      var assigns:Object = {'array': [[1,2],[3,4],[5,6]] };
      assertTemplateResult('123456', '{%for item in array%}{%for i in item%}{{ i }}{%endfor%}{%endfor%}', assigns);
    };

    [Test]
    public function shouldTestOffsetOnly():void {
      var assigns:Object = {'array': [1,2,3,4,5,6,7,8,9,0]};
      assertTemplateResult('890', '{%for i in array offset:7 %}{{ i }}{%endfor%}', assigns);
    };

    [Test]
    public function shouldTestPauseResume():void {
      var assigns:Object = {'array': {'items': [1,2,3,4,5,6,7,8,9,0]}};
      var markup:String = ( <![CDATA[
      {%for i in array.items limit: 3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit: 3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit: 3 %}{{i}}{%endfor%}
      ]]> ).toString();
      var expected:String = ( <![CDATA[
      123
      next
      456
      next
      789
      ]]> ).toString()
      assertTemplateResult(expected, markup, assigns);
    };

    [Test]
    public function shouldTestPauseResumeLimit():void {
      var assigns:Object = {'array': {'items': [1,2,3,4,5,6,7,8,9,0]}};
      var markup:String = ( <![CDATA[
      {%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:1 %}{{i}}{%endfor%}
      ]]> ).toString();
      var expected:String = ( <![CDATA[
      123
      next
      456
      next
      7
      ]]> ).toString()
      assertTemplateResult(expected, markup, assigns);
    };

    [Test]
    public function shouldTestPauseResumeBIGLimit():void {
      var assigns:Object = {'array': {'items': [1,2,3,4,5,6,7,8,9,0]}};
      var markup:String = ( <![CDATA[
      {%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:1000 %}{{i}}{%endfor%}
      ]]> ).toString();
      var expected:String = ( <![CDATA[
      123
      next
      456
      next
      7890
      ]]> ).toString()
        assertTemplateResult(expected, markup, assigns);
    };


    [Test]
    public function shouldTestPauseResumeBIGOffset():void {
      var assigns:Object = {'array': {'items': [1,2,3,4,5,6,7,8,9,0]}};
      var markup:String = ( <![CDATA[{%for i in array.items limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 %}{{i}}{%endfor%}
      next
      {%for i in array.items offset:continue limit:3 offset:1000 %}{{i}}{%endfor%}]]> ).toString();
      var expected:String = ( <![CDATA[123
      next
      456
      next
      ]]> ).toString();
        assertTemplateResult(expected, markup, assigns);
    };

    [Test]
    public function shouldTestAssignInOrder():void {
      var assigns:Object = {'var': 'content' };
      assertTemplateResult('var2:  var2:content', 'var2:{{var2}} {%assign var2 = var%} var2:{{var2}}', assigns);

    };

    [Test]
    public function shouldTestHyphenatedAssign():void {
      var assigns:Object = {'a-b': '1' };
      assertTemplateResult('a-b:1 a-b:2', 'a-b:{{a-b}} {%assign a-b = 2 %}a-b:{{a-b}}', assigns);

    };

    [Test]
    public function shouldTestAssignWithColonAndSpaces():void {
      var assigns:Object = {'var': {'a:b c': {'paged': '1' }}};
      assertTemplateResult('var2: 1', '{%assign var2 = var["a:b c"].paged %}var2: {{var2}}', assigns);
    };

    [Test]
    public function shouldTestCapture():void {
      var assigns:Object = {'var': 'content' };
      assertTemplateResult('content foo content foo ',
                           '{{ var2 }}{% capture var2 %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}',
                           assigns);
    };

    [Test]
    public function shouldTestCaptureDetectsBadSyntax():void {
      assertThrows(liquid.errors.SyntaxError, function():void {
        assertTemplateResult('content foo content foo ',
                             '{{ var2 }}{% capture %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}',
                             {'var': 'content' });
      });
    };

    [Test]
    public function shouldTestCase():void {
      var assigns:Object;

      assigns = {'condition': 2 };
      assertTemplateResult(' its 2 ',
                           '{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}',
                           assigns);

      assigns = {'condition': 1 };
      assertTemplateResult(' its 1 ',
                           '{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}',
                           assigns);

      assigns = {'condition': 3 };
      assertTemplateResult('',
                           '{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}',
                           assigns);

      assigns = {'condition': "string here" };
      assertTemplateResult(' hit ',
                           '{% case condition %}{% when "string here" %} hit {% endcase %}',
                           assigns);

      assigns = {'condition': "bad string here" };
      assertTemplateResult('',
                           '{% case condition %}{% when "string here" %} hit {% endcase %}',
                           assigns);
    };

    [Test]
    public function shouldTestCaseWithElse():void {
      var assigns:Object;

      assigns = {'condition': 5 };
      assertTemplateResult(' hit ',
                           '{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}',
                           assigns);

      assigns = {'condition': 6 };
      assertTemplateResult(' else ',
                           '{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}',
                           assigns);

      assigns = {'condition': 6 };
      assertTemplateResult(' else ',
                           '{% case condition %} {% when 5 %} hit {% else %} else {% endcase %}',
                           assigns);
    };

    [Test]
    public function shouldTestCaseOnSize():void {
      assertTemplateResult('',  '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', {'a': []});
      assertTemplateResult('1', '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', {'a': [1]});
      assertTemplateResult('2', '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', {'a': [1, 1]});
      assertTemplateResult('',  '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', {'a': [1, 1, 1]});
      assertTemplateResult('',  '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', {'a': [1, 1, 1, 1]});
      assertTemplateResult('',  '{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', {'a': [1, 1, 1, 1, 1]});
    };

    [Test]
    public function shouldTestCaseOnSizeWithElse():void {
      assertTemplateResult('else',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           {'a': []});

      assertTemplateResult('1',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           {'a': [1]});

      assertTemplateResult('2',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           {'a': [1, 1]});

      assertTemplateResult('else',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           {'a': [1, 1, 1]});

      assertTemplateResult('else',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           {'a': [1, 1, 1, 1]});

      assertTemplateResult('else',
                           '{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}',
                           {'a': [1, 1, 1, 1, 1]});
    };

    [Test]
    public function shouldTestCaseOnLengthWithElse():void {
      assertTemplateResult('else',
                           '{% case a.empty? %}{% when true %}true{% when false %}false{% else %}else{% endcase %}',
                           {});

      assertTemplateResult('false',
                           '{% case false %}{% when true %}true{% when false %}false{% else %}else{% endcase %}',
                           {});

      assertTemplateResult('true',
                           '{% case true %}{% when true %}true{% when false %}false{% else %}else{% endcase %}',
                           {});

      assertTemplateResult('else',
                           '{% case NULL %}{% when true %}true{% when false %}false{% else %}else{% endcase %}',
                           {});
    };

    [Test]
    public function shouldTestAssingFromCase():void {
      // Example from the shopify forums
      var code:String = "{% case collection.handle %}{% when 'menswear-jackets' %}{% assign ptitle = 'menswear' %}{% when 'menswear-t-shirts' %}{% assign ptitle = 'menswear' %}{% else %}{% assign ptitle = 'womenswear' %}{% endcase %}{{ ptitle }}";
      var template:Template = Template.parse(code);
      assertEquals("menswear",   template.render({"collection": {'handle': 'menswear-jackets'}}));
      assertEquals("menswear",   template.render({"collection": {'handle': 'menswear-t-shirts'}}));
      assertEquals("womenswear", template.render({"collection": {'handle': 'x'}}));
      assertEquals("womenswear", template.render({"collection": {'handle': 'y'}}));
      assertEquals("womenswear", template.render({"collection": {'handle': 'z'}}));
    };

    [Test]
    public function shouldTestCaseWhenOr():void {
      var code:String;

      code = '{% case condition %}{% when 1 or 2 or 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}';
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 1 });
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 2 });
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 3 });
      assertTemplateResult(' its 4 ', code, {'condition': 4 });
      assertTemplateResult('', code, {'condition': 5 });

      code = '{% case condition %}{% when 1 or "string" or null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}';
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 1 });
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 'string' });
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': null });
      assertTemplateResult('', code, {'condition': 'something else' });
    };

    [Test]
    public function shouldTestCaseWhenComma():void {
      var code:String;

      code = '{% case condition %}{% when 1, 2, 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}';
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 1 });
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 2 });
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 3 });
      assertTemplateResult(' its 4 ', code, {'condition': 4 });
      assertTemplateResult('', code, {'condition': 5 });

      code = '{% case condition %}{% when 1, "string", null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}';
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 1 });
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': 'string' });
      assertTemplateResult(' its 1 or 2 or 3 ', code, {'condition': null });
      assertTemplateResult('', code, {'condition': 'something else' });
    };

    [Test]
    public function shouldTestAssign():void {
      assertEquals('variable', Template.parse( '{% assign a = "variable"%}{{a}}'  ).render());
    };

    [Test]
    public function shouldTestAssignAnEmptyString():void {
      assertEquals('', Template.parse( '{% assign a = ""%}{{a}}'  ).render());
    };

    [Test]
    public function shouldTestAssignIsGlobal():void {
      assertEquals('variable',
                 Template.parse( '{%for i in (1..2) %}{% assign a = "variable"%}{% endfor %}{{a}}'  ).render());
    };

    [Test]
    public function shouldTestCaseDetectsBadSyntax():void {
      // FIXME This test doesn't throw, but seems to be a problem with 
      // detection in liquid.tags.Case with blank markup with when (or else)
//      assertThrows(liquid.errors.SyntaxError, function():void {
//        assertTemplateResult('',  '{% case false %}{% when %}true{% endcase %}', {});
//      });
      

      assertThrows(liquid.errors.SyntaxError, function():void {
        assertTemplateResult('',  '{% case false %}{% huh %}true{% endcase %}', {});
      });

    };

    [Test]
    public function shouldTestCycle():void {
      assertTemplateResult('one', '{%cycle "one", "two"%}');
      assertTemplateResult('one two', '{%cycle "one", "two"%} {%cycle "one", "two"%}');
      assertTemplateResult(' two', '{%cycle "", "two"%} {%cycle "", "two"%}');

      assertTemplateResult('one two one', '{%cycle "one", "two"%} {%cycle "one", "two"%} {%cycle "one", "two"%}');

      assertTemplateResult('text-align: left text-align: right',
      '{%cycle "text-align: left", "text-align: right" %} {%cycle "text-align: left", "text-align: right"%}');
    };

    [Test]
    public function shouldTestMultipleCycles():void {
      assertTemplateResult('1 2 1 1 2 3 1',
      '{%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%}');
    };

    [Test]
    public function shouldTestMultipleNamedCycles():void {
      assertTemplateResult('one one two two one one',
      '{%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %}');
    };

    [Test]
    public function shouldTestMultipleNamedCyclesWithNamesFromContext():void {
      var assigns:Object = {"var1": 1, "var2": 2 };
      assertTemplateResult('one one two two one one',
      '{%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %}', assigns);
    };

    [Test]
    public function shouldTestSizeOfArray():void {
      var assigns:Object = {"array": [1,2,3,4]};
      assertTemplateResult('array has 4 elements', "array has {{ array.size }} elements", assigns);
    };

    // TODO Enable when we support hash size in AS3
    //[Test]
    public function shouldTestSizeOfHash():void {
      var assigns:Object = {"hash": {'a': 1, 'b': 2, 'c': 3, 'd': 4}};
      assertTemplateResult('hash has 4 elements', "hash has {{ hash.size }} elements", assigns);
    };

    [Test]
    public function shouldTestIllegalSymbols():void {
      assertTemplateResult('', '{% if true == empty %}?{% endif %}', {});
      assertTemplateResult('', '{% if true == null %}?{% endif %}', {});
      assertTemplateResult('', '{% if empty == true %}?{% endif %}', {});
      assertTemplateResult('', '{% if null == true %}?{% endif %}', {});
    };

    [Test]
    public function shouldTestForReversed():void {
      var assigns:Object = {'array': [ 1, 2, 3] };
      assertTemplateResult('321', '{%for item in array reversed %}{{item}}{%endfor%}', assigns);
    };


    [Test]
    public function shouldTestIfchanged():void {
      var assigns:Object;

      assigns = {'array': [ 1, 1, 2, 2, 3, 3] };
      assertTemplateResult('123', '{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}', assigns);

      assigns = {'array': [ 1, 1, 1, 1] };
      assertTemplateResult('1', '{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}', assigns);
    };
  };
};
