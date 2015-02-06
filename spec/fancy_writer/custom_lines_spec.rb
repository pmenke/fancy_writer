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

  before(:each) do
    @string = String.new
    @writer = FancyIO.new(@string) 
  end
  
  context 'Custom lines' do
    
    it 'can store custom line configurations' do
      @writer.add_line_config(:custom, "Hi %s")
      @writer.custom_lines.should_not be nil
    end  

    it 'stores correct info for custom line configurations' do
      @writer.add_line_config(:custom, "Hi %s")
      @writer.custom_lines.has_key?(:custom).should be true
      @writer.custom_lines[:custom].should eq "Hi %s"
    end  
    
    it 'uses a stored line to produce correct output' do
      @writer.add_line_config(:custom, "Hi %who")
      @writer.convert do
        custom who: 'ho'
      end
      @string.should eq "Hi ho\n"
    end
    
    it 'converts also multi-value, complex patterns' do
      @writer.add_line_config :load_module, "LoadModule %module modules/%file.so"
      @writer.convert do
        load_module module: 'mime_module', file: 'mod_mime'
      end
      @string.should eq "LoadModule mime_module modules/mod_mime.so\n"
      puts @string
    end
    
    it 'converts patterns with special characters' do
      @writer.add_line_config :node, "\\node at (%x,%y) (%name) {%label};"
      @writer.convert do
        node x: 4, y: 2, name: 'node1', label: 'Source'
      end
      @string.should eq "\\node at (4,2) (node1) {Source};\n"
      puts @string
    end
    
  end
  
  context 'Custom blocks' do
    
    it 'can store custom block configurations' do
      @writer.add_block_config(:custom2, "begin", "end", 4)
      @writer.custom_blocks.should_not be nil
    end  

    it 'stores correct info for custom block configurations' do
      @writer.add_block_config(:custom2, "begin", "end", 4)
      @writer.custom_blocks.has_key?(:custom2).should be true
      @writer.custom_blocks[:custom2][0].should eq "begin"
      @writer.custom_blocks[:custom2][1].should eq "end"
      @writer.custom_blocks[:custom2][2].should eq 4
    end  
    
    it 'uses a stored block to produce correct output' do
      @writer.add_block_config(:custom2, "begin %name", "end %name", 4)
      @writer.convert do
        custom2 name: 'Heidi' do
          line 'Peter'
        end
      end
      @string.should eq "begin Heidi\n    Peter\nend Heidi\n"
    end
    
    
  end
  
end