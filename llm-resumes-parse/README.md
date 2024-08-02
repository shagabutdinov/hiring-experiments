# Parsing resumes with LLM

This is an example of how the LLM could be used to extract information from resumes.

This is useful for:

- Quickly rejecting irrelevant candidates
- Drastically reducing the amount of information reviewed manually
- Finding out top 100 resumes you want potentially review manually

This is not good for:

- It doesn't make decision on which candidate is good for you

# Important note

This is a very rough research that is not ready to be productionalized. The
steps listed here as they were done originally. Some steps not work anymore or
be hard to reproduce. Some steps might potentially be optimized using APIs or
more efficient code.

# Scratchpad

## Downloading resumes

1. Go to the workable page that contains the list of the candidates you want ot get.
2. Scroll the list of candidates to make the browser to load the full list
3. Get all candidates from the workable job page by executing in the browser console:

```
[...document.querySelectorAll('[data-ui="candidate-name"]')].map((e) => e.closest('a')?.href?.match(/\d+$/)[0])
```

4. Copy the resulting object.
5. Put it to "./data/ids".
6. Steal workable cookie and save it to `./cookie`.
7. Run "./llm-resumes-parse/download-resumes.rb".

## Convert resumes to markdown

- Install [marker](https://github.com/VikParuchuri/marker)
- Run `./convert-pdfs-to-mds.rb`.

## Get the table of candidates

- Run `./convert-mds-to-csv.rb > ./data/resumes.csv`.
- Upload `./data/resumes.csv` to google sheets.

## Extract the information from the resumes

1. Get the OpenAI token from Alex Senov. Make sure that your token has a
   reasonable spending limit - there is a high chance of burning more money than
   was intended due to unpredicable nature of the google sheets scheduler.
2. Put your token to `./google-sheets-openai.js`
3. Open google sheets, use the menu "Extensions -> App Scripts" to open the
   scripts editor.
4. Put the contents of `./google-sheets-openai.js` there
5. Add your questions (prompts) in the first row of the sheet.
6. Use the formula `=ARRAYFORMULA(OPENAI($C3:$C50,D$1))` to invoke openai for resumes listed in column C and the prompt from cell "D1" - apply this formula to all prompts and resumes. It is important to use `ARRAYFORMULA` instead directly calling `OPENAI` function because this reduces optimizes the number of calls to google engine, significantly reducing the overall execution time for the formula.
7. You are on your own now. Good luck!

## Potential prompts

We've experimented with the following prompts:

- When the career of this candidate has started? Reply in a format "YYYY-MM", e.g. "2022-02", without narrative or additional text
- Does this candidate has real experience, besides interships and education? Reply with the latest position of the candidate, without adding additional words, example "Frontend Engineer". Reply with "no" if there is no real experience.
- Is most of the candidate’s experience relevant to building scalable web applications, use of modern web technologies (e.g., React, Node.js, AWS)? Reply with "yes" or “no”. Do not output additional narrative.
- What is the focus of this candidates resume? Do not output additional narrative.
- Does this candidate has experience working with React, Vue, Angular, Svelte, or similar? Reply with the name of the framework candidate has the most experience with, without adding anything else, for example: "Vue". Reply with "no" if the candidate doesn't have experience with frontend frameworks.
- Does this candidate has experience working with backend frameworks (nest.js, express, Fast API, Django, rails, or similar)? Reply with the name of the backend candidate has the most experience with, without adding anything else, for example: "Rails". Reply with "no". if the candidate doesn't have experience with backend frameworks.
- Does this candidate has production experience working with dynamic programming languages that do not compile to byte-code except javascript or typescript (like ruby or python)? Reply with the name of such language the candidate has the most experience with, without adding anything else, for example: "python". Reply with "no". if the candidate doesn't have experience with such languages.
- Does this candidate has experience working with statically compiled languages (cpp, java, rust, go, or similar)? Reply with the name of such language the backend candidate has the most experience with, without adding anything else, for example: "go". Reply with "no". if the candidate doesn't have experience with statically compiled languages.
- What was the last workplace of this candidate where they worked as a software engineer? Reply with the name of such company here, without additional text, for example "Best Software Company". Reply with "no" if there is no such experience.
- Has this candidate worked in a product-based company, that has a software product as their main business? Examples are Airbnb, Booking.com, Microsoft, and so on. Reply with the name of such company, without additional text, for example "Booking.com". Reply with "no" if there is no such experience.
- Has this candidate worked in a product-based company that is famous for their high entry barrier for candidates, or high quality of the products they build? Examples are Google, Amazon, Netflix, and so on. Reply with the name of such company without additional text or "no". Example reply: Yandex.ru.
- What is the top 3 biggest achievements of this candidate in terms of the impact or the complexity of the work? Reply with three short sentences, separated by semicolon ";". Be concise, do not water the response down, do not output the narrative. Examples: "Delivered a report generation feature", "Grew 2 junior engineers".
- What is the cumulative impact of the achievements mentioned in the resume in terms of number users, business value, or organization metrics? Reply with one short sentence, examples: “100k users using delivered features” or “50% cost reduction in processing requests”. Reply with “no” if the impact was not mentioned. Do not output narrative.
- Does the resume specify any side projects that have real-world application and practical usefulness that were not made within the educational course? Do not count projects that have been made solely for training purposes within the course. If yes, specify the list of names separated by commas. If the resume doesn’t specify such projects, output “no”. Do not output additional narrative.
- Does this candidate has experience leading other people, for example a team, a junior, a group of collegues? Reply with a one very short setence (a few words) of their leadership experience or "no".
- Does this resume mention teaching, guidance, onboarding, support, or help to other engineers (students, junior engineers, peer engineers, or similar)? Print the who did this candidate help and with what. If the resume doesn’t mention this information, print “no”. Do not print additional narrative.
- Did the candidate participate as a speaker in conferences? If yes, conference names separated by commas. Print “no” if the candidate didn’t participate as a speaker in conferences, or it’s unknown. Do not print additional narrative.
- "Does the candidate has a computer science, math, physics, or another exact sciences degree? Reply with the following information separated by semicolon:
  - short name of the school (e.g. “Moscow State University” or “Standford University”), name of the field (e.g. “Computer Science” or “Applied Mathematics”),
  - the grade in the format “X/Y” or ""no grade"" if grade is not available (e.g., “8.1/10”, “95/100”, “no grade”). Assume the capping value if it’s not available, e.g. “7.4/10”, if “/10” is not available in the resume.
  - and calculated grade percentage (e.g., “81%”, “95%”, “no grade”). Output the number with percent sign only, without additional text. Output “no grade” if the grade is not available.
  - Full example: ""Moscow State University;Computer Science;8.1/10;81%"". Reply ""no"" if there is no degree mentioned in the resume. Do not output narrative."
- Is the field of the education is one of computer science, exact science, or engineering? Reply with “yes” or “no”. Do not output narrative.
- Is the given school is particularly well known for producing top-tier computer scientists, software engineers, or exact science specialists? Reply with “yes” or “no”. Do not output the narrative.
- Does the resume specifies the additional non-university education, like courses or trainings? Print single the most prominient education - output only it's name, without additional text or dates of participation, example is "Software development courses for Java". Print "no" if the no additional education is available. Be consice, do not output the narrative.
- Did the candidate won any computer science, math, physics, or any other exact sciences competitions? Print the name of the competition without addiitonal text, joined with comma, for example: "State math competition, Univercity computer science competition, Federal physics competition". Print "no" if the candidate didn't win any relevant competitions.
- If this resume contains a link to the github profile, extract it and print as a reply to this message. If it doesn't contain the link to the profile, respond with "no github".

# Areas to improve

- The licensing of [marker](https://github.com/VikParuchuri/marker) forbids it's commercial use, so we potentially need to find another way to convert resumes to md, or find a way to make it legal.
- The costs could be optimized by sending a single request per resume that includes all questions, instead of asking the questions one-by-one. This should significantly reduce the cost of execution of the script because OpenAI charges us on the number of tokens in the input and output and the resume provided as an input each time the question is asked.
- We promised to review female candidate resumes first, but there is no prompt for that yet.
