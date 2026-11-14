# Layout presets

The template ships no code folders. Step 1 of the [setup guide](README.md) asks which preset fits the project, and the setup creates only the folders of that preset. The project can change them later.

| Preset | Fits | Code folders |
|--------|------|--------------|
| `services` | a system of several deployable services | `src/microservices/`, `src/libraries/`, `src/devops/`, `src/tests/e2e/` |
| `single-app` | one application or monolith | `app/`, `test/` |
| `library` | a published library | `lib/`, `test/`, `example/` |
| `data` | data or machine-learning work | `notebooks/`, `data/`, `pipelines/` |

The code root of the `services` preset is `src/`, not `sources/`: the name `sources/` would clash with the wiki folder `docs/second-brain/wiki/sources/`, which holds summaries of source documents.

Each preset below lists its folders and the lines to put in the *Layout* section of [`AGENTS.md`](../AGENTS.md). The two lines about `docs/` already there stay. Each preset also gives the lines for *Project structure* in the root [`README.md`](../README.md), which replace its example `src/` line. Empty folders get a `.gitkeep` file so Git tracks them.

## services

Everything that is built, deployed or tested across several services. The setup copies the description below to `src/README.md`.

### Folders

```
src/
├── microservices/                  one folder per deployable service
├── libraries/                      shared code used by several services
├── devops/                         build, deploy and operate
└── tests/
    └── e2e/                        end-to-end tests against the running system
```

- `microservices/` — one subfolder per deployable service, named after the service (e.g. `microservices/web-<name>/`). Each service is self-contained: its own package manifest, `Dockerfile`, environment template (`.env.template`), and its unit and integration tests. A service can have its own `AGENTS.md` for rules that only apply to it.
- `libraries/` — code reused by more than one service: shared packages, clients, types and utilities. Nothing here is deployed on its own; services depend on it. Code used by a single service stays inside that service.
- `devops/` — everything needed to build, deploy and operate the services: database schema and migrations, deployment manifests (e.g. Kubernetes), environment setup scripts, and repository-wide checks (validators, contract tests). Organise it in subfolders by area as it grows.
- `tests/` — tests that span more than one service or exercise the whole system. Unit and integration tests of a single service live inside that service.
  - `e2e/` — end-to-end tests against the running application (e.g. browser tests), with an environment template such as `.env.test.example`.

Conventions for `src/README.md`:

- Secrets are never committed: commit only templates (`*.example`, `.env.template`) and keep real values in ignored files.
- Before designing or changing code here, check the project knowledge in `docs/second-brain/wiki/index.md` (see `AGENTS.md`).

### AGENTS.md Layout lines

```markdown
- `src/` — code and operations, described in `src/README.md`: `microservices/` (one folder per deployable service), `libraries/` (shared code), `devops/` (build, deploy, operate), `tests/e2e/` (end-to-end tests).
```

### README.md Project structure lines

```markdown
- `src/` — code and operations, described in `src/README.md`
```

## single-app

One application or monolith, with its tests next to it.

### Folders

```
app/                                the application
test/                               unit, integration and end-to-end tests
```

- `app/` — all application code, its package manifest, its `Dockerfile` if any, and an environment template (`.env.template`).
- `test/` — all tests of the application. Mirror the structure of `app/`; keep end-to-end tests in a subfolder `test/e2e/`.

### AGENTS.md Layout lines

```markdown
- `app/` — the application code, its package manifest and environment template.
- `test/` — all tests, mirroring `app/`; end-to-end tests in `test/e2e/`.
```

### README.md Project structure lines

```markdown
- `app/` — the application code
- `test/` — its tests
```

## library

A library published for others to use.

### Folders

```
lib/                                the library's public code
test/                               tests of the library
example/                            small programs that use the library
```

- `lib/` — the library's code. Its public interface is what the examples and the tests use; keep it small and documented.
- `test/` — unit and integration tests. Every public function has a test.
- `example/` — runnable examples that show how to use the library. They depend only on the public interface.

### AGENTS.md Layout lines

```markdown
- `lib/` — the library's code; its public interface is documented.
- `test/` — unit and integration tests of the library.
- `example/` — runnable examples that use only the public interface.
```

### README.md Project structure lines

```markdown
- `lib/` — the library's code
- `test/` — its tests
- `example/` — runnable examples
```

## data

Data analysis, machine learning or data engineering.

### Folders

```
notebooks/                          exploration and reports
data/                               datasets
pipelines/                          code that produces and transforms data
```

- `notebooks/` — notebooks for exploration and reporting. Anything a notebook proves and the project depends on moves into `pipelines/`, where it is tested.
- `data/` — datasets, split into `raw/` (never edited) and `processed/` (produced by the pipelines). Large or private data stays out of Git: commit only a description of how to get it.
- `pipelines/` — code that downloads, cleans and transforms data, and trains or evaluates models, with its tests. Each pipeline can be re-run from the raw data.

### AGENTS.md Layout lines

```markdown
- `notebooks/` — exploration and reports; proven logic moves into `pipelines/`.
- `data/` — datasets: `raw/` is never edited, `processed/` comes from the pipelines; large or private data is not committed.
- `pipelines/` — tested code that produces and transforms data and models.
```

### README.md Project structure lines

```markdown
- `notebooks/` — exploration and reports
- `data/` — datasets
- `pipelines/` — code that produces and transforms data
```
