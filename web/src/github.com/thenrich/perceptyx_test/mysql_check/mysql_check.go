package main

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"os"
	"fmt"
)

// Main HTTP method, connect to MySQL and run query
func main() {
	db, err := sql.Open("mysql", os.Getenv("MYSQL_CONNECTION_STRING"))
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
		return
	}

	defer db.Close()

	if err = db.Ping(); err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
		return
	}

	os.Exit(0)

}