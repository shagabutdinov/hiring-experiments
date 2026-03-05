Get all candidates from the workable job page by executing in the browser console:

```
[...document.querySelectorAll('[data-ui="candidate-name"]')].map((e) => e.closest('a')?.href)
```

Copy the resulting object;

```
[
  "https://XXXX.workable.com/backend/jobs/4087255/browser/applied/candidate/370715911",
  "https://XXXX.workable.com/backend/jobs/4087255/browser/applied/candidate/370684553",
  ...
]
```

Steal cookie:

```
export COOKIE="$(cat cookie)"
```
