#!/bin/bash

#Usage: $0 create|update|delete|show|list|search
#create  - Create a new task
#update  - Update an existing task
#delete  - Delete a task
#show    - Show all information about a task
#list    - List tasks of a given day (default: current day)
TODO_FILE="todo.txt"

usage() {
    echo "Usage: $0 [option] [arguments]"
    echo "Options:"
    echo "  -c               Create a new task"
    echo "  -u <id>          Update an existing task"
    echo "  -d <id>          Delete an existing task"
    echo "  -l               List all tasks for today"
    echo "  -s <title>       Search for a task by title"
    exit 1
}


if [ ! -f "$TODO_FILE" ]; then
    touch "$TODO_FILE"
fi


create_task() {
    local title="$1"
    local description="$2"
    local location="$3"
    local due_date="$4"
    local id=$(uuidgen) 

    
    if ! date -d "$due_date" &>/dev/null; then
        echo "Error: Invalid date format. Please use 'YYYY-MM-DD HH:MM'" >&2
        return 1
    fi

    echo "$id,$title,$description,$location,$due_date,false" >> "$TODO_FILE"
    echo "Task created with ID $id"
}


update_task() {
    local id="$1"
    
    local temp_file=$(mktemp)

    local task_found=false
    while IFS=',' read -r task_id title description location due_date completed; do
        if [[ "$task_id" == "$id" ]]; then
            task_found=true
            read -p "Enter new title (current: $title): " new_title
            read -p "Enter new description (current: $description): " new_description
            read -p "Enter new location (current: $location): " new_location
            read -p "Enter new due date (YYYY-MM-DD HH:MM, current: $due_date): " new_due_date

            
            if [[ "$new_due_date" && ! $(date -d "$new_due_date" 2>/dev/null) ]]; then
                echo "Error: Invalid date format. Please use 'YYYY-MM-DD HH:MM'" >&2
                rm "$temp_file"
                return 1
            fi

            
            new_title=${new_title:-$title}
            new_description=${new_description:-$description}
            new_location=${new_location:-$location}
            new_due_date=${new_due_date:-$due_date}

            echo "$id,$new_title,$new_description,$new_location,$new_due_date,$completed" >> "$temp_file"
        else
            echo "$task_id,$title,$description,$location,$due_date,$completed" >> "$temp_file"
        fi
    done < "$TODO_FILE"

    if [ "$task_found" = true ]; then
        mv "$temp_file" "$TODO_FILE"
        echo "Task with ID $id has been updated."
    else
        rm "$temp_file"
        echo "Error: Task with ID $id not found." >&2
        return 1
    fi
}


delete_task() {
    local id="$1"
    local temp_file=$(mktemp)
    local task_found=false

    while IFS=',' read -r task_id title description location due_date completed; do
        if [[ "$task_id" != "$id" ]]; then
            echo "$task_id,$title,$description,$location,$due_date,$completed" >> "$temp_file"
        else
            task_found=true
        fi
    done < "$TODO_FILE"

    if [ "$task_found" = true ]; then
        mv "$temp_file" "$TODO_FILE"
        echo "Task with ID $id has been deleted."
    else
        rm "$temp_file"
        echo "Error: Task with ID $id not found." >&2
        return 1
    fi
}


list_today_tasks() {
    local today=$(date '+%Y-%m-%d')
    grep "$today" "$TODO_FILE" | while IFS=',' read -r id title description location due_date completed; do
        echo "ID: $id"
        echo "Title: $title"
        echo "Due Date: $due_date"
        [[ "$completed" == "true" ]] && status="Completed" || status="Uncompleted"
        echo "Status: $status"
        echo
    done
}


search_task() {
    local title="$1"
    grep -i "$title" "$TODO_FILE" | while IFS=',' read -r id task_title description location due_date completed; do
        echo "ID: $id"
        echo "Title: $task_title"
        echo "Due Date: $due_date"
        [[ "$completed" == "true" ]] && status="Completed" || status="Uncompleted"
        echo "Status: $status"
        echo
    done
}


while getopts ":cu:d:ls:" opt; do
    case $opt in
        c)
            read -p "Enter title: " title
            read -p "Enter description: " description
            read -p "Enter location: " location
            read -p "Enter due date (YYYY-MM-DD HH:MM): " due_date
            create_task "$title" "$description" "$location" "$due_date"
            ;;
        u)
            read -p "Enter ID of the task to update: " task_id
            update_task "$task_id"
            ;;
        d)
            read -p "Enter ID of the task to delete: " task_id
            delete_task "$task_id"
            ;;
        l)
            list_today_tasks
            ;;
        s)
            read -p "Enter title to search: " search_title
            search_task "$search_title"
            ;;
        \?)
            usage
            ;;
    esac
done


if [ $OPTIND -eq 1 ]; then
    list_today_tasks
fi
