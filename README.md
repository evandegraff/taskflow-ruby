# TaskFlow

A small full-stack task manager built to practice Ruby on the backend and
vanilla JavaScript on the frontend.

- **Backend:** Plain Ruby, using only the standard library (`WEBrick` for
  the HTTP server, `JSON` for serialization). No Rails, no gems to install —
  clone it and run it with just a Ruby interpreter.
- **Frontend:** HTML/CSS/JavaScript with no build step or framework —
  `fetch()` and the DOM API talking directly to the REST endpoints below.
- **Tests:** `Minitest` (also part of Ruby's standard library) covering the
  model and the in-memory data store.

I built this to get more hands-on with Ruby while applying for backend
roles — I'm still learning Rails, so this intentionally sticks to plain
Ruby to show how the language itself works without a framework doing the
heavy lifting.

## Running it

Requires only Ruby (3.0+). No gem install needed.

```bash
git clone https://github.com/YOUR_USERNAME/taskflow-ruby.git
cd taskflow-ruby
ruby server/app.rb
```

Then open **http://localhost:4567** in a browser.

## Running the tests

```bash
rake test
# or directly:
ruby -Itest test/task_test.rb
ruby -Itest test/task_store_test.rb
```

## API

| Method | Path             | Description         |
|--------|------------------|----------------------|
| GET    | `/api/tasks`     | List all tasks       |
| POST   | `/api/tasks`     | Create a task        |
| GET    | `/api/tasks/:id` | Fetch a single task  |
| PUT    | `/api/tasks/:id` | Update a task        |
| DELETE | `/api/tasks/:id` | Delete a task        |

Example:

```bash
curl -X POST http://localhost:4567/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Write more Ruby", "description": "Practice makes progress"}'
```

## Project structure

```
server/
  app.rb          # HTTP server + routing
  task.rb         # Task model
  task_store.rb   # In-memory, thread-safe data store
public/
  index.html
  styles.css
  app.js          # Frontend logic (fetch-based CRUD)
test/
  task_test.rb
  task_store_test.rb
```

## What I'd do next

- Swap `TaskStore` for a real database (the class is already isolated so
  this shouldn't touch the rest of the app)
- Add request validation with clearer error messages
- Move to Rails once I've got more hands-on time with it
