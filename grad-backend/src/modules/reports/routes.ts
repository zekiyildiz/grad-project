import { Router } from 'express';
import * as controller from './controller';
import { authMiddleware } from '../../common/middleware/auth';

const router = Router();

// --- BİLDİRİM YOLLARI (Statik yollar en üstte) ---
router.get('/notifications', authMiddleware, controller.getMyNotifications);
router.put('/notifications/read-all', authMiddleware, controller.markAllNotificationsAsRead);
router.put('/notifications/:id/read', authMiddleware, controller.markNotificationAsRead);
router.delete('/notifications/:id', authMiddleware, controller.deleteNotification);

// --- GENEL RAPOR YOLLARI ---
router.post('/', authMiddleware, controller.createReport);
router.get('/all', authMiddleware, controller.getAllReports);
router.get('/', authMiddleware, controller.getMyReports);

// --- TEKİL İŞLEMLER ---
router.get('/:id', authMiddleware, controller.getReportById);
router.put('/:id/assign', authMiddleware, controller.assignReport);
router.put('/:id/status', authMiddleware, controller.updateReportStatus);

// KATEGORİ GÜNCELLEME ROTASI
router.put('/:id/category', authMiddleware, controller.updateReportCategory);

export default router;