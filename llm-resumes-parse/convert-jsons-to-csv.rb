#!/usr/bin/env ruby

require 'json'
require 'csv'
require 'rest_client'

data_path = File.join(Dir.pwd, 'data')
questions = JSON.parse(File.read(File.join(data_path, 'questions.json')))
answers_path = File.join(data_path, 'answers')

linkedins_path = File.join(data_path, 'linkedins')
if !Dir.exist?(linkedins_path)
  Dir.mkdir(linkedins_path)
end

# puts("XXXX convert-jsons-to-csv.rb:8 #{File.join(data_path, 'answers')}")

data = CSV.generate do |csv|
  csv << [
    'id',
    'name',
    'email',
    'linkedin',
    # 'linkedin_exists',
    *questions.keys
  ]

  Dir.foreach(File.join(data_path, 'answers')) do |filename|
    if !filename.end_with?('.json')
      next
    end

    id = filename.gsub('.json', '')

    answers = JSON.parse(
      File
        .read(File.join(answers_path, id + ".json"))
        .gsub(/\A.*?\{/m, '{')
        .gsub(/\}.*?\z/m, '}')
    )

    info = JSON.parse(
      File.read(File.join(data_path, 'candidates', id + '.json')),
    )

    linkedin_url =
      info
      .dig('data', 'attributes', 'social_profiles')
      &.find { |profile| profile['network'] == 'linkedin' }
      &.dig('url')

    if linkedin_url.nil?
      linkedin_url = answers['urls_linkedin']
    end

    # linkedin_path = File.join(linkedins_path, id + '.json')
    # if !File.exist?(linkedin_path)
    #   begin
    #     puts("XXXX convert-jsons-to-csv.rb:51 #{linkedin_url}")
    #     linkedin_exists = RestClient.get(linkedin_url).code == 200
    #     File.write(linkedin_path, JSON.generate(linkedin_exists))
    #   rescue StandardError => error
    #     STDERR.puts("error: #{error.to_s}")
    #     STDERR.puts("error: #{error.response.body}")
    #   end
    # end

    # linkedin_exists = JSON.parse(File.read(linkedin_path))

    row = [
      id,
      info.dig('data', 'attributes', 'name'),
      info.dig('data', 'attributes', 'email'),
      linkedin_url,
      # linkedin_exists,
      *questions.keys.map { |key| answers[key] }
    ]

    csv << row
  end
end

puts(data)
