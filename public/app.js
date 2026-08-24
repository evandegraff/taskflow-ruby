// TaskFlow frontend
// Talks to the Ruby API over fetch(). No frameworks, no build step —
// just DOM APIs, so it's easy to read top to bottom.

const API_BASE = "/api/tasks";

const form = document.getElementById("task-form");
const titleInput = document.getElementById("task-title");
const descriptionInput = document.getElementById("task-description");
const taskList = document.getElementById("task-list");
const errorBanner = document.getElementById("error-banner");

document.addEventListener("DOMContentLoaded", loadTasks);
form.addEventListener("submit", handleCreateTask);

async function loadTasks() {
  try {
    const tasks = await request(API_BASE);
    renderTasks(tasks);
  } catch (err) {
    showError("Couldn't load tasks. Is the API running?");
  }
}

async function handleCreateTask(event) {
  event.preventDefault();
  const title = titleInput.value.trim();
  if (!title) return;

  try {
    await request(API_BASE, {
      method: "POST",
      body: JSON.stringify({
        title,
        description: descriptionInput.value.trim(),
      }),
    });
    titleInput.value = "";
    descriptionInput.value = "";
    await loadTasks();
  } catch (err) {
    showError("Couldn't create that task. Please try again.");
  }
}

async function toggleComplete(task) {
  try {
    await request(`${API_BASE}/${task.id}`, {
      method: "PUT",
      body: JSON.stringify({ completed: !task.completed }),
    });
    await loadTasks();
  } catch (err) {
    showError("Couldn't update that task.");
  }
}

async function deleteTask(id) {
  try {
    await request(`${API_BASE}/${id}`, { method: "DELETE" });
    await loadTasks();
  } catch (err) {
    showError("Couldn't delete that task.");
  }
}

function renderTasks(tasks) {
  taskList.innerHTML = "";

  if (tasks.length === 0) {
    const empty = document.createElement("li");
    empty.className = "empty-state";
    empty.textContent = "No tasks yet — add one above.";
    taskList.appendChild(empty);
    return;
  }

  tasks.forEach((task) => taskList.appendChild(buildTaskElement(task)));
}

function buildTaskElement(task) {
  const li = document.createElement("li");
  li.className = `task${task.completed ? " task--completed" : ""}`;

  const checkbox = document.createElement("input");
  checkbox.type = "checkbox";
  checkbox.className = "task__checkbox";
  checkbox.checked = task.completed;
  checkbox.addEventListener("change", () => toggleComplete(task));

  const body = document.createElement("div");
  body.className = "task__body";

  const title = document.createElement("p");
  title.className = "task__title";
  title.textContent = task.title;
  body.appendChild(title);

  if (task.description) {
    const description = document.createElement("p");
    description.className = "task__description";
    description.textContent = task.description;
    body.appendChild(description);
  }

  const deleteBtn = document.createElement("button");
  deleteBtn.className = "task__delete";
  deleteBtn.textContent = "Delete";
  deleteBtn.addEventListener("click", () => deleteTask(task.id));

  li.append(checkbox, body, deleteBtn);
  return li;
}

async function request(url, options = {}) {
  const response = await fetch(url, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });

  if (!response.ok && response.status !== 204) {
    throw new Error(`Request failed: ${response.status}`);
  }

  hideError();
  return response.status === 204 ? null : response.json();
}

function showError(message) {
  errorBanner.textContent = message;
  errorBanner.hidden = false;
}

function hideError() {
  errorBanner.hidden = true;
}
