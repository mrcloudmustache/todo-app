package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"sync"
)

// Todo item
type Todo struct {
	ID   int
	Text string
	Done bool
}

var (
	todos   = []Todo{}
	nextID  = 1
	todoMux sync.Mutex
)

var tpl = template.Must(template.New("index").Parse(`
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Todo List</title>
	<style>
		body { font-family: Arial; margin: 40px; }
		.done { text-decoration: line-through; color: #777; }
	</style>
</head>
<body>
	<h1>Todo List</h1>

	<form method="POST" action="/add">
		<input name="text" placeholder="New task" required />
		<button type="submit">Add</button>
	</form>

	<ul>
		{{range .}}
			<li>
				<span class="{{if .Done}}done{{end}}">{{.Text}}</span>
				<form style="display:inline" method="POST" action="/toggle">
					<input type="hidden" name="id" value="{{.ID}}">
					<button type="submit">Toggle</button>
				</form>
				<form style="display:inline" method="POST" action="/delete">
					<input type="hidden" name="id" value="{{.ID}}">
					<button type="submit">Delete</button>
				</form>
			</li>
		{{end}}
	</ul>
</body>
</html>
`))

func main() {
	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/add", addHandler)
	http.HandleFunc("/toggle", toggleHandler)
	http.HandleFunc("/delete", deleteHandler)

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	todoMux.Lock()
	defer todoMux.Unlock()
	tpl.Execute(w, todos)
}

func addHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		text := r.FormValue("text")
		if text != "" {
			todoMux.Lock()
			todos = append(todos, Todo{ID: nextID, Text: text})
			nextID++
			todoMux.Unlock()
		}
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func toggleHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		id := r.FormValue("id")
		todoMux.Lock()
		for i := range todos {
			if itoa(todos[i].ID) == id {
				todos[i].Done = !todos[i].Done
				break
			}
		}
		todoMux.Unlock()
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func deleteHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		id := r.FormValue("id")
		todoMux.Lock()
		for i := range todos {
			if itoa(todos[i].ID) == id {
				todos = append(todos[:i], todos[i+1:]...)
				break
			}
		}
		todoMux.Unlock()
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

// small helper
func itoa(n int) string {
	return fmt.Sprintf("%d", n)
}
