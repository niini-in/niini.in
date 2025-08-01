const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const winston = require('winston');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
require('dotenv').config();

const notificationRoutes = require('./routes/notifications');
const { startConsumer } = require('./kafka/consumer');
const { connectDatabase } = require('./database/database');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console()
  ]
});

const app = express();

// Swagger configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Notification Service API',
      version: '1.0.0',
      description: 'Notification management service for MiniShop e-commerce platform',
      contact: {
        name: 'MiniShop Support',
        email: 'support@minishop.com'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: 'http://localhost:8085',
        description: 'Development server'
      }
    ]
  },
  apis: ['./src/routes/*.js', './src/models/*.js']
};

const specs = swaggerJsdoc(swaggerOptions);

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Swagger documentation
app.use('/docs', swaggerUi.serve, swaggerUi.setup(specs));

// Routes
app.use('/api/notifications', notificationRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'notification-service' });
});

// Error handling
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

const PORT = process.env.PORT || 8085;

// Start services
const startServer = async () => {
  try {
    // Connect to database
    await connectDatabase();
    
    // Start Kafka consumer
    await startConsumer();
    
    // Start HTTP server
    app.listen(PORT, () => {
      logger.info(`Notification service running on port ${PORT}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

module.exports = app;