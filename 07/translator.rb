#!/usr/bin/env ruby

class TranslatorException < Exception; end

class Translator
  def initialize()
  end
end

puts "Translator"

# Expects only one argument, either single .vm filename, or a Dir
def args_valid?
  return ARGV.size == 1 && ((File.extname(ARGV[0]) == '.vm' && File.exist?(ARGV[0])) || Dir.exist?(ARGV[0]))
end

def get_files(path)
  if Dir.exist?(path) # get all '.vm' files in dir
  end
end

abort('Usage: ./translator.rb (Prog.vm || /dir/ProgamDir), the file or directory should exist') unless args_valid?

path = ARGV[0]
