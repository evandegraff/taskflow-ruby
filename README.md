# TaskFlow

A small full-stack task manager built to practice Ruby on the backend and
vanilla JavaScript on the frontend.

- **Backend:** Plain Ruby with no framework — `WEBrick` for the HTTP
  server and the standard library's `JSON` for serialization. No Rails or
  Sinatra; routing, filtering, pagination, and logging are written by hand.
- **Frontend:** HTML/CSS/JavaScript with no build step or framework —
  `fetch()` and the DOM API talking directly to the REST endpoints below.
- **Tests:** 35 `Minitest` tests covering the model, the in-memory store,
  query filtering/sorting, pagination, and the request logger.

I built this to get more hands-on with Ruby while applying for backend
roles — I'm still learning Rails, so this intentionally sticks to plain
Ruby to show how the language itself works without a framework doing the
heavy lifting.

## Running it

Requires Ruby 3.0+. WEBrick was removed from Ruby's default gems in 3.0,
so install it first (it's the only runtime dependency):

```bash
git clone https://github.com/evandegraff/taskflow-ruby.git
cd taskflow-ruby
gem install webrick      # or: bundle install
ruby server/app.rb
```

Then open **http://localhost:4567** in a browser.

## Running the tests

```bash
rake test
# or run a single file:
ruby -Itest test/task_query_test.rb
```

## API

| Method | Path             | Description         |
|--------|------------------|----------------------|
| GET    | `/api/tasks`     | List tasks (filter, sort, paginate) |
| POST   | `/api/tasks`     | Create a task        |
| GET    | `/api/tasks/:id` | Fetch a single task  |
| PUT    | `/api/tasks/:id` | Update a task        |
| DELETE | `/api/tasks/:id` | Delete a task        |

### Query parameters for `GET /api/tasks`

All optional, and they can be combined.

| Param       | Values                                  | Example                  |
|-------------|-----------------------------------------|--------------------------|
| `completed` | `true` / `false`                        | `?completed=false`       |
| `priority`  | `low` / `medium` / `high`               | `?priority=high`         |
| `q`         | text (matches title or description)     | `?q=tests`               |
| `sort`      | `id`, `title`, `priority`, `created_at` | `?sort=priority`         |
| `order`     | `asc` (default) / `desc`                | `?sort=title&order=desc` |
| `page`      | positive integer                        | `?page=2`                |
| `per_page`  | 1–100 (default 20)                      | `?page=1&per_page=10`    |

Pagination is opt-in. When `page` or `per_page` is set, page info comes
back in response headers (`X-Total-Count`, `X-Page`, `X-Per-Page`,
`X-Total-Pages`) so the body stays a plain JSON array.

Invalid values return `422 Unprocessable Entity` with an error message,
e.g. `{"error": "sort must be one of id, title, priority, created_at"}`.

### Examples

```bash
curl -X POST http://localhost:4567/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Write more Ruby", "description": "Practice makes progress", "priority": "high"}'

# Open high-priority tasks, newest first
curl "http://localhost:4567/api/tasks?completed=false&priority=high&sort=created_at&order=desc"
```

### Request logging

Every API request is logged to stdout with method, path, status, and
timing:

```
2026-10-06T14:03:22Z GET /api/tasks?sort=title 200 1.4ms
```

## Project structure

```
server/
  app.rb              # HTTP server + routing
  task.rb             # Task model (title, description, priority, completed)
  task_store.rb       # In-memory, thread-safe data store
  task_query.rb       # Filtering + sorting rules for GET /api/tasks
  paginator.rb        # Opt-in pagination
  request_logger.rb   # Logs each request with status and timing
public/
  index.html
  styles.css
  app.js          # Frontend logic (fetch-based CRUD)
test/
  task_test.rb
  task_store_test.rb
  task_query_test.rb
  paginator_test.rb
  request_logger_test.rb
```

## What I'd do next

- Swap `TaskStore` for a real database (the class is already isolated so
  this shouldn't touch the rest of the app)
- Add filter and sort controls to the frontend
- Move to Rails once I've got more hands-on time with it
