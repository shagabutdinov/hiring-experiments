#!/usr/bin/env ruby

data_path = File.join(Dir.pwd, 'data')
pdfs_path = File.join(data_path, 'pdfs')
mds_path = File.join(data_path, 'mds')

Dir.mkdir(mds_path) if !Dir.exist?(mds_path)

files = Dir.entries(pdfs_path).select { |file| file.end_with?('.pdf') }

files.each.with_index do |filename, index|
  id = filename.gsub('.pdf', '')
  raw_resume_path = File.join(data_path, 'mds', id, id + '.md')
  puts("processing: #{id} (#{index}/#{files.length})")

  if !File.exist?(raw_resume_path) || File.size(raw_resume_path).zero?
    pdf_path = File.join(data_path, 'pdfs', filename)
    puts("converting: #{pdf_path}")

    success = system(
      "marker_single",
      pdf_path,
      mds_path,
      "--batch_multiplier",
      "2",
      "--max_pages",
      "10",
      "--langs",
      "English",
    )

    if !success
      raise StandardError.new("Failed to convert pdf to md")
    end
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
