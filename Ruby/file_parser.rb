# Copyright RDX
# Description: Reads all files in path and creates new style.

class FileChurner
  def initialize
    #@description = []
    @line = ''
  end
  def feed(line)
    @line = line
  end
  def retrieve
    @line
  end
end

def process_file(filename)
  output = open(filename + '~', 'w')
  churner = FileChurner.new
  File.open(filename, 'r') do |f|
    f.each_line do |line|
      churner.feed line
      output.write(churner.retrieve)
      puts line
    end
  end
  output.close
end

#ARGV.each_with_index do |a, i|
#  puts "Argument #{i}: #{a}"
#end

puts "Processing path #{ARGV[0]}"
Dir.foreach(ARGV[0]) do |filename|
  next if filename == '.' or filename == '..'
  next unless filename.end_with? ".cpp" or filename.end_with? ".h"
  next if File.directory? filename
  puts 'file: ' + filename
  process_file(filename)
end
