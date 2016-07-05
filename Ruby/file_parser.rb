#!/usr/bin/ruby
# Description: Reads all files in path and creates new style.

FILE_ENDING = ".reformed"
MODE = :echo

class FileChurner
  def initialize
    #@code = []
    #@comments = []
    @return_value = ''
    @in_comment = false
    @in_code_block = 0
    @in_comment_block = 0
    @file_name = ''
    @mode = :echo
  end
  def feed(line)
    if @mode == :echo
      @return_value += line + "\n"
    end
  end
  def retrieve
    return_value = @return_value
    @return_value = ''
    return return_value
  end
  def setFileName(name)
    @file_name = name
  end
  def setMode(mode)
    @mode = mode
  end
end

def process_file(filename)
  output = open(filename + FILE_ENDING, 'w')
  churner = FileChurner.new
  churner.setFileName filename
  churner.setMode MODE
  File.open(filename, 'r') do |f|
    f.each_line do |line|
      churner.feed line.chop
      output.write(churner.retrieve)
    end
  end
  output.close
end

if ARGV.length != 2
  abort( "Error: Invalid syntax!\n" \
    "Please pass directory path or . as first argument\n" \
    "Please pass 'run', 'clean' or 'permanent' as second argument\n"
  )
end

if ARGV[0].downcase == "depot"
  ARGV[0] = 'C:\depot\trunk\software\B-series\Second_Try'
end

#ARGV.each_with_index do |a, i|
#  puts "Argument #{i}: #{a}"
#end

puts "Processing path #{ARGV[0]} with #{ARGV[1]}"
# Loop over all files in the directory
Dir.foreach(ARGV[0]) do |filename|
  # Check if directory
  next if filename == '.' || filename == '..'
  next if File.directory? filename
  # Clean if necessary
  if ARGV[1].downcase.include? "clean"
    if filename.end_with? FILE_ENDING
      puts 'clean: ' + filename
      # Delete the file
      File.delete filename
    end
  end
  # Check if CPP source file
  next unless filename.end_with?(".cpp") || filename.end_with?(".h")
  # Run if necessary
  if ARGV[1].downcase.include? "run"
    puts 'run: ' + filename
    process_file(filename)
  end
  # Make changes permanent if necessary
  if ARGV[1].downcase.include? "perm"
    if File.file? filename + FILE_ENDING
      puts 'permanent: ' + filename
      # Delete the original file
      File.delete filename
      # Rename the new file
      File.rename(filename + FILE_ENDING, filename)
    end
  end
end

puts "Finished"
