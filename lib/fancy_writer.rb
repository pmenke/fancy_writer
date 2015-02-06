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

require "fancy_writer/version"

module FancyWriter

  # FancyIO is the main class used for creating formatted writers.
  # See README.md for an exhaustive usage description.
  class FancyIO

    # This hash holds some default options that are used when
    # no other options are passed to the constructor.
    DEFAULT_OPTIONS = {
      enum_separator: ',',
      enum_quote: ''
    }

    # The internal stream (IO) to write formatted output to.
    attr_reader :stream

    # The stack for strings to be prepended to each line.
    attr_reader :prefix_stack

    # The separator string to use for printing enumerables.
    attr_reader :enum_separator

    # The quote symbol to use for printing enumerables.
    attr_reader :enum_quote

    # An attribute holding the caller object.
    attr_reader :caller


    # Initializes a new fancy writer instance that wraps
    # around the given io object +p_stream+.
    # The block contains the code for writing to that
    # stream.
    # @param p_stream [IO]    The stream to write into.
    # @option opts [String] :enum_separator The symbol to
    #                                       be used to separate
    #                                       values in enums.
    # @option opts [String] :enum_quote The symbol for quoting
    #                                   values in enums.
    # @option opts [Object] :caller The calling object, useful
    #                               when a method of it must
    #                               be called inside FancyWriter's
    #                               blocks.
    # @param @block   [Block] A block containing the
    #                         fancy writer code.
    def initialize(p_stream, opts={}, &block)
      @stream = p_stream
      @prefix_stack = []
      effective_opts = DEFAULT_OPTIONS.merge(opts)
      @enum_separator = effective_opts[:enum_separator]
      @enum_quote = effective_opts[:enum_quote]
      @caller = effective_opts[:caller]
      if block_given?
        instance_eval &block
      end
    end

    # Adds a new string to the prepend stack. These strings
    # will be added to each output line until the end of the
    # block is reached.
    # @param prepend_string [String] The string to be prepended
    #                                to each line in the given
    #                                block
    def prepend(prepend_string=' ', &block)
      @prefix_stack << prepend_string
      yield # &block
      @prefix_stack.pop
    end

    # Prepends each line in the given block with Ruby-style
    # comments ("# "). Another comment character can be passed
    # as a parameter.
    # @param comment_string [String] The comment character(s) to
    #                                be prepended to each line in
    #                                the given block.
    def comment(comment_string='#', space_sep=true, &block)
      if block_given?
        if space_sep
          prepend("#{comment_string} ", &block)
        else
          prepend("#{comment_string}", &block)
        end
      end
    end

    # Indents each line in the given block with spaces. The default
    # amount is 2, another number of spaces can be given as a
    # parameter.
    # @param number [Integer] The number of spaces to be used for
    #                         indentation in the given block.
    def indent(number=2, &block)
      prepend(' '*number, &block)
    end

    # Indents each line in the given block with tabs. The default
    # amount is 1, another number of tabs can be given as a
    # parameter.
    # @param number [Integer] The number of tabs to be used for
    #                         indentation in the given block.
    def tab_indent(number=1, &block)
      prepend("\t"*number, &block)
    end

    # Writes one or more lines to the output object, taking into
    # account all strings on the prefix stack (such as comment
    # symbols or indentations).
    # @param line [Object] The object(s) to be formatted and written
    #                      to the underlying writer.
    def write(*line)
      lines = lines==[] ? [''] : line
      lines.each do |l|
        write_line(l)
      end
    end

    # This is a helper method for writing a single enumerable.
    # @param p_enum [Enumerable] the enumerable to format and write.
    def write_enum(p_enum)
      write_line(p_enum)
    end

    # Adds an alias +w+ for the +write+ method.
    alias :w    :write

    # Adds an alias +line+ for the +write+ method.
    alias :line :write

    # Adds an alias +c+ for the +comment+ method.
    alias :c :comment

    # Adds an alias +i+ for the +indent+ method.
    alias :i :indent

    # Adds an alias +t+ for the +tab_indent+ method.
    alias :t :tab_indent

    # Adds an alias +e+ for the +write_enum+ method.
    alias :e :write_enum


    private

    # This method redirects failed message calls to the
    # caller object, if present, in order to provide the
    # user with method calls inside FancyWriter's blocks.
    def method_missing(meth, *args, &block)
      if caller.respond_to?(meth)
        caller.send(meth, *args, &block)
      else
        super
      end
    end

    # Internal method that performs the actual writing.
    # @param line [Object] the line to be written.
    def write_line(line)
      if line.kind_of? String
        formatted_line = line
      elsif line.kind_of? Enumerable
        formatted_line = join_enumerable(line)
      else
        formatted_line = line.to_s
      end
      stream << @prefix_stack.join('')
      stream << formatted_line
      stream << "\n"
    end

    # Joins together an enumerable, using configuration options
    # +enum_quote+ to quote the single values, and +enum_separator+ to
    # glue them together.
    # @param enum [Enumerable] the enumerable to format.
    def join_enumerable(enum)
      enum.collect{|e| "#{@enum_quote}#{e}#{@enum_quote}"}.join(@enum_separator)
    end

  end

end
