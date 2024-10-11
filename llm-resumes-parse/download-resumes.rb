#!/usr/bin/env ruby

require 'json'

data_path = File.join(Dir.pwd, 'data')
pdfs_path = File.join(data_path, 'pdfs')
candidates_path = File.join(data_path, 'candidates')

Dir.mkdir(candidates_path) if !Dir.exist?(candidates_path)
Dir.mkdir(pdfs_path) if !Dir.exist?(pdfs_path)

ids = JSON.parse(File.read('./data/ids'))
ids.each.with_index do |id, index|
  puts("processing: #{id} (#{index}/#{ids.length})")

  candidate_path = File.join(candidates_path, "#{id}.json")
  if !File.exist?(candidate_path)
      puts("downloading json: #{File.basename(candidate_path)}")
    `./download-workable-candidate.rb #{id} > #{candidate_path}`
  end

  pdf_path = File.join(pdfs_path, "#{id}.pdf")
  if !File.exist?(pdf_path)
    pdf_url = `cat #{candidate_path} | jq '.data.attributes.resume.pdf_url' -r`.strip
    puts("downloading pdf: #{File.basename(pdf_path)}")
    system("curl", "-s", "-o", pdf_path, pdf_url)
  end
end
