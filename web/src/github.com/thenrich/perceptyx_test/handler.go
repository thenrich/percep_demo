package main

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"net/http"
	"os"
	"fmt"
)

// Main HTTP method, connect to MySQL and run query
func mainHandler(w http.ResponseWriter, r *http.Request) {

	db, err := sql.Open("mysql", os.Getenv("MYSQL_CONNECTION_STRING"))
	if err != nil {
		http.Error(w, "Error connecting to database", http.StatusInternalServerError)
		return
	}


	q := `
	SELECT CONCAT(first_name, " ", last_name) as full_name
	FROM employees 
	WHERE gender = ?
	AND birth_date = ?
	AND hire_date > ?
	ORDER BY full_name;
	`


	rows, err := db.Query(q, "M", "1965-02-01", "1990-01-01")
	if err != nil {
		http.Error(w, fmt.Sprintf("Query error: %s", err.Error()), http.StatusInternalServerError)
	}

	defer rows.Close()

	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			http.Error(w, fmt.Sprintf("Query error: %s", err.Error()), http.StatusInternalServerError)
		}

		fmt.Fprintf(w, "%s\n", name)
	}


}