


class AssemblerParserException < Exception; end

class Parser

  C_COMMAND = 0
  A_COMMAND = 1
  L_COMMAND = 2

  attr_reader :command

  def initialize(input_file)
    @asm_file = input_file

    @instructions = @asm_file.readlines
    @instructions.each do |i|
      i.gsub!(/\/\/.*/, '')
      i.strip!
    end
    @instructions.delete('')
    @index = 0
    @command = @instructions[@index]
  end

  def has_more_commands?
    @instructions[@index]
  end

  # Reads the next command from the input and sets it as current command
  def advance
    raise AssemblerParserException.new('No more commands') unless has_more_commands?
    @index += 1
    @command = @instructions[@index]
  end

  # Returns the current command's type
  def command_type
    return A_COMMAND if @command[/^@.*/]
    return L_COMMAND if @command[/^\(.*\)/]
    return C_COMMAND
  end

  # Returns the symbol or decimal Xxx of the current command @Xxx or (Xxx).
  # Should be called only when command_type() is A_COMMAND or L_COMMAND.
  def symbol
    # Return the 1st captured match of the regex. See http://www.ruby-doc.org/core-2.1.0/String.html#method-i-5B-5D
    return @command[/@(.*)/, 1]
  end

  # Returns the dest mnemonic in the current C-instruction (8 possibilities).
  # Should only be called when command_type() is C_COMMAND.
  def dest
    return @command[/^(.*)=/, 1]
  end

  # Returns the comp mnemonic in the current C-instruction (28 possibilities).
  # Should only be called when command_type() is C_COMMAND.
  def comp
    @command.scan(/^.*=(.*)$|(.*);/) { |x, y|
      return x unless not x
      return y
    }
  end

  # Returns the dest mnemonic in the current C-instruction (8 possibilities).
  # Should only be called when command_type() is C_COMMAND.
  def jump
    return @command[/;(.*)/, 1]
  end

end