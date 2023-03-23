require 'csv'
require 'webdrivers'

csv_file_path = Dir["csv_input/*"][0]

file_name = File.basename(csv_file_path)

puts csv_file_path

puts file_name

# matriculas = []
# CSV.foreach(csv_file_path, headers: true, col_sep: ';') do |row|
#   matriculas << row[0]
# end

# matriculas.length.times do |i|
#   puts matriculas[i].class
# end
