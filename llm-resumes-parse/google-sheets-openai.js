function OPENAI(resumes, question, model = "gpt-4o-mini") {
  const scriptCache = CacheService.getScriptCache();
  const cache = CacheService.getUserCache();
  const results = [];

  const resumesArray = typeof resumes === "string" ? [resumes] : resumes;

  for (let resume of resumesArray) {
    if (resume instanceof Array) {
      if (resume.length != 1) {
        throw new Error(
          "resume is expected to be 1 element array or string, given: " +
            JSON.stringify(resume)
        );
      }
      resume = resume[0];
    }

    if (!resume || !question) {
      results.push("");
      continue;
    }

    const rawKey =
      resume + "." + question + (model === "gpt-4o-mini" ? "" : "." + model);

    const key =
      "openai." +
      Utilities.base64Encode(
        Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, rawKey)
      ); // Define a unique key for your data

    // Check if data exists in cache
    let result = cache.get(key) || scriptCache.get(key);

    // If data is not cached or expired, fetch and cache it
    if (!result) {
      const apiKey = "INSERT_YOUR_OPENAI_KEY_HERE";
      const url = "https://api.openai.com/v1/chat/completions";

      const payload = {
        model,
        messages: [
          {
            role: "system",
            content:
              "You are hiring assistant. You analyze resumes and reply questions on them.",
          },
          {
            role: "user",
            content: `
              I'll provide you a resume in the next message and the
              question on it in the follow up question. Wait for the
              resume and for the follow up question before replying.
              Reply ok to this message and the message with resume.
            `,
          },
          {
            role: "assistant",
            content: "ok",
          },
          {
            role: "user",
            content: resume,
          },
          {
            role: "assistant",
            content: "ok",
          },
          {
            role: "user",
            content: question,
          },
        ],
      };

      const options = {
        method: "post",
        contentType: "application/json",
        headers: {
          Authorization: "Bearer " + apiKey,
        },
        payload: JSON.stringify(payload),
      };

      const response = UrlFetchApp.fetch(url, options);
      const json = JSON.parse(response.getContentText());
      result = json.choices[0].message.content.trim();
    }

    cache.put(key, result, 24 * 365 * 3600);
    results.push(result);
  }

  if (typeof resumes === "string") {
    return results[0];
  }

  return results;
}
