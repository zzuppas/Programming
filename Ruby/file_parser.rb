# Copyright RDX
# Description: Reads all files in path and creates new style.

def process_file(filename)
  output = open(filename + '~', 'w')
  File.open(filename, 'r') do |f|
    f.each_line do |line|
      output.write(line)
      puts line
    end
  end
  output.close
end


# puts 'file parser: Opens cpp/h files and reformats them'
#ARGV.each_with_index do |a, i|
#  puts "Argument #{i}: #{a}"
#end
# puts Dir[ARGV[1] + "*"]
#output = open('output.cpp
puts "Processing path #{ARGV[0]}"
Dir.foreach(ARGV[0]) do |filename|
  next if filename == '.' or filename == '..'
  next unless filename.end_with? ".cpp" or filename.end_with? ".h"  
  next if File.directory? filename
  puts 'file: ' + filename
  process_file(filename)
end





