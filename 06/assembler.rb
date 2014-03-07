#!/usr/bin/env ruby

# Will Spurgin
# A Hack assembler that is written in Ruby!
# usage: ruby assembler.rb Some.asm
# after which Some.hack will be generated


puts "Hack Assembler"

def args_valid?
  return ARGV.size == 1 && File.exist?(ARGV[0]) && File.extname(ARGV[0]) == ".asm"
end

abort("Usage ruby assembler.rb Some.asm") unless args_valid?

begin
  asm_basename = File.basename(ARGV[0], '.asm')
  asm_path = File.split(ARGV[0])[0]
  hack_filename = "#{asm_path}/#{asm_basename}.hack"

  File.open(ARGV[0], "r") do |asm_file|
    File.open(hack_filename, "w") do |hack_file|
      assembler = Assembler.new(asm_file, hack_file)
      assembler.assemble!
    end
  end
rescue Excetion => e
  abort(e.message)
end

class Assembler

  def initialize(asm, hack)
    @asm_file = asm
    @hack_file = hack
  end
  
end
