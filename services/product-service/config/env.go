package config

import (
	"log"
	"os"
)

func LoadEnv() {
	// Set default values
	if os.Getenv("PORT") == "" {
		os.Setenv("PORT", "8082")
	}
	if os.Getenv("DB_HOST") == "" {
		os.Setenv("DB_HOST", "localhost")
	}
	if os.Getenv("DB_PORT") == "" {
		os.Setenv("DB_PORT", "5432")
	}
	if os.Getenv("DB_NAME") == "" {
		os.Setenv("DB_NAME", "productdb")
	}
	if os.Getenv("DB_USER") == "" {
		os.Setenv("DB_USER", "postgres")
	}
	if os.Getenv("DB_PASSWORD") == "" {
		os.Setenv("DB_PASSWORD", "postgres")
	}

	log.Println("Environment variables loaded")
}