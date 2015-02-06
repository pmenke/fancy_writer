# FancyWriter

FancyWriter is a wrapper around an IO object that allows you to augment text
blocks with whitespace indentation and comment symbols, and to format simple
CSV data series. It uses a simple DSL for defining indentations, comment
sections, and rules for symbol-separated value lists out of Enumerables.

This gem originated from the need to create files in a simple plain-text
format in which indentation is important: The TextGrid file format of Praat,
a software used for linguistic and phonetic analyses
(see [http://www.fon.hum.uva.nl/praat/](http://www.fon.hum.uva.nl/praat/)).

After creating the code for indentation, I added the other methods, since
they could easily benefit from the code that was already produced.

## Installation

Add this line to your application's Gemfile:

    gem 'fancy_writer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fancy_writer

## Basic usage

### Writing lines

Given an IO object that is suitable for writing (such as a file or stdout),
FancyWriter can use this IO object for creating formatted output:

```` Ruby
io = File.open('/foo/bar', 'w') # or any other writable IO
FancyWriter::FancyIO.new(io) do
  w 'Hello World!'
end
````

produces

````
Hello World!
````

The methods `write`, `w`, and `line` can be used to your liking to create
plain output. You can also pass multiple lines at once to such a method.
Newlines are added automatically between each line. So,

```` Ruby
FancyWriter::FancyIO.new(io) do
  w 'one', 'two', 'three'
end
````

produces

````
one
two
three
````

### Ading commented sections

You can mark a section of your document with comment symbols by wrapping the
section in a block given to the `comment` method (short version: `c`):

```` Ruby
FancyWriter::FancyIO.new(io) do
  comment do
    w 'This line is commented out.', 'This one, too.'
  end
end
````

````
# This line is commented out.
# This one, too.
````

As you can see, Ruby-style comments are used by default (including a single
trailing space to keep thind readable). To use another comment symbol, simply
pass it as a parameter to the method:

```` Ruby
FancyWriter::FancyIO.new(io) do
  comment('//') do
    w 'This is a C style comment.'
  end
  comment('%') do
    w 'This is a LaTeX style comment.'
  end
end
````

````
// This is a C style comment.
% This is a LaTeX style comment.
````

You can suppress the space separator by passing `false` as a second parameter.
In this case, you must specify the comment symbol parameter in any case.

```` Ruby
FancyWriter::FancyIO.new(io) do
  comment('#', false) do
    w 'This line is commented out.'
  end
end
````

````
#This line is commented out.
````

### Indentation

Similar to comment blocks you can mark sections that should be indented by a
certain amount of spaces (for tabs see below) with the `indent` method
(short version: `i`):

```` Ruby
FancyWriter::FancyIO.new(io) do
  w 'one'
  indent do
    w 'two'
    indent do
      w 'three'
    end
  end
end
````

````
one
  two
    three
````

You can see in this example that indentation (and also commenting) can be
nested. Multiple indentations will be added / concatenated.
By default, indentation uses two spaces. You can specify another amount
of spaces by giving a number as a parameter.
If you prefer tabs, you can use the method `tab_indent` (short version: `t`)
– it works similar, but uses tabs instead of spaces and defaults to *one*
tab symbol instead of *two* spaces.

```` Ruby
FancyWriter::FancyIO.new(io) do
  w 'one'
  tab_indent do
    w 'I'm indented with one tab symbol.'
    indent(8) do
      w 'Additionally, eight spaces.'
    end
  end
end
````

````
  I'm indented with one tab symbol.
          Additionally, eight spaces.
````

### Blocks

With "blocks" I refer to segments of text that have one single line that begins it and one line that ends it, and an additional body in between. Often, this
body is indented. The following three-line samples show different examples of
such blocks from different languages. Each first line is the beginning of a
block, each second line its body, each third line its ending:

```` HTML
<div>
  <p>Lorem ipsum dolor sit amet...</p>
</div>
````
```` Latex
\begin{section}
  Lorem ipsum dolor sit amet...
\end{section}
````
```` Bibtex
@article{User1999,
  author = {Joe User}
}
````

FancyWriter provides the `block` method (shortcut: `b`) to ease the process
of creating such blocks. This method expects two or three parameters and a
block. The first two parameters indicate the beginning and ending line, 
respectively. The third parameter is optional, it indicates the number of
spaces to be used for indentation (its default is 2 spaces).

So, the first example above (the HTML one) can be produced with FancyWriter
as follows:

```` Ruby
FancyWriter::FancyIO.new(io) do
  block '<div>', '</div>' do
    line '<p>Lorem ipsum dolor sit amet...</p>'
  end
end
````

While this feature in general does not appear to be very helpful, it can
be used in combination with custom patterns (see below) to produce blocks
dynamically. 

### Symbol-separated values

If you pass an Enumerable to `write_enum` (short version: `e`), the underlying
collection will be formatted as a symbol-separated list. By default, a comma
will be used to separate values, and the values themselves will be used as-is:

```` Ruby
FancyWriter::FancyIO.new(io) do
  write_enum [1,2,3,4]
end
````

````
1,2,3,4
````

You can specify another separator and a symbol used for quoting the single values
by passing them to the writer object during initialization. So, in order to use
a semicolon and single quotes, you can write:

```` Ruby
FancyWriter::FancyIO.new(io, {enum_quote: "'", enum_separator: ";"}) do
  write_enum [1,2,3,4]
end
````

````
'1';'2';'3';'4'
````

Note that also for this method, surrounding `comment` or indentation methods
are evaluated, meaning that also formatted number sequences will be indented
or commented out.

## An exhaustive example of basic usage

This is a somewhat artifical example, but it contains most of the methods
in action.

```` Ruby
FancyWriter::FancyIO.new(io) do
  comment '#' do
    line 'This is an example file.'
    line 'These comments explain the contents.'
  end
  line 'config:'
  indent 4 do
    line 'setting:'
    indent 4 do
      line 'some_key: some_value.'
      comment do
        line 'This is an inside comment.'
      end
    end
    line 'data:'
    indent 4 do
      write_enum %w(1,2,3,4)
      write_enum %w(5,6,7,8)
    end
  end
end
````

````
# This is an example file.
# These comments explain the contents.
config:
    setting:
        some_key: some_value.
        # This is an inside comment.
    data:
        1,2,3,4
        5,6,7,8
````

## Advanced usage 

### Custom line patterns

If you are working with file formats that use repeated patterns (usually
resulting from the language used), you can make your work even easier
by defining *named patterns*. These are basically strings with some
placeholders in them, which you can use to generate lines where these
placeholders are substituted with parameters.

With the possibility to generate named patterns, you can create your
own small DSL for the file format you are working with. This can
save time and make your code more legible.

Let me give an example with the following segment of an Apache configuration
file (let us further assume that you somehow need to generate these
config files in your Ruby scripts from some source):

```` conf
User wwwrun
Listen 80
DocumentRoot "/srv/www/htdocs"
LoadModule cgi_module modules/mod_cgi.so
LoadModule mime_module modules/mod_mime.so
LoadModule negotiation_module modules/mod_negotiation.so
LoadModule status_module modules/mod_status.so
````

Two things are important here: this configuration file follows a predefined syntax, and there are elements that repeat themselves. For these, you could define named patterns which serve several purposes: You do not need to spell out the complete line, you avoid repetition of formatting, and you can reduce errors. If you look at the end of the sample, you see many similar lines. If you define one pattern for them, you follow the DRY principle, you reduce the number of places to look for if a bug occurs, and you get a cleaner way of generating the file contents.

If you want to use named patterns, you need to delay the calling of the formatting method, because you need to insert the configuration fist. Thus, you do not call the formatting method directly on the newly created object  as in the examples above, or like this:

```` Ruby
FancyWriter::FancyIO.new(io) do
  # calls to line, block, comment, etc.
end
````

Instead, you assign the FancyWriter instance to a variable, perform the configuration, and finally call `convert` on the instance and give it a block with your formatting wishes:

```` Ruby
@writer = FancyWriter::FancyIO.new(io)
# Do your named pattern configuration here
@writer.add_line_config :load_module, "LoadModule %module modules/%file.so")
@writer.convert do
  # NOW, we can start writing!
  # insert your calls to line, block, comment, etc.
end
````

In this example, you can see how a named pattern can be inserted using the
`add_line_config` method. It expects a symbol (containing the name of the pattern) and the pattern itself. The symbol should follow the rules for method names in Ruby. You will see why in a few moments. 

The named pattern follows a convention similar to the one used for the `sprintf` string formatting. The difference is that *names* are used, such as `%method`. These names will, during text generation, be replaced with matching values from the hash passed to your custom line method. Thus, if you pass a hash containing the entry `method: "mime"`, then all occurrences of `%method` in that pattern will be replaced with `mime`. Literal `%` characters can be expressed by doubling them in the pattern: `%%`.

The pattern defined above basically inserts a line starting with 'LoadModule', and then a formatting of two parameters that you can give it during calling. You will be able to call this named pattern as if you call the pattern name as a method (that's why the pattern name should follow these rules).

You can generate the four module configurations from the example with this code:

```` Ruby
@writer = FancyWriter::FancyIO.new(io)
# Do your named pattern configuration here
@writer.add_line_config :load_module, "LoadModule %module modules/%file.so"
@writer.convert do
  load_module module: 'cgi_module', file: 'mod_cgi'
  load_module module: 'mime_module', file: 'mod_mime'
  load_module module: 'negotiation_module', file: 'mod_negotiation'
  load_module module: 'status_module', file: 'mod_status'
end
````

In a similar fashion, you could add patterns for the other lines in the configuration file. 

### Custom block patterns

Similar to this, you can also add patterns that create custom blocks. In these blocks, the beginning *and* ending text will be interpolated with the values you pass to the block. The functionality is similar to the one used for custom line patterns, with the following exceptions:

You configure a new block as follows:
```` Ruby
@writer.add_block_config block_name, begin_pattern, end_pattern, indentation
````

- `block_name` is the symbol to be used for the method call.
- `begin_pattern` and `end_pattern` are patterns for the strings that you want to use to surround your block. Here, you can add `%field` definitions in places where you want to put a variable value.
- `indentation` declares the number of spaces to use for block indentation.

The difference in calling a block pattern is that you pass a (Ruby) block to it that contains rules for creating the body of the block:

```` Ruby
@writer.add_block_config :xml_tag, '<%tagname>', '</%tagname>', 2
@writer.convert do1
  xml_tag tagname: 'div' do
    xml_tag tagname: 'p' do 
      line 'Hello world!'
    end
  end
end
````
thus produces
````XML
<div>
  <p>
    Hello World!
  </p>
</div>
````

*(Of course there are dozens of better and more efficient ways to actually output XML, this is supposed to be just a comprehensible example.)*

## Issues

### Context and scope

It is not possible at the moment to access member variables
inside a `FancyIO.new` block. This is due to the way
`instance_eval` works (which is used internally to evaluate
the formatting blocks). If you need access to the context
of the calling object,

1. use accessor methods instead of variables,
2. add `caller: self` to the options passed during creation
of the fancy writer object:

```` Ruby
FancyWriter::FancyIO.new(io, {..., caller: self}) do
  ...
end
````

Then, the writer will know about the context of the object.
Internally, it will try to send method calls to the origin
object whenever `method_missing` reports a method call for
which the writer does not have a counterpart.

Found another problem? Is something not working? Contact me,
ideally by creating an issue on Github.

[https://github.com/pmenke/fancy_writer/issues](https://github.com/pmenke/fancy_writer/issues)

Please browse existing issues first, to avoid double postings.

## Release history

### 1.0.2 – named pattern support (6 Feb 2015)

- __[#4](https://github.com/pmenke/fancy_writer/issues/4) implemented.__
Adds support for custom line patterns
- __[#2](https://github.com/pmenke/fancy_writer/issues/2) implemented.__
Adds support for custom block patterns


### 1.0.1 – block support (6 Feb 2015)

- __[#1](https://github.com/pmenke/fancy_writer/issues/1) implemented.__
Adds support for blocks
- __[#3](https://github.com/pmenke/fancy_writer/issues/3) implemented.__
Minor code improvements

### 1.0.0 – initial version (28 Mar 2014)

- First version of the gem, basic support for lines, comments, indentation.

## Contributing

Any ideas are welcome!  Either

1. Fork it ( http://github.com/<my-github-username>/fancy_writer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

or create an issue on github:

[https://github.com/pmenke/fancy_writer/issues](https://github.com/pmenke/fancy_writer/issues)

Please browse existing issues first, to avoid double postings.

## Copyright and License

FancyWriter is free software: you can redistribute it and/or modify
it under the terms of the **GNU Lesser General Public License** as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

FancyWriter is distributed in the hope that it will be useful,
but **WITHOUT ANY WARRANTY**; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.

See LICENSE.txt for further details.
