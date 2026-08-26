  def create(title:, description: "", completed: false, priority: "medium")
    @mutex.synchronize do
      task = Task.new(id: @next_id, title: title, description: description, completed: completed, priority: priority)
      @tasks[task.id] = task
      @next_id += 1
      task
    end
  end