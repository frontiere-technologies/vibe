# How the Orders team ships a change

The Orders team owns the `orders-api` service. The team has three people: Giulia (tech lead), Paolo and Sara (developers).

Every change starts on its own branch, created from `main`. The developer writes the code and its unit tests on that branch, then opens a pull request on GitHub.

When the pull request is opened, the CI pipeline runs the unit tests and the linter. Giulia, or another developer, reviews the code.

Rules of the team:

- A pull request can be merged into `main` only if the CI pipeline is green and one reviewer has approved it.
- If the CI pipeline fails, the developer fixes the branch and pushes again; the pipeline runs again.
- After a merge, `orders-api` is deployed automatically to the staging environment.
- Production deploys happen on Tuesday and Thursday only, and only after the change has been checked on staging.
- On Friday there are no production deploys.

Paolo is on call this week: if a production deploy breaks something, he rolls it back to the previous version.
