data_path = File.join(Dir.pwd, 'data')

# Define the directory path containing the markdown files
Dir.foreach(File.join(data_path, 'pdfs')) do |filename|
  if !filename.end_with?('.pdf')
    next
  end

  id = filename.gsub('.pdf', '')

  raw_resume_path = File.join(data_path, 'mds', id, id + '.md')
  if !File.exist?(raw_resume_path) || File.size(raw_resume_path).zero?
    system([
      "marker_single",
      File.join(data_path, 'pdfs', filename),
      File.join(data_path, 'mds'),
      "--batch_multiplier",
      "2",
      "--max_pages",
      "10",
      "--langs",
      "English",
    ])
  end

  resume_path = File.join(data_path, 'mds', id + '.md')
  if !File.exist?(resume_path)
    File.write(resume_path, File.read(raw_resume_path))
  end

  # if !File.exist?(resume_path) || File.size(resume_path).zero?
  #   output, status = Open3.capture2(
  #     "ollama",
  #     "run",
  #     "llama3",
  #     "Remove name and surname of the person, phones, emails, and addresses " +
  #     "from the provided text. Reply with ONLY updated text, without adding " +
  #     "'here is your text' or similar. \n\n#{File.read(raw_resume_path)}",
  #     err: STDERR,
  #   )

  #   if !status.success?
  #     raise StandardError.new("Failed to remove personal data from the resume")
  #   end
  # end

  # File.write(resume_path, output)
end
