package main

import (
	"net/http"
	"log"
)

func main() {
	http.HandleFunc("/", mainHandler)

	log.Fatal(http.ListenAndServe(":8080", nil))
}