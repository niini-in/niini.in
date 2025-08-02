package main

import (
	"log"
	"os"

	"github.com/minishop/product-service/config"
	"github.com/minishop/product-service/handlers"
	"github.com/minishop/product-service/models"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	config.LoadEnv()

	dsn := "host=" + os.Getenv("DB_HOST") +
		" port=" + os.Getenv("DB_PORT") +
		" user=" + os.Getenv("DB_USER") +
		" password=" + os.Getenv("DB_PASSWORD") +
		" dbname=" + os.Getenv("DB_NAME") +
		" sslmode=disable"

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Auto migrate the schema
	db.AutoMigrate(&models.Product{})

	r := gin.Default()

	// Routes
	productHandler := handlers.NewProductHandler(db)
	r.GET("/api/products", productHandler.GetAllProducts)
	r.GET("/api/products/:id", productHandler.GetProductByID)
	r.POST("/api/products", productHandler.CreateProduct)
	r.PUT("/api/products/:id", productHandler.UpdateProduct)
	r.DELETE("/api/products/:id", productHandler.DeleteProduct)
	r.GET("/api/products/search", productHandler.SearchProducts)
	r.GET("/metrics", gin.WrapH(promhttp.Handler()))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8082"
	}

	log.Printf("Product service starting on port %s", port)
	r.Run(":" + port)
}