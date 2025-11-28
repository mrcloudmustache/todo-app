package main

import (
	"database/sql"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

type Todo struct {
	ID   int
	Text string
	Done bool
}

var db *sql.DB

var tpl = template.Must(template.New("index").Parse(`
<!DOCTYPE html>
<html>
<head>
	<title>Todo List</title>
	<style>
		body { font-family: Arial; margin: 40px; }
		.done { text-decoration: line-through; color: #777; }
	</style>
</head>
<body>
	<h1>Todo List (RDS)</h1>

	<form method="POST" action="/add">
		<input name="text" required placeholder="New task"/>
		<button type="submit">Add</button>
	</form>

	<ul>
	{{range .}}
		<li>
			<span class="{{if .Done}}done{{end}}">{{.Text}}</span>
			<form method="POST" action="/toggle" style="display:inline">
				<input type="hidden" name="id" value="{{.ID}}">
				<button>Toggle</button>
			</form>
			<form method="POST" action="/delete" style="display:inline">
				<input type="hidden" name="id" value="{{.ID}}">
				<button>Delete</button>
			</form>
		</li>
	{{end}}
	</ul>
</body>
</html>
`))

func main() {

	var err error

	db, err = sql.Open("postgres",
		fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
			os.Getenv("DB_HOST"),
			os.Getenv("DB_PORT"),
			os.Getenv("DB_USER"),
			os.Getenv("DB_PASS"),
			os.Getenv("DB_NAME"),
		),
	)
	if err != nil {
		log.Fatal("DB open error:", err)
	}

	if err := db.Ping(); err != nil {
		log.Fatal("DB ping error:", err)
	}

	createTable()

	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/add", addHandler)
	http.HandleFunc("/toggle", toggleHandler)
	http.HandleFunc("/delete", deleteHandler)

	log.Println("Listening on :8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func createTable() {
	_, err := db.Exec(`
	CREATE TABLE IF NOT EXISTS todos (
		id SERIAL PRIMARY KEY,
		text VARCHAR(255),
		done BOOLEAN DEFAULT false
	)
	`)
	if err != nil {
		log.Fatal("Could not create table:", err)
	}
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query(`SELECT id, text, done FROM todos ORDER BY id`)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer rows.Close()

	var todos []Todo
	for rows.Next() {
		var t Todo
		rows.Scan(&t.ID, &t.Text, &t.Done)
		todos = append(todos, t)
	}

	tpl.Execute(w, todos)
}

func addHandler(w http.ResponseWriter, r *http.Request) {
	text := r.FormValue("text")
	if text != "" {
		db.Exec(`INSERT INTO todos (text) VALUES ($1)`, text)
	}
	http.Redirect(w, r, "/", 303)
}

func toggleHandler(w http.ResponseWriter, r *http.Request) {
	id := r.FormValue("id")
	db.Exec(`UPDATE todos SET done = NOT done WHERE id = $1`, id)
	http.Redirect(w, r, "/", 303)
}

func deleteHandler(w http.ResponseWriter, r *http.Request) {
	id := r.FormValue("id")
	db.Exec(`DELETE FROM todos WHERE id = $1`, id)
	http.Redirect(w, r, "/", 303)
}
