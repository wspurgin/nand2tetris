#!/usr/bin/env ruby

# Will Spurgin
# A Hack assembler that is written in Ruby!
# usage: ruby assembler.rb Some.asm
# after which Some.hack will be generated

require_relative 'code'
require_relative 'parser'
require_relative 'symbol_table'

class AssemblerException < Exception; end

class Assembler

  def initialize(asm, hack)
    unless (File.readable?(asm.path) && File.writable?(hack.path))
      raise AssemblerException.new('Could not read/write files.')
    end
    @asm_file = asm
    @hack_file = hack
    @parser = Parser.new(@asm_file)
    @code = Code.new
    @symbol_table = SymbolTable.new
    @num_labels = 0
  end

  def assemble!
    begin
      constantize_labels while @parser.has_more_commands?
      @parser.rewind!
      assemble_command while @parser.has_more_commands?
    rescue Exception => e
      puts e.backtrace.join("\n")
      abort(e.message)
    end
  end

  def constantize_labels
    if @parser.command_type == Parser::L_COMMAND
      @symbol_table.add_entry(@parser.symbol, @parser.index - @num_labels)
      @num_labels += 1
    end
    @parser.advance
  end

  def assemble_command
    if @parser.command_type == Parser::C_COMMAND
      assemble_c_command
    elsif @parser.command_type == Parser::A_COMMAND
      assemble_a_command
    end
    @parser.advance
  end

  def assemble_a_command
    constant = @parser.symbol
    if constant[/\D/]
      constant = @symbol_table.address_of(constant)
    end
    @hack_file << "0#{@code.constant(constant)}\n"
  end

  def assemble_c_command
    begin
      comp = @code.comp(@parser.comp)
      dest = @code.dest(@parser.dest)
      jump = @code.jump(@parser.jump)
    rescue Exception => e
      puts e.backtrace.join("\n")
      abort(e.message)
    end
    @hack_file << "111#{comp}#{dest}#{jump}\n"
  end
  
end


puts "Hack Assembler"

def args_valid?
  return ARGV.size == 1 && File.exist?(ARGV[0]) && File.extname(ARGV[0]) == ".asm"
end

abort("Usage ruby assembler.rb Some.asm") unless args_valid?

begin
  asm_basename = File.basename(ARGV[0], '.asm')
  asm_path = File.split(ARGV[0])[0]
  hack_filename = "#{asm_path}/#{asm_basename}.mine.hack"

  File.open(ARGV[0], "r") do |asm_file|
    File.open(hack_filename, "w") do |hack_file|
      assembler = Assembler.new(asm_file, hack_file)
      assembler.assemble!
    end
  end
  puts "#{ARGV[0]} assembled successfully into #{hack_filename}"
rescue Exception => e
  abort(e.message)
end
