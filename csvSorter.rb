def trim_string(string)
  # trim whitespace from strings if any exists
  string.strip == nil ? string : string.strip
end

# print help if no arguments are given or help is requested
if ARGV.length < 1 || ARGV[0] == "--help"
  puts "Usage: ruby %s [CSVFileName]\n\tColumn headers should be First Name,Last Name,Zip Code" % $0
  exit 1
end

# read from the passed file and catch possible IO error
begin
  lines = IO.readlines(ARGV[0])
rescue
  STDERR.puts "Sorry, that file does not exist"
  exit 1
end
lines.delete_if { |line| line =~ /^\s*$/ } # delete blank lines

all_line_tokens = []
column = {First: 0, Last: 0, ZIP: 0} # index of our three key columns (all other columns are ignored)
longest = {First: 5, Last: 4, ZIP: 3} # longest string length per column for use in printing

# tokenize all strings to a 2D array
lines.each { |line|
  this_line_tokens = line.split(",").map { |token| trim_string(token) }

  if column[:ZIP] == nil || column[:First] == nil || column[:Last] == nil
    STDERR.puts "Invalid CSV:\n\tHeaders should be \"First Name\", \"Last Name\", and \"Zip Code\" in any order"
    exit 1
  elsif column[:Last] == column[:First]
    # header line

    # find the column with a header containing "last", "first", and "zip" respectively - non-case sensitive
    column[:Last] = this_line_tokens.find_index { |token| token.match(/last/i) }
    column[:First] = this_line_tokens.find_index { |token| token.match(/first/i) } # find the column with a header containing "first", non-case sensative
    column[:ZIP] = this_line_tokens.find_index { |token| token.match(/zip/i) } # find the column with a header containing "zip", non-case sensative
  else
    # everything else
    all_line_tokens.push(this_line_tokens)

    # adjust the length of the longest string in a given column for the sake of printing
    longest[:Last] = [longest[:Last], this_line_tokens[column[:Last]].length].max
    longest[:First] = [longest[:First], this_line_tokens[column[:First]].length].max
    longest[:ZIP] = [longest[:ZIP], this_line_tokens[column[:ZIP]].length].max
  end
}

#sort 
modified = all_line_tokens.size > 1 # is already sorted?
sort_end_index = 0 # optimize for the back of the array being increasingly sorted
while modified do
  modified = false
  (0..all_line_tokens.size - 2 - sort_end_index).each { |i|
    if (all_line_tokens[i][column[:Last]] > all_line_tokens[i + 1][column[:Last]]) || (all_line_tokens[i][column[:Last]] == all_line_tokens[i + 1][column[:Last]] && all_line_tokens[i][column[:First]] > all_line_tokens[i + 1][column[:First]]) # sort by first name then by first name
      all_line_tokens[i], all_line_tokens[i + 1] = all_line_tokens[i + 1], all_line_tokens[i]
      modified = true
    end
  }
  sort_end_index += 1
end

# print into a formatted table
formatting_length = 10 # number of characters printed around the data (ie spaces and '|')
table_seperator = "*" + "-" * (longest[:First] + longest[:Last] + longest[:ZIP] + formatting_length - 2) + "*"
format_string = "| %-" + longest[:First].to_s + "s | %-" + longest[:Last].to_s + "s | %-" + longest[:ZIP].to_s + "s |"
puts table_seperator + "\n" + format_string % %w(First Last ZIP) + "\n" + table_seperator

all_line_tokens.each { |lineToken|
  puts format_string % [trim_string(lineToken[column[:First]]), trim_string(lineToken[column[:Last]]), trim_string(lineToken[column[:ZIP]])]
}
