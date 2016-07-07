#!/usr/bin/ruby
# Description: Reads all files in path and creates new style.

FILE_ENDING = ".reformed"
MODE = :doxygenate

# Add a test for first digit alphanumeric to String class
class String
  def wordish?
    # Returns true if our first character is a-z, A-Z, 0-9 or _
    (/\w/ =~ self) == 0
  end
end

class FileChurner
  def initialize
    # @description = []
    @return_value = ''
    # @in_comment = false
    # @in_code_block = 0
    # @in_comment_block = 0
    @file_name = ''
    @in_start_of_file = true
    # @in_description = false
    @mode = :echo
  end
  def feed(line)
    # Process lines from file based on mode; trailing new line removed
    case @mode
    when :echo
      # Echo back each line
      @return_value += line + "\n"
    when :snake_to_camel
      # Look for underscores that are probably in variable names and removed
      # them while making the next letter capitalized.
      if line.strip.start_with? '#include'
        # Leave included file names alone
        @return_value += line + "\n"
        return
      end
      # Split the line and keep all spaces
      line_splits = line.split(/ /)
      # Modify any words as necessary
      line_splits.collect! { |word|
        if word.empty?
          # Leave empty word alone
          word
        elsif word.include?("__LINE__") \
          || word.include?("__FILE__") \
          || word.include?("static_cast") \
          || word.include?("dynamic_cast")
          # Leave these words alone
          word
        else
          # Remove each underscore and capitalize the next letter
          word_splits = word.split('_')
          first_syllable = true
          word_splits.collect! { |syllable|
            if first_syllable
              # Leave first syllable alone
              first_syllable = false
              syllable
            elsif syllable.length == 0
              # Leave empty syllable alone
              syllable
            elsif syllable[0].wordish? && syllable[0] == syllable[0].upcase
              # Keep underscore if syllable is already uppercase alphanumeric
              # (e.g. CONST_DEF and not (test_))
              "_" + syllable
            else
              # Capitalize the first letter and leave other letters alone
              syllable[0].upcase + syllable[1..-1]
            end
          }
          word_splits.join
        end
      }
      # Join the line back up
      @return_value += line_splits.join(' ') + "\n"
    when :doxygenate
      # No longer start of file if we get a non empty non comment line
      @in_start_of_file = false if !line.empty? && !line.start_with?("//")
      # Inject Javadoc style comment block after description
      @return_value += line + "\n"
      tag = "// Description: "
      if line.start_with? tag
        description = line[tag.length..-1]
        filename = @file_name.split("/").last
        if @in_start_of_file
          @return_value += "\n"
          @return_value += "/** @file #{filename}\n"
          @return_value += " * @brief #{description}\n"
          @return_value += " * @details fill_me_in\n"
          @return_value += " * @copyright Radiometrics Corporation 2014-2016\n"
          @return_value += " */\n"
        @return_value += "\n"
        else
          @return_value += "\n"
          @return_value += "/**\n"
          @return_value += " * @brief #{description}\n"
          @return_value += " */\n"
        end
      end
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
    "Please pass 'run', 'clean' or 'perm' as second argument\n"
  )
end

if ARGV[0].downcase == "depot"
  ARGV[0] = 'C:/depot/trunk/software/B-series/Second_Try'
elsif ARGV[0].downcase == "cci"
  ARGV[0] = 'C:/depot/trunk/software/B-series/Second_Try/CCI'
end

#ARGV.each_with_index do |a, i|
#  puts "Argument #{i}: #{a}"
#end

puts "Processing path #{ARGV[0]} with #{ARGV[1]}"
# Loop over all files in the directory
Dir.glob(ARGV[0] + '/**/*').each do |filename|
  # Check if directory
  next if filename == '.' || filename == '..'
  next if File.directory? filename
  next if filename.include? "Archive/"
  next if filename.include? "Debug/"
  next if filename.include? "Release/"
  next if filename.include? "qtserialport/"
  next if filename.include? "Qtc-ssh-sftp"
  # Clean if necessary
  if ARGV[1].downcase.include? "clean"
    if filename.end_with? FILE_ENDING
      puts 'clean: ' + filename
      # Delete the file
      File.delete filename
    end
  end
  # Check if CPP source file
  next unless filename.end_with?(".cpp") \
      || filename.end_with?(".h") \
      || filename.end_with?(".ui")
  next if (MODE == :doxygenate) && filename.end_with?(".ui")
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
