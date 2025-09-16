package com.todo.task.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.todo.task.model.TodoTask;
import com.todo.task.service.IToDoTaskService;

@RestController
@RequestMapping("/api/todos/task")
@CrossOrigin(origins = "*")
public class ToDoTaskController {
	
	@Autowired
	private IToDoTaskService toDoTaskService;
	
	@GetMapping("/getAllTask")
    public List<TodoTask> getAllTodoTasks(@RequestParam String userId) {
        return toDoTaskService.getAllTodoTasks(userId);
    }
	
	@GetMapping("/{id}")
	public TodoTask getTodoTaskById(@PathVariable Long id) {
		return toDoTaskService.getTodoTaskById(id);
	}
	
	@PostMapping
	public TodoTask createTodoTask(@RequestBody TodoTask todoTask) {
		return toDoTaskService.createToDoTask(todoTask);
	}
	
	@PutMapping("/{id}")
	public TodoTask updateTodoTask(@PathVariable Long id,@RequestBody TodoTask task,@RequestParam String userId) {
		task.setUserId(userId);
		return toDoTaskService.updateToDoTask(id, task);
	}
	
	@DeleteMapping("/{id}")
	public ResponseEntity<String> deleteToDoTaskById(@PathVariable Long id, 
	                                                 @RequestParam String userId) {
	    boolean deleted = toDoTaskService.deleteToDoTaskById(id, userId);
	    if (deleted) {
	        return ResponseEntity.ok("Task deleted successfully");
	    } else {
	        return ResponseEntity.status(HttpStatus.NOT_FOUND)
	                             .body("Task not found or not authorized to delete");
	    }
	}

}
