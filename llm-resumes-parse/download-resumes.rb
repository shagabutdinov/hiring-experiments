#!/usr/bin/env ruby

File.read('./data/ids').lines do |line|
  id = line.strip
  puts("downloading: #{id}")

  if !File.exist?("./data/#{id}.json")
    `./download-workable-candidate.rb #{id} > ./data/#{id}.json`
  end

  if !File.exist?("./data/#{id}.pdf")
    pdf_url = `cat ./data/#{id}.json | jq '.data.attributes.resume.pdf_url' -r`
    system("curl", "-s", "-o", "./data/#{id}.pdf", pdf_url)
  end
end
