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

## Usage

### Basic usage and writing lines

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

## An exhaustive example

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
