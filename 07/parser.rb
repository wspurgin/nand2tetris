class TranslatorParserException < Exception; end

class Parser


  PUSH_CONST_COMMAND = 0
  ADD_COMMAND = 1
  SUB_COMMAND = 2
  NEG_COMMAND = 3
  EQ_COMMAND = 4
  LT_COMMAND = 5
  GT_COMMAND = 6
  AND_COMMAND = 7
  OR_COMMAND = 8
  NOT_COMMAND = 9

  attr_reader :command
  attr_reader :index

  def initialize(input_file=nil)
    if input_file
      new_file(input_file)
    end
  end

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

  # Returns the current command's type
  def command_type
    return PUSH_CONST_COMMAND if @command[/^push\sconstant/]
    return ADD_COMMAND if @command[/^add$/]
    return SUB_COMMAND if @command[/^sub$/]
    return NEG_COMMAND if @command[/^neg$/]
    return EQ_COMMAND if @command[/^eq$/]
    return LT_COMMAND if @command[/^lt$/]
    return GT_COMMAND if @command[/^gt$/]
    return AND_COMMAND if @command[/^and$/]
    return OR_COMMAND if @command[/^or$/]
    return NOT_COMMAND if @command[/^not$/]

    raise TranslatorParserException.new("Unrecognized command '#{@command}' at instruction #{@index+1}")
  end

  def reset!
    @index = 0
    @command = @instructions[@index]
  end

  # Reads the next command from the input and sets it as current command
  def advance
    raise TranslatorParserException.new('No more commands') unless has_more_commands?
    @index += 1
    @command = @instructions[@index]
  end

  # This function should only be called if parser has declared the current
  # command is a PUSH_CONST_COMMAND. <i>This function does not check</i>
  def push_constant
    return @command[/(\d*)$/, 1]
  end

end