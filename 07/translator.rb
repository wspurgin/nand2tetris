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
  files = []
  if Dir.exist?(path) # get all '.vm' files in dir
    Dir.foreach(path) { |file|
      if File.extname(file) == '.vm'
        files << path + '/' + file
      end
    }
    if files.empty?
      raise TranslatorException.new("No files found with \'.vm\' extension in #{path}")
    end
  else
    files = [path]
  end
  return files
end

abort('Usage: ./translator.rb (Prog.vm || /dir/ProgamDir), the file or directory should exist') unless args_valid?

begin # messy block... definitely should refuctor to functions.
  vm_basename = nil
  vm_path = nil
  
  path = ARGV[ 0 ].dup
  # strip ending / if there is one
  path.sub!(/\/$/, '')

  if Dir.exist?(path)
    for p in path.match(/^.*\/(.*)$|(\w*)/).captures
        vm_basename = p unless not p
    end
    vm_path = path
  else
    vm_basename = File.basename(ARGV[0], '.vm')
    vm_path = ARGV[0][/^(.*)\//, 1]
  end

  asm_filename = "#{vm_path}/#{vm_basename}.asm"
  files = get_files(path)
  files.each {|file| puts "#{file} will be translated into #{asm_filename}"}

rescue Exception => e
  puts e.backtrace.join("\n")
  abort(e.message)
end 