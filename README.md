# Mike

Open-source release containing the Mike frontend and backend.

## Contents

- `frontend/` - Next.js application
- `backend/` - Express API, Supabase access, document processing, and migrations
- `backend/migrations/000_one_shot_schema.sql` - one-shot Supabase schema for fresh databases

## Setup

Install dependencies:

```bash
npm install --prefix backend
npm install --prefix frontend
```

Create local env files from the examples:

```bash
cp backend/.env.example backend/.env
cp frontend/.env.local.example frontend/.env.local
```

Run `backend/migrations/000_one_shot_schema.sql` in the Supabase SQL editor for a fresh database when not using the bundled Docker Compose setup.

Start the backend:

```bash
npm run dev --prefix backend
```

Start the frontend:

```bash
npm run dev --prefix frontend
```

Open `http://localhost:3000`.

## Docker Compose

This repository includes a root `docker-compose.yml` that runs:

- `frontend` (Next.js) on `http://localhost:3000`
- `backend` (Express API) on `http://localhost:3001`
- `supabase-kong` (Supabase API gateway) on `http://localhost:8000`
- `minio` (S3-compatible storage) on `http://localhost:9000` (`console` on `:9001`)

1. Copy the docker env template:

```bash
cp .env.docker.example .env.docker
```

1. Set at minimum these values in `.env.docker`:

- `SUPABASE_SECRET_KEY`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY`

1. Start the stack:

```bash
docker compose --env-file .env.docker -f docker-compose.yml up --build
```

### Supabase Self-Hosting Notes

Use the official Supabase self-hosting Docker stack documented here:

- <https://supabase.com/docs/guides/self-hosting/docker>

For local Docker usage with this project:

- This compose now includes core Supabase services (`db`, `auth`, `rest`, `kong`).
- On a fresh Docker volume, Postgres initializes `supabase/init.sql` first, then a dedicated `mike-db-init` service waits for Auth tables to exist and applies `backend/migrations/000_one_shot_schema.sql`.
- Postgres is aligned to Supabase's PG17 image (`supabase/postgres:17.6.1.084`).
- The custom bootstrap only supplies the minimal compatibility expected ahead of the Supabase Postgres built-in init scripts, including `supabase_admin` and the `postgres` search path used by GoTrue.
- MinIO and MinIO client are aligned to Supabase's S3-style Chainguard images.
- Email/password signup is enabled locally via GoTrue with auto-confirm turned on.
- GoTrue runs against `postgres`, with that role's `search_path` set to `auth,public` so auth tables resolve correctly under the `auth` schema.
- The compose uses fresh named volumes (`supabase-db17-data`, `minio-s3-data`) to avoid PG15->PG17 incompatibility and old MinIO volume permission conflicts.
- Existing Postgres volumes do not rerun `/docker-entrypoint-initdb.d/*`; if the auth schema is already in a bad state, reset the DB volume or repair it manually.
- If you need to keep old local data, migrate it before switching volume names.
- `NEXT_PUBLIC_SUPABASE_URL` should stay `http://localhost:8000` for browser traffic.
- `SUPABASE_URL` should stay `http://supabase-kong:8000` for container-to-container backend traffic.

### Optional: Join Supabase Docker Network

If you run Mike and the official Supabase stack as separate Docker Compose projects on the same machine, you can connect Mike containers to Supabase's Docker network and use the Supabase `kong` service directly.

1. Ensure your Supabase stack is running and note its Docker network name.
2. Set `SUPABASE_DOCKER_NETWORK` in `.env` (default expected by this repo is `supabase_default`).
3. Start Mike with the override file:

```bash
docker compose -f docker-compose.yml -f docker-compose.supabase-network.yml up --build
```

In this mode:

- backend uses `SUPABASE_URL=http://kong:8000` (container-to-container)
- frontend keeps `NEXT_PUBLIC_SUPABASE_URL=http://localhost:8000` (browser-to-host)

## Required Services

- Supabase Auth and Postgres
- S3-compatible object storage, such as Cloudflare R2
- At least one supported model provider key, depending on which models you enable
- LibreOffice for DOC/DOCX to PDF conversion

## Checks

```bash
npm run build --prefix backend
npm run build --prefix frontend
npm run lint --prefix frontend
```

## License

AGPL-3.0-only. See `LICENSE`.
