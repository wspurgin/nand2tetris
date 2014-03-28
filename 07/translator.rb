#!/usr/bin/env ruby
# Author
# 
# 

# Translator Exception class
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
  end

  def translate!
    File.open(@asm_filename, "w") do |asm_file|
      for file in @files
        File.open(file, "r") do |vm_file|
          lines = vm_file.readlines
          lines.each do |line|
            asm_file << line
          end
        end
      end
    end
    puts "#{@asm_filename} created successfully"
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
  abort(e.message)
end 