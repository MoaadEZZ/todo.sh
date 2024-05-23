the goal of this script is to manage a todo list by storing the data in a txt file "todo.txt" (it also creates the file in case it doesn't existe).

the executable file "todo.sh" handles the management of tasks (creating, updating, deleting, listing, searching) by specifing one of the following parametres:

-c : creates a task.

-u "id" : updates a task using its id (numbre).

-d "id" : delete a task using its id (numbre).

-l : list all tasks of the day.

-s "title" : search for a task by its title.


data is stored the following way: "id,title,description,location,due_date,completed" in the todo.txt file.

the code is organized by dividing each functionality to different functions "create_task()|search_task()|..." the function "usage()" is used in case the user didn't put any parameter.

to run the code:

  - step 1: download the todo.sh file (must be using linux).
  - step 2: execute the commande "chmode u+x todo.sh" or "chmode 700 todo.sh" to give the file owner 'u' the execut proprity 'x'.
  - step 3: ./todo.sh to execute the script.
