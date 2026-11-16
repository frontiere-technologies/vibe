# sources

Everything that is built, deployed or tested: application code, shared libraries, infrastructure and cross-service tests. Project knowledge does not live here — it is in [`docs/second-brain/`](../docs/second-brain/).

The structure below is a generic, standard layout. The project can change it if it needs to, but keeping it is recommended even when the application is a single web application (a single microservice): that service goes in `microservices/`, and the other folders are ready for when the project grows (shared code, deployment, end-to-end tests). If the structure changes, update *Layout* in [`AGENTS.md`](../AGENTS.md) and *Project structure* in the root [`README.md`](../README.md).

```
sources/
├── microservices/                  one folder per deployable service
├── libraries/                      shared code used by several services
├── devops/                         build, deploy and operate
└── tests/
    └── e2e/                        end-to-end tests against the running system
```

## microservices/

One subfolder per deployable service, named after the service (e.g. `microservices/web-<name>/`). Each service is self-contained: its own package manifest, `Dockerfile`, environment template (`.env.template`), and its unit and integration tests. A service can have its own `AGENTS.md` for rules that only apply to it.

## libraries/

Code reused by more than one service: shared packages, clients, types and utilities. Nothing here is deployed on its own; services depend on it. Code used by a single service stays inside that service.

## devops/

Everything needed to build, deploy and operate the services: database schema and migrations, deployment manifests (e.g. Kubernetes), environment setup scripts, and repository-wide checks (validators, contract tests). Organise it in subfolders by area as it grows.

## tests/

Tests that span more than one service or exercise the whole system. Unit and integration tests of a single service live inside that service.

- `e2e/` — end-to-end tests against the running application (e.g. browser tests), with an environment template such as `.env.test.example`.

## Conventions

- Secrets are never committed: commit only templates (`*.example`, `.env.template`) and keep real values in ignored files.
- Before designing or changing code here, check the project knowledge in `docs/second-brain/wiki/index.md` (see `AGENTS.md`).
