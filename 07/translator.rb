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
    for file in @files
      File.open(file, "r") do |vm_file|
        @parser.new_file(vm_file)
        translate_command while @parser.has_more_commands?
        set_local_fun
      end
    end
    puts "#{@asm_filename} created successfully"
  end

  def set_local_fun
    asm_command = [
      "@END",
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
      "(END)"
    ]
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
    @total_commands -= 3 # for 3 labels
  end

  def translate_command
    if @parser.command_type == Parser::PUSH_CONST_COMMAND
      translate_push_command(@parser.push_constant)
    elsif @parser.command_type == Parser::ADD_COMMAND
      translate_add_command
    elsif @parser.command_type == Parser::SUB_COMMAND
      translate_sub_command
    elsif @parser.command_type == Parser::NEG_COMMAND
      translate_neg_command
    elsif @parser.command_type == Parser::EQ_COMMAND
      translate_eg_command
    elsif @parser.command_type == Parser::LT_COMMAND
      translate_lt_command
    elsif @parser.command_type == Parser::GT_COMMAND
      translate_gt_command
    elsif @parser.command_type == Parser::AND_COMMAND
      translate_and_command
    elsif @parser.command_type == Parser::OR_COMMAND
      translate_or_command
    elsif @parser.command_type == Parser::NOT_COMMAND
      translate_not_command
    else
      puts "Couldn't translate '#{@parser.command}'"
    end
    @parser.advance  
  end

  def translate_push_command(value)
    asm_command = [
      "@#{value}",
      "D=A",
      "@SP",
      "A=M",
      "M=D",
      "@SP",
      "M=M+1"
    ]
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_add_command
    asm_command = [
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
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_sub_command
    asm_command = [
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
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_neg_command
    asm_command = [
      "@SP",
      "A=M-1",
      "M=-M"
    ]
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_eg_command
    asm_command = [
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
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_lt_command
    asm_command = [
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
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_gt_command
    asm_command = [
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
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_and_command
    asm_command = [
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
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_or_command
    asm_command = [
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
    for cmd in asm_command
      @asm_file << cmd + "\n"
      @total_commands += 1
    end
  end

  def translate_not_command
    asm_command = [
      "@SP",
      "A=M-1",
      "M=!M"
    ]
    for cmd in asm_command
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