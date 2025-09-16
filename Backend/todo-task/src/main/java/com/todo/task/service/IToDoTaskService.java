package com.todo.task.service;

import java.util.List;

import com.todo.task.model.TodoTask;

public interface IToDoTaskService {
	
	List<TodoTask> getAllTodoTasks(String userId);
	TodoTask getTodoTaskById(Long id);
	TodoTask createToDoTask(TodoTask todoTask);
	TodoTask updateToDoTask(Long id,TodoTask todoTask);
	boolean deleteToDoTaskById(Long id, String userId);

}
