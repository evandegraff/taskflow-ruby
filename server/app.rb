      task = @store.create(
        title: body["title"],
        description: body["description"] || "",
        completed: body["completed"] || false,
        priority: body["priority"] || "medium"
      )