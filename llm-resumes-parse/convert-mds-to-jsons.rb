#!/usr/bin/env ruby

require 'rest-client'
require 'json'

PROMPT = <<~TEXT
You are the hiring assistant that prepares resumes to be read by the hiring
manager.
TEXT

TASK = <<~TEXT
I'll provide a resume and a set of questions in the json format in
the next two messages. Use the provided resume to answer provided questions.
Here are the guidelines for preparing the answers:

- Be extremely consise, make the answers as short as possible
- Do not include narrative in the answers
- Reply with the json that has structure:
  {"question title 1": "answer 1", "question title 2": "answer 2"}
- Reply in plain json only, without formatting or narrative
- Titles of the questions are specified in keys of the json in the following
  format: {"question title 1": "question 1", "question title 2": "question 2"}
TEXT

API_KEY = ENV['OPENAI_API_KEY']

data_path = File.join(Dir.pwd, 'data')
questions = File.read(File.join(data_path, 'questions.json'))

answers_path = File.join(data_path, 'answers')
Dir.mkdir(answers_path) if !Dir.exist?(answers_path)

mds_path = File.join(data_path, 'mds')
files = Dir.entries(mds_path).select { |file| file.end_with?('.md') }

files.each.with_index do |filename, index|
  id = filename.gsub('.md', '')
  puts("processing: #{id} (#{index}/#{files.length})")
  answer_path = File.join(answers_path, id + ".json")
  if File.exist?(answer_path)
    next
  end

  md_path = File.join(mds_path, filename)
  resume = File.read(md_path)

  puts("convertign: #{md_path}")

  begin
    response = RestClient.post(
      'https://api.openai.com/v1/chat/completions',
      {
        model: "gpt-4o",
        messages: [
          { role: "system", content: PROMPT },
          { role: "user", content: TASK },
          { role: "assistant", content: "ok" },
          { role: "user", content: resume },
          { role: "assistant", content: "ok" },
          { role: "user", content: questions }
        ],
        max_tokens: 4096,
      }.to_json,
      {
        content_type: :json,
        accept: :json,
        Authorization: "Bearer #{API_KEY}"
      },
    )

    answers =
      JSON
      .parse(response)
      .fetch('choices')
      .fetch(0)
      .fetch('message')
      .fetch('content')
      .sub(/^`+\w*/, '')
      .sub(/`+$/, '')
      .strip

    File.write(answer_path, answers)
  rescue StandardError => error
    if error.respond_to?(:response)
      STDERR.puts("openai api call failure: #{error.message} #{error.response.body}")
    end

    raise
  end
end
