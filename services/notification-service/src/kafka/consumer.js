const { Kafka } = require('kafkajs');
const NotificationService = require('../services/NotificationService');
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

const kafka = new Kafka({
  clientId: 'notification-service',
  brokers: [process.env.KAFKA_BROKERS || 'localhost:9092'],
  retry: {
    retries: 5,
    initialRetryTime: 100,
    factor: 2
  }
});

const consumer = kafka.consumer({
  groupId: 'notification-service-group',
  sessionTimeout: 30000,
  heartbeatInterval: 10000
});

const eventHandlers = {
  'order.created': async (message) => {
    const { userId, orderId, orderNumber, totalAmount } = message;
    await NotificationService.createNotification({
      userId,
      type: 'ORDER_CONFIRMED',
      title: 'Order Confirmed',
      message: `Your order #${orderNumber} has been confirmed. Total: $${totalAmount}`,
      metadata: { orderId, orderNumber, totalAmount }
    });
  },

  'order.shipped': async (message) => {
    const { userId, orderId, orderNumber, trackingNumber } = message;
    await NotificationService.createNotification({
      userId,
      type: 'ORDER_SHIPPED',
      title: 'Order Shipped',
      message: `Your order #${orderNumber} has been shipped. Tracking: ${trackingNumber}`,
      metadata: { orderId, orderNumber, trackingNumber }
    });
  },

  'order.delivered': async (message) => {
    const { userId, orderId, orderNumber } = message;
    await NotificationService.createNotification({
      userId,
      type: 'ORDER_DELIVERED',
      title: 'Order Delivered',
      message: `Your order #${orderNumber} has been delivered. Enjoy your purchase!`,
      metadata: { orderId, orderNumber }
    });
  },

  'payment.success': async (message) => {
    const { userId, orderId, amount, paymentMethod } = message;
    await NotificationService.createNotification({
      userId,
      type: 'PAYMENT_SUCCESS',
      title: 'Payment Successful',
      message: `Payment of $${amount} via ${paymentMethod} was successful for order #${orderId}`,
      metadata: { orderId, amount, paymentMethod }
    });
  },

  'payment.failed': async (message) => {
    const { userId, orderId, amount, reason } = message;
    await NotificationService.createNotification({
      userId,
      type: 'PAYMENT_FAILED',
      title: 'Payment Failed',
      message: `Payment of $${amount} failed for order #${orderId}. Reason: ${reason}`,
      metadata: { orderId, amount, reason }
    });
  },

  'inventory.low': async (message) => {
    const { userId, productId, productName, currentStock } = message;
    await NotificationService.createNotification({
      userId,
      type: 'INVENTORY_LOW',
      title: 'Low Stock Alert',
      message: `Product "${productName}" is running low. Only ${currentStock} items left.`,
      metadata: { productId, productName, currentStock }
    });
  }
};

const startConsumer = async () => {
  try {
    await consumer.connect();
    logger.info('Kafka consumer connected');

    await consumer.subscribe({
      topics: [
        'order.created',
        'order.shipped',
        'order.delivered',
        'payment.success',
        'payment.failed',
        'inventory.low'
      ],
      fromBeginning: false
    });

    await consumer.run({
      eachMessage: async ({ topic, partition, message }) => {
        try {
          const value = JSON.parse(message.value.toString());
          logger.info(`Processing message from topic ${topic}`, { value });

          const handler = eventHandlers[topic];
          if (handler) {
            await handler(value);
            logger.info(`Successfully processed message from topic ${topic}`);
          } else {
            logger.warn(`No handler found for topic ${topic}`);
          }
        } catch (error) {
          logger.error(`Error processing message from topic ${topic}:`, error);
        }
      }
    });

    logger.info('Kafka consumer started successfully');
  } catch (error) {
    logger.error('Error starting Kafka consumer:', error);
    throw error;
  }
};

const stopConsumer = async () => {
  try {
    await consumer.disconnect();
    logger.info('Kafka consumer disconnected');
  } catch (error) {
    logger.error('Error stopping Kafka consumer:', error);
  }
};

module.exports = {
  startConsumer,
  stopConsumer,
  consumer
};