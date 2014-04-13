class TranslatorParserException < Exception; end

class Parser

  attr_reader :command
  attr_reader :index
  attr_reader :vm_file

  def initialize(input_file=nil)
    if input_file
      new_file(input_file)
    end
  end

  # reinitizlizes state of parser
  def new_file(input_file)
    puts "Parsing new file '#{input_file.path}'"
    @vm_file = input_file

    @instructions = @vm_file.readlines
    @instructions.each do |i|
      i.gsub!(/\/\/.*/, '')
      i.strip!
    end
    @instructions.delete('')
    reset!
  end

  def has_more_commands?
    @instructions[@index]
  end

  def reset!
    @index = 0
    @command = @instructions[@index]
  end

  # Returns the current command's type
  def command_type
    return :PUSH_CONST_COMMAND if @command[/^push\sconstant/]
    return :ADD_COMMAND if @command[/^add$/]
    return :SUB_COMMAND if @command[/^sub$/]
    return :NEG_COMMAND if @command[/^neg$/]
    return :EQ_COMMAND if @command[/^eq$/]
    return :LT_COMMAND if @command[/^lt$/]
    return :GT_COMMAND if @command[/^gt$/]
    return :AND_COMMAND if @command[/^and$/]
    return :OR_COMMAND if @command[/^or$/]
    return :NOT_COMMAND if @command[/^not$/]
    return :PUSH_COMMAND if @command[/^push\s.*/]
    return :POP_COMMAND if @command[/^pop\s.*/]
    return :LABEL_COMMAND if @command[/^label\s.*/]
    return :IF_GOTO_COMMAND if @command[/^if-goto\s.*/]
    return :GOTO_COMMAND if @command[/^goto\s.*/]
    return :FUCNTION_COMMAND if @command[/^function\s.*/]

    raise TranslatorParserException.new("Unrecognized command '#{@command}' at instruction #{@index+1}")
  end

  # Reads the next command from the input and sets it as current command
  def advance
    raise TranslatorParserException.new('No more commands') unless has_more_commands?
    @index += 1
    @command = @instructions[@index]
  end

  # This function should only be called if parser has declared the current
  # command is a PUSH_CONST_COMMAND, PUSH_COMMAND, or POP_COMMAND.
  # <i>This function does not check if the command type</i>
  def cmd_index
    return @command[/(\d*)$/, 1]
  end

  # This function will return the second argument in a command.
  def cmd_arg2
    return @command.scan(/^.*\s(.*)\s|^.*\s(.*)$/) { |x, y|
      return x unless not x
      return y 
    }
  end
end