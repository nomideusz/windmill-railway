# Deploy and Host Windmill Dev on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/windmill-dev?utm_medium=integration&utm_source=button&utm_campaign=windmill-dev)

[Windmill](https://www.windmill.dev/) is the open-source developer platform for internal code: write a script in Python, TypeScript, Bash, Go, SQL or a dozen other languages, and Windmill gives it a generated UI, a webhook, a schedule and a place in multi-step flows with retries, approvals and branching. Build internal apps on top with a drag-and-drop editor. This template runs Windmill Community Edition 1.822.0 with a server, a job worker, a native worker and Postgres, and creates your superadmin on first boot, so Windmill's default `admin@windmill.dev` / `changeme` login never exists on a public URL.

## About Hosting Windmill Dev

The stack is four services: Windmill, Worker, Native Worker and Postgres.

- **Windmill** serves the web app and the API on the public domain. It does not run jobs.
- **Worker** runs the jobs: Python, TypeScript (Deno and Bun), Bash, Go, PowerShell, PHP, Rust, C#, Java, Ruby, R, Ansible, DuckDB and dbt scripts, plus flows and dependency installs.
- **Native Worker** runs the lightweight native jobs in-process: native TypeScript (`fetch`), Postgres, MySQL, GraphQL, Snowflake, BigQuery and MS SQL queries. Upstream splits these into their own worker group; without one, those jobs would sit in the queue.
- **Postgres** holds everything: scripts, flows, apps, resources, secrets (encrypted per workspace), schedules, the job queue and job logs.
- **Superadmin ready, default login gone.** On the very first boot the server starts on localhost only, creates your account from `WINDMILL_ADMIN_EMAIL` and the generated `WINDMILL_ADMIN_PASSWORD`, deletes the default admin, checks that `changeme` no longer works, and only then starts serving. Railway routes no traffic to a deploy until its health check passes, so there is no window to claim the instance.
- **One pinned version.** All three Windmill services build the same wrapper of the official image, so the server and the workers can never drift apart. Upgrades run their own migrations on boot.
- **Scripts can call Windmill.** The workers reach the server over Railway's private network, so the `wmill` client works inside scripts (reading resources and variables, starting other jobs).

## Common Use Cases

- Turning team scripts into internal tools with auto-generated forms, replacing Retool or a pile of cron boxes
- Workflow orchestration and data pipelines with retries, approvals and error handlers, replacing Airflow, Prefect or Temporal for small teams
- Webhook endpoints, scheduled jobs and integrations written as code, as a developer-first alternative to n8n or Zapier

## Dependencies for Windmill Dev Hosting

- Postgres 17 (included, private network only)

### Deployment Dependencies

- [Windmill documentation](https://www.windmill.dev/docs/intro)
- [Windmill self-hosting guide](https://www.windmill.dev/docs/advanced/self_host)
- [Template source on GitHub](https://github.com/nomideusz/windmill-railway)

### Implementation Details

**Sign in** at the Windmill service's Railway domain with the email you entered at deploy time and the `WINDMILL_ADMIN_PASSWORD` value from the Windmill service's Variables tab. The first boot runs several hundred database migrations, so give it two or three minutes. Windmill then asks you to create your first workspace. Change the password afterwards under Account settings; the variable is only read on first boot.

**Teammates.** Add them under Instance settings → Users, or invite them from a workspace's settings. Railway only allows outbound SMTP on the Pro plan, so on other plans no email is sent: create the user with a password, or invite them and tell them the URL.

**Memory.** Around 400 MB at idle: about 230 MB for the server, 40 MB for each worker and 100 MB for Postgres. Jobs use what they need on top, so a Python job with heavy dependencies briefly needs a few hundred MB more on the Worker. Workers cache installed dependencies on local disk; the cache starts empty after each redeploy, so the first run of a script after a deploy reinstalls its packages.

**More throughput.** Raise the Worker service's replicas in Railway, or set `NUM_WORKERS` on it to run several jobs at once in one container. Worker groups and their tags are configured in Windmill under Workers.

**Not included.** The editor's language server (code completion for Python and Deno) runs as a separate `windmill-extra` service upstream; the editor works without it. Sandboxed `# sandbox <image>` jobs and the legacy Docker job mode need privileged containers or a Docker socket, which Railway does not provide. Enterprise features (SSO, audit logs, full-text log search) need a license and the EE image.

**Backups.** Everything lives in Postgres, so enable Railway's volume backups on the Postgres volume.

**Custom domain.** Add it in the Windmill service's Settings → Networking, then set `BASE_URL` to `https://your.domain`. You can also override it in Instance settings → Core.

## Why Deploy Windmill Dev on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Windmill Dev on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
