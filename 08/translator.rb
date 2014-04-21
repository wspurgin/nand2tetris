#!/usr/bin/env ruby
# Author Will Spurgin
# 
# 

require_relative 'parser'

# === Translator Exception class
class TranslatorException < Exception; end

# == Translator class
class Translator

  def initialize(path)
    @files = []

    # strip '.vm' extension if exists
    path.chomp!('.vm')

    # <i>Love</i> the oneline-i-ness
    vm_path, vm_basename = File.split(path)

    @asm_filename = "#{vm_path}/#{vm_basename}.asm"
    @path = "#{vm_path}/#{vm_basename}"

    get_files
    # check for Sys.vm file, put it first (yay 1-liners)
    @files.sort_by! { |f| [ File.basename(f) == "Sys.vm" ? 0 : 1, f ]}
    @files.each {|file| puts "#{file} will be translated into #{@asm_filename}"}
    @parser = Parser.new
    @asm_file = File.open(@asm_filename, "w")
    @total_commands = 0
  end

  def get_files
    if Dir.exist?(@path) # get all '.vm' files in dir
      Dir.foreach(@path) { |file|
        if File.extname(file) == '.vm'
          @files << @path + '/' + file
        end
      }
      if @files.empty?
        raise TranslatorException.new("No files found with \'.vm\' extension in #{path}")
      end
    else
      @files = [@path + '.vm']
    end
  end

  def translate!
    set_main
    for file in @files
      File.open(file, "r") do |vm_file|
        @parser.new_file(vm_file)
        translate_command while @parser.has_more_commands?
        set_local_fun if file == @files.last
      end
    end
    puts "#{@asm_filename} created successfully"
  end

  def set_main
    asm = [
      "@256",
      "D=A",
      "@SP",
      "M=D", # set SP to 0x0100
    ]
    write(asm)
    translate_call("Sys.init", "0")
  end

  def set_local_fun
    asm = [
      "@__END__",
      "0;JMP",
      "(__setTrue__)",
      "  @SP",
      "  A=M",
      "  M=-1",
      "  @SP",
      "  M=M+1",
      "  @continue",
      "  A=M",
      "  0;JMP",
      "(__setFalse__)",
      "  @SP",
      "  A=M",
      "  M=0",
      "  @SP",
      "  M=M+1",
      "  @continue",
      "  A=M",
      "  0;JMP",
      "(__END__)"
    ]
    write(asm)
    @total_commands -= 3 # for 3 labels
  end

  def translate_command
    command_type = @parser.command_type
    if command_type == :PUSH_CONST_COMMAND
      translate_push_const(@parser.cmd_index)
    elsif command_type == :ADD_COMMAND
      translate_add
    elsif command_type == :SUB_COMMAND
      translate_sub
    elsif command_type == :NEG_COMMAND
      translate_neg
    elsif command_type == :EQ_COMMAND
      translate_eg
    elsif command_type == :LT_COMMAND
      translate_lt
    elsif command_type == :GT_COMMAND
      translate_gt
    elsif command_type == :AND_COMMAND
      translate_and
    elsif command_type == :OR_COMMAND
      translate_or
    elsif command_type == :NOT_COMMAND
      translate_not
    elsif command_type == :PUSH_COMMAND
      translate_push(@parser.cmd_arg2, @parser.cmd_index)
    elsif command_type == :POP_COMMAND
      translate_pop(@parser.cmd_arg2, @parser.cmd_index)
    elsif command_type == :LABEL_COMMAND
      translate_label(@parser.cmd_arg2)
    elsif command_type == :IF_GOTO_COMMAND
      translate_if_goto(@parser.cmd_arg2)
    elsif command_type == :GOTO_COMMAND
      translate_goto(@parser.cmd_arg2)
    elsif command_type == :FUNCTION_COMMAND
      translate_function(@parser.cmd_arg2, @parser.cmd_index)
    elsif command_type == :RETURN_COMMAND
      translate_return
    elsif command_type == :CALL_COMMAND
      translate_call(@parser.cmd_arg2, @parser.cmd_index)
    else
      puts "Couldn't translate '#{@parser.command}'"
    end
    @parser.advance  
  end

  def translate_push_const(index)
    asm = [
      "@#{index}",
      "D=A",
      "@SP",
      "A=M",
      "M=D",
      "@SP",
      "M=M+1"
    ]
    write(asm)
  end

  def translate_add
    asm = [
      "@SP",
      "M=M-1",
      "A=M",
      "D=M",
      "M=0",
      "@SP",
      "M=M-1",
      "A=M",
      "M=D+M",
      "@SP",
      "M=M+1"
    ]
    write(asm)
  end

  def translate_sub
    asm = [
      "@SP",
      "M=M-1",
      "A=M",
      "D=M",
      "M=0",
      "@SP",
      "M=M-1",
      "A=M",
      "M=M-D",
      "@SP",
      "M=M+1"
    ]
    write(asm)
  end

  def translate_neg
    asm = [
      "@SP",
      "A=M-1",
      "M=-M"
    ]
    write(asm)
  end

  def translate_eg
    asm = [
      "@#{@total_commands+17}",
      "D=A",
      "@continue",
      "M=D",
      "@SP",
      "M=M-1",
      "A=M",
      "D=M",
      "M=0",
      "@SP",
      "M=M-1",
      "A=M",
      "D=D-M",
      "@__setTrue__",
      "D;JEQ",
      "@__setFalse__",
      "D;JNE"
    ]
    write(asm)
  end

  def translate_lt
    asm = [
      "@#{@total_commands+17}",
      "D=A",
      "@continue",
      "M=D",
      "@SP",
      "M=M-1",
      "A=M",
      "D=M",
      "M=0",
      "@SP",
      "M=M-1",
      "A=M",
      "D=D-M",
      "@__setTrue__",
      "D;JGT",
      "@__setFalse__",
      "D;JLE"
    ]
    write(asm)
  end

  def translate_gt
    asm = [
      "@#{@total_commands+17}",
      "D=A",
      "@continue",
      "M=D",
      "@SP",
      "M=M-1",
      "A=M",
      "D=M",
      "M=0",
      "@SP",
      "M=M-1",
      "A=M",
      "D=D-M",
      "@__setTrue__",
      "D;JLT",
      "@__setFalse__",
      "D;JGE"
    ]
    write(asm)
  end

  def translate_and
    asm = [
      "@SP",
      "M=M-1",
      "A=M",
      "D=M",
      "M=0",
      "@SP",
      "M=M-1",
      "A=M",
      "M=D&M",
      "@SP",
      "M=M+1"
    ]
    write(asm)
  end

  def translate_or
    asm = [
      "@SP",
      "M=M-1",
      "A=M",
      "D=M",
      "M=0",
      "@SP",
      "M=M-1",
      "A=M",
      "M=D|M",
      "@SP",
      "M=M+1"
    ]
    write(asm)
  end

  def translate_not
    asm = [
      "@SP",
      "A=M-1",
      "M=!M"
    ]
    write(asm)
  end

  def get_mem_symbol(segment, index)
    symbol = nil
    case segment
    when "local"
      symbol = "LCL"
    when "argument"
      symbol = "ARG"
    when "this"
      symbol = "THIS"
    when "that"
      symbol = "THAT"
    when "temp"
      symbol = "#{5+index.to_i}"
    when "pointer"
      if index == "0"
        symbol = "3" # THIS
      elsif index == "1"
        symbol = "4" # THAT
      end

    when "static"
      symbol = "#{File.basename(@parser.vm_file, '.vm')}.#{index}"
    else
      raise TranslatorException.new("Unrecognized memory segment '#{segment}' in push command")
    end
    return symbol
  end

  def translate_push(segment, index)
    symbol = get_mem_symbol(segment, index)
    asm = []
    # Case statment for getting the proper value into D register
    case symbol
    when "LCL", "ARG", "THIS", "THAT"
      asm += [
        "@#{index}", # this first part is to get the proper value from memory
        "D=A",
        "@#{symbol}",
        "A=D+M",
        "D=M" # the value from symbol+index is now in D
      ]
    else
      asm += [
        "@#{symbol}",
        "D=M"
      ]
    end
    asm += [
      "@SP",
      "A=M",
      "M=D", # push value from D onto stack
      "@SP",
      "M=M+1"
    ]
    write(asm)
  end

  def translate_pop(segment, index)
    symbol = get_mem_symbol(segment, index)
    asm = []
    # Case statment for getting the proper address into R13
    case symbol
    when "LCL", "ARG", "THIS", "THAT"
      asm += [
        "@#{index}", # this first part is to get the proper memory address
        "D=A",
        "@#{symbol}",
        "D=D+M",
        "@R13",
        "M=D" # the address from symbol+index is now in R13
      ]
    else
      asm += [
        "@#{symbol}",
        "D=A",
        "@R13",
        "M=D"
      ]
    end
    # take address in R13 and pop from the stack to that address.
    asm += [
      "@SP",
      "AM=M-1",
      "D=M",
      "@R13",
      "A=M",
      "M=D", # value from stack now at proper memory address
    ]
    write(asm)
  end

  def translate_label(label_name)
    asm = ["(#{label_name})"]
    write(asm)
    @total_commands -= 1 # labels don't count as commands.
  end

  def translate_if_goto(label_name)
    asm = [
      "@SP",
      "AM=M-1",
      "D=M",
      "@#{label_name}",
      "D;JNE" # jump if top of stack is true (not 0)
    ]
    write(asm)
  end

  def translate_goto(label_name)
    asm = [
      "@#{label_name}",
      "0;JMP"
    ]
    write(asm)
  end

  def translate_function(fun_name, num_locals)
    translate_label(fun_name)
    asm = []
    num_locals.to_i.times do |i|
      asm += [
        "@SP",
        "A=M",
        "M=0",
        "@SP",
        "M=M+1"
      ]
    end
    write(asm)
  end

  def translate_return
    asm = [
      "//return",
      "@LCL",
      "D=M",
      "@R13",
      "M=D",
      "@5",
      "A=D-A",
      "D=M", # get return address
      "@command",
      "M=D", # store return address
      "@SP",
      "A=M-1",
      "D=M", # store return value
      "@ARG",
      "A=M",
      "M=D", # position return value
      "@ARG",
      "D=M+1", 
      "@SP",
      "M=D", # restore working stack
    ]
    # retore LCL, ARG, THIS, THAT
    args = ["LCL", "ARG", "THIS", "THAT"]
    i = 4
    for a in args
      asm += [
        "@R13",
        "D=M",
        "@#{i}",
        "A=D-A",
        "D=M",
        "@#{a}",
        "M=D"
      ]
      i -= 1
    end
    asm += [
      "@command",
      "A=M",
      "0;JMP" # jump to return address
    ]
    write(asm)
    @total_commands -= 1 # for comment
  end

  def translate_call(fun_name, num_args)
    asm = [
      "//call #{fun_name + " " + num_args}",
      "@#{@total_commands+47}",
      "D=A",
      "@SP",
      "A=M",
      "M=D", # push return address to stack
      "@SP",
      "M=M+1"
    ]
    args = ["LCL", "ARG", "THIS", "THAT"]
    for a in args
      asm += [
        "@#{a}",
        "D=M",
        "@SP",
        "A=M",
        "M=D",
        "@SP",
        "M=M+1",
      ]
    end
    asm += [
      "@#{num_args.to_i+5}",
      "D=A",
      "@SP",
      "D=M-D",
      "@ARG",
      "M=D",
      "@SP",
      "D=M",
      "@LCL",
      "M=D",
      "@#{fun_name}",
      "0;JMP"
    ]
    write(asm)
    @total_commands -= 1 # for comment
  end

  def write(asm)
    for cmd in asm
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end
end

puts "Translator"

# Expects only one argument, either single .vm filename, or a Dir
def args_valid?
  return ARGV.size == 1 && ((File.extname(ARGV[0]) == '.vm' && File.exist?(ARGV[0])) || Dir.exist?(ARGV[0]))
end



abort('Usage: ./translator.rb (Prog.vm || /dir/ProgamDir), the file or directory should exist') unless args_valid?

begin

  translator = Translator.new(ARGV[0].dup)
  translator.translate!

rescue Exception => e
  puts e.backtrace.join("\n")
  abort("\n#{e.message}")
end 