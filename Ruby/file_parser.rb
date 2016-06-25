#!/usr/bin/ruby
# Description: Reads all files in path and creates new style.

FILE_ENDING = ".reformed"

class FileChurner
  def initialize
    @code = []
    @comments = []
    @line = ''
    @in_comment = false
    @in_code_block = 0
    @in_comment_block = 0
  end
  def feed(line)
    @line = line
  end
  def retrieve
    @line
  end
end

def process_file(filename)
  output = open(filename + FILE_ENDING, 'w')
  churner = FileChurner.new
  File.open(filename, 'r') do |f|
    f.each_line do |line|
      churner.feed line
      output.write(churner.retrieve)
    end
  end
  output.close
end

#ARGV.each_with_index do |a, i|
#  puts "Argument #{i}: #{a}"
#end

puts "Processing path #{ARGV[0]}"
Dir.foreach(ARGV[0]) do |filename|
  next if filename == '.' || filename == '..'
  next if File.directory? filename
  if ARGV.length > 1 && ARGV[1].downcase == "clean"
    if filename.end_with? FILE_ENDING
      # Delete the file
      File.delete filename
    end
    next
  end
  next unless filename.end_with?(".cpp") || filename.end_with?(".h")
  puts 'file: ' + filename
  process_file(filename)
end
