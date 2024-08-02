require 'csv'
require 'open3'
require 'json'

data_path = File.join(Dir.pwd, 'data')

# Initialize an empty array to store the CSV data
csv_data = ""

# Iterate over all files in the directory
Dir.foreach(File.join(data_path, 'mds')) do |filename|
  # Check if the file is a markdown file (ends with .md extension)
  next unless filename.end_with?(".md")
  id = filename.gsub('.md', '')

  name =
    JSON
    .parse(File.read(File.join(data_path, 'jsons', id + '.json')))
    .dig('data', 'attributes', 'name')

  # Add the content of the file as the first element of a new row
  STDOUT.puts(CSV.generate_line([filename, name, File.read(File.join(data_path, 'mds', id, filename))]))
end
