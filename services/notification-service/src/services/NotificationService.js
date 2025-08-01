const Notification = require('../models/Notification');
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

class NotificationService {
  async getAllNotifications(limit = 50, offset = 0) {
    try {
      const notifications = await Notification.findAll({
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['createdAt', 'DESC']]
      });
      return notifications;
    } catch (error) {
      logger.error('Error fetching all notifications:', error);
      throw new Error('Failed to fetch notifications');
    }
  }

  async getNotificationById(id) {
    try {
      const notification = await Notification.findByPk(id);
      if (!notification) {
        throw new Error('Notification not found');
      }
      return notification;
    } catch (error) {
      logger.error(`Error fetching notification ${id}:`, error);
      throw error;
    }
  }

  async getNotificationsByUserId(userId, limit = 50, offset = 0) {
    try {
      const notifications = await Notification.findAll({
        where: { userId },
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['createdAt', 'DESC']]
      });
      return notifications;
    } catch (error) {
      logger.error(`Error fetching notifications for user ${userId}:`, error);
      throw new Error('Failed to fetch user notifications');
    }
  }

  async createNotification(notificationData) {
    try {
      const notification = await Notification.create({
        userId: notificationData.userId,
        type: notificationData.type,
        title: notificationData.title,
        message: notificationData.message,
        metadata: notificationData.metadata || {}
      });
      
      logger.info(`Notification created: ${notification.id} for user ${notificationData.userId}`);
      return notification;
    } catch (error) {
      logger.error('Error creating notification:', error);
      throw new Error('Failed to create notification');
    }
  }

  async markAsRead(id) {
    try {
      const [updatedRows] = await Notification.update(
        { isRead: true },
        { where: { id } }
      );
      
      if (updatedRows === 0) {
        throw new Error('Notification not found');
      }
      
      const notification = await Notification.findByPk(id);
      logger.info(`Notification marked as read: ${id}`);
      return notification;
    } catch (error) {
      logger.error(`Error marking notification ${id} as read:`, error);
      throw error;
    }
  }

  async markAllAsRead(userId) {
    try {
      const [updatedRows] = await Notification.update(
        { isRead: true },
        { where: { userId } }
      );
      
      logger.info(`All notifications marked as read for user ${userId}: ${updatedRows} updated`);
      return { updatedCount: updatedRows };
    } catch (error) {
      logger.error(`Error marking all notifications as read for user ${userId}:`, error);
      throw new Error('Failed to mark notifications as read');
    }
  }

  async getUnreadCount(userId) {
    try {
      const count = await Notification.count({
        where: { userId, isRead: false }
      });
      return { unreadCount: count };
    } catch (error) {
      logger.error(`Error getting unread count for user ${userId}:`, error);
      throw new Error('Failed to get unread count');
    }
  }
}

module.exports = new NotificationService();