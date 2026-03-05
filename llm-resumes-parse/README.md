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

```javascript
// scroll document
document.querySelector('[data-ui="results-container"]').scrollTop =
  document.querySelector('[data-ui="results-container"]').scrollHeight;

[...document.querySelectorAll('[data-ui="candidate-name"]')].map(
  (e) => e.closest("a")?.href?.match(/\d+$/)[0],
);
```

4. Copy the resulting object.
5. Put it to `./data/ids`.
6. Steal workable cookie and save it to `./data/cookie`.
7. Set cookie as a global variable: `export COOKIE="$(cat ./data/cookie)"`.
8. Run `./download-resumes.rb`.

## Convert resumes to markdown

- Install [marker](https://github.com/VikParuchuri/marker)
- Run `./convert-pdfs-to-mds.rb`.

## Extract the information from the resumes

- Put your questions into `./data/questions.json`
- Run `./convert-mds-to-jsons.rb`
- Run `./convert-jsons-to-csv.rb`

## Working with candidates in workable

Use the following script to quickly select candidates using their ids in workable (note that you should scroll the list of the candidates manually to the bottom to load all candidates):

```javascript
// scroll document
document.querySelector('[data-ui="results-container"]').scrollTop =
  document.querySelector('[data-ui="results-container"]').scrollHeight;

// select ids
(async () => {
  const ids = [
    // list of ids
  ];

  for (const id of ids) {
    console.log(id);

    document
      ?.querySelector(
        `[data-ui="candidate-card"] a[href="/backend/jobs/XXXXXX/browser/applied/candidate/${id}"]`,
      )
      ?.closest('[data-ui="candidate-card"]')
      ?.querySelector('input[type="checkbox"]')
      ?.click();

    await new Promise((resolve) => setTimeout(resolve, 1));
  }
})();
```

## Potential prompts

We've experimented with the following prompts:

```
{
  "experience_country": "Where the candidates is located? Print the name of the country, for example 'Brazil'. Print 'no' if there is no location information.",
  "experience_start": "When the career of this candidate has started? Reply in a format 'YYYY-MM', e.g. '2022-02', without narrative or additional text",
  "experience_focus": "What the career of the candidate is focused on, what is the main area of the expertise? Reply with a couple of words, examples: 'Product manager', 'Product owner', 'Frontend Engineer'.",
  "experience_production": "What real experience candidate have, that doesn't include interships and education? Reply with the latest position of the candidate, examples: 'Product Manager'. Reply with 'no' if there is no real experience.",
  "experience_frontend": "Does this candidate has experience working with React, Vue, Angular, Svelte, or similar? Reply with the name of the framework candidate has the most experience with, for example: 'Vue'. Reply with 'no' if the candidate doesn't have experience with frontend frameworks.",
  "experience_backend": "Does this candidate has experience working with backend frameworks (nest.js, express, Fast API, Django, rails, or similar)? Reply with the name of the backend candidate has the most experience with, for example: 'Rails'. Reply with 'no'. if the candidate doesn't have experience with backend frameworks.",
  "experience_dynamic_language": "Does this candidate has production experience working with dynamic programming languages that do not compile to byte-code except javascript or typescript (like ruby or python)? Reply with the name of such language the candidate has the most experience with, without adding anything else, for example: 'python'. Reply with 'no'. if the candidate doesn't have experience with such languages.",
  "experience_static_language": "Does this candidate has experience working with statically compiled languages (cpp, java, rust, go, or similar)? Reply with the name of such language the backend candidate has the most experience with, without adding anything else, for example: 'go'. Reply with 'no'. if the candidate doesn't have experience with statically compiled languages.",
  "workplace_last": "What was the last workplace of this candidate where they worked as a product manager? Reply with the name of such company here, without additional text, for example 'Best Software Company'. Reply with 'no' if there is no such experience.",
  "workplace_product": "Has this candidate worked in a product-based company, that has a software product as their main business? Examples are Airbnb, Booking.com, Microsoft, and so on. Reply with the name of such company, without additional text, for example 'Booking.com'. Reply with 'no' if there is no such experience.",
  "workplace_hard": "Has this candidate worked in a product-based company that is famous for their high entry barrier for candidates, or high quality of the products they build? Examples are Google, Amazon, Netflix, and so on. Reply with the name of such company without additional text or 'no'. Example reply: Yandex.ru.",
  "delivery_achievements": "What is the top 3 biggest achievements of this candidate in terms of the impact or the complexity of the work? Reply with three short sentences, separated by semicolon ';'. Examples: 'Delivered a report generation feature', 'Grew 2 junior product managers'.",
  "delivery_sideprojects": "Does the resume specify any side projects that have real-world application and practical usefulness that were not made within the educational course? Do not count projects that have been made solely for training purposes within the course, or that do not have a URL. If yes, specify the list of projects URLs separated by commas. If the resume doesn’t specify such projects, reply with 'no'.",
  "leadership_managing": "Does this candidate has experience leading other people, for example a team, a junior, a group of collegues? Reply with a one very short setence (a few words) of their leadership experience or 'no'.",
  "leadership_support": "Does this resume mention teaching, guidance, onboarding, support, or help to other product manager (students, junior product manager, peer engineers, or similar)? Print the who did this candidate help and with what. If the resume doesn’t mention this information, print 'no'.",
  "leadership_conferences": "Did the candidate participate as a speaker in conferences? If yes, conference names separated by commas. Print “no” if the candidate didn’t participate as a speaker in conferences, or it’s unknown.",
  "education_degree": "Does the candidate has a computer science, math, physics, or another exact sciences degree? Reply with the name of the school and the name of the field, for example 'Moscow State University, Computer Science'. Reply with 'no' if there is no such education.",
  "education_known": "Is the school from the question 'education_degree' is particularly well known for producing top-tier computer scientists, software engineers, or exact science specialists? Reply with “yes” or “no”.",
  "education_courses": "Does the resume specifies the additional non-university education relevant to computer science, like courses or trainings? Print single the most prominient education - output only it's name, without additional text or dates of participation, example is 'Software development courses for Java'. Print 'no' if the no additional education is available.",
  "education_competitions": "Did the candidate participated in any computer science, math, physics, or any other exact sciences competitions? Print the name of the competition, joined with comma, for example: 'State math competition, Univercity computer science competition, Federal physics competition'. Print 'no' if the candidate didn't win any relevant competitions.",
  "urls_github": "Link to the github profile. Reply with 'no' if there is no such link in the resume.",
  "urls_linkedin": "Link to the linkedin profile. Reply with 'no' if there is no such link in the resume."
}
```

# Areas to improve

- The licensing of [marker](https://github.com/VikParuchuri/marker) forbids it's commercial use, so we potentially need to find another way to convert resumes to md, or find a way to make it legal.
- The costs could be optimized by sending a single request per resume that includes all questions, instead of asking the questions one-by-one. This should significantly reduce the cost of execution of the script because OpenAI charges us on the number of tokens in the input and output and the resume provided as an input each time the question is asked.
- Use the workable API to get the list of candidates instead of manual scraping.
- We promised to review female candidate resumes first, but there is no prompt for that yet.
