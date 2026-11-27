# India News App

Inshorts-style short news for India. Android only for now. Zero-budget stack.

| Part | Tech | Where it runs (free) |
|---|---|---|
| App (`app/`) | Flutter, Riverpod, go_router | Google Play ($25 one-time fee) |
| API (`backend/`) | FastAPI + PyMongo async, Docker | Render free plan |
| Ingestion | `python -m app.ingest.run` | GitHub Actions cron, every 15 min |
| Database | MongoDB | Atlas M0 (512 MB), 14-day retention |

## Run locally (Docker only, no Python needed)

```powershell
docker compose up -d --build mongo api        # API on http://localhost:8000/docs
docker compose run --rm test                  # unit tests
docker compose run --rm ingest                # fetch feeds into local Mongo
```

Try: `http://localhost:8000/v1/feed?category=sports&lang=en`

## API

```
GET /healthz
GET /v1/categories      GET /v1/meta
GET /v1/feed?category=&state=&lang=&cursor=&limit=
GET /v1/search?q=&lang=
GET /v1/articles/{id}
```

## Deploy (free)

1. **Atlas**: create a free M0 cluster, a DB user, allow `0.0.0.0/0`, copy the connection string.
2. **Render**: New > Blueprint > pick this repo (uses `render.yaml`), set `MONGO_URI`.
3. **GitHub**: add repo secret `MONGO_URI`; the `ingest-news` workflow then fills the DB every 15 min.

## Content notes

Only headline, short summary and link are stored; the app must show the source name and open the
original article. Review each publisher's RSS terms before launch (`backend/app/ingest/sources.yaml`).

## Run the app (`app/`)

Android only. Design: "Paper" handoff (theme in `app/lib/core/theme/news_theme.dart`, copy in
`app/lib/core/l10n/strings_data.dart`). State: `flutter_riverpod`; navigation: `go_router`.

```powershell
cd app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # emulator -> host API (default)
flutter test
```

Debug builds fall back to three bundled sample stories when the API is unreachable and nothing is
cached; release builds show the error state instead (`--dart-define=SAMPLE_FALLBACK=true` overrides).
