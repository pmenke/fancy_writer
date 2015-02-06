# encoding: utf-8
# This file is part of the fancy_writer gem.
# Copyright (c) 2014 Peter Menke.
# http://www.petermenke.de
#
# fancy_writer is free software: you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.
#
# fancy_writer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with fancy_writer. If not, see
# <http://www.gnu.org/licenses/>.
require 'spec_helper'

include FancyWriter

describe FancyWriter::FancyIO do

  # set up an initial corpus representation from the example file
  before(:each) do
    @string = String.new
    @enum = [1,2,3,4]
  end

  context 'FancyWriter' do

    context 'Static methods' do
      
      it 'performs basic interpolation correctly' do
        @pattern = 'The %speed %color fox'
        @args = { speed: 'quick', color: 'brown'}
        @result = FancyIO.interpol(@pattern, @args)
        @result.should eq "The quick brown fox"
      end
      
      it 'respects escaped percent signs' do
        @pattern = 'The %%speed %color fox'
        @args = { speed: 'quick', color: 'brown'}
        @result = FancyIO.interpol(@pattern, @args)
        @result.should eq "The %speed brown fox"
      end
      
      it 'respects escaped percent signs even in the very beginning' do
        @pattern = '%%speed %color fox'
        @args = { speed: 'quick', color: 'brown'}
        @result = FancyIO.interpol(@pattern, @args)
        @result.should eq "%speed brown fox"
      end
      
    end

    context 'Initialization' do
      
      it 'can take additional config and then be run with convert method' do 
         @writer = FancyIO.new(@string) 
         in_between = @writer.class.name
         @writer.convert do
           w "convert"
         end
         @string.should eq "convert\n" 
      end
      
    end

    context 'Basics' do
      it 'writes lines without method as they are' do
        @writer = FancyIO.new(@string) do
          w "Foo"
        end
        @string.should eq "Foo\n"
      end

      it 'also works with the aliases of write' do
        @writer = FancyIO.new(@string) do
          w "a"
          write "b"
          line "c"
        end
        @string.should eq "a\nb\nc\n"
      end
    end

    context 'Comments' do
      it "should write comments without options as '#'" do
        @writer = FancyIO.new(@string) do
          comment do
            w "Foo"
          end
        end
        @string.should eq "# Foo\n"
      end
      it 'should write comments with options correctly' do
        @writer = FancyIO.new(@string) do
          comment '//' do
            w "Foo"
          end
        end
        @string.should eq "// Foo\n"
      end
      it 'should write comments without indentation correctly' do
        @writer = FancyIO.new(@string) do
          comment '#', false do
            w "Foo"
          end
        end
        @string.should eq "#Foo\n"
      end
    end

    context 'Enumerables' do

      it 'produces the correct output for default enum config' do
        test_enum = @enum
        @writer = FancyIO.new(@string) do
          write_enum(test_enum)
        end
        @string.should eq "1,2,3,4\n"
      end

      it 'produces the correct output for a custom separator' do
        test_enum = @enum
        separator = ';'
        @writer = FancyIO.new(@string, enum_separator: separator) do
          write_enum(test_enum)
        end
        @string.should eq "1;2;3;4\n"
      end

      it 'produces the correct output for a custom quote symbol' do
        test_enum = @enum
        quote = "'"
        @writer = FancyIO.new(@string, enum_quote: quote) do
          write_enum(test_enum)
        end
        @string.should eq "'1','2','3','4'\n"
      end

      it 'produces the correct output for custom quote symbol and separator' do
        test_enum = @enum
        quote = "'"
        separator = ';'
        @writer = FancyIO.new(@string, enum_quote: quote, enum_separator: separator) do
          write_enum(test_enum)
        end
        @string.should eq "'1';'2';'3';'4'\n"
      end

    end

    context 'Blocks' do
      
      it 'produces correct blocks' do
        @writer = FancyIO.new(@string) do
          line 'before'
          block 'begin', 'end' do
            line 'inside'
          end
          line 'after'
        end
        @string.should eq "before\nbegin\n  inside\nend\nafter\n"
      end
      
      it 'produces correct blocks with custom indentation settings' do
        @writer = FancyIO.new(@string) do
          line 'before'
          block 'begin', 'end', 4 do
            line 'inside'
          end
          line 'after'
        end
        @string.should eq "before\nbegin\n    inside\nend\nafter\n"
      end
      
    end

    it 'exports a complex example correctly' do
      @writer = FancyIO.new(@string) do
        comment '# ' do
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
    end
  end
end
