import { Router } from 'express';
import * as controller from './controller';
import { authMiddleware } from '../../common/middleware/auth';

const router = Router();

//authMiddleware -> Only users who have been authenticated via Firebase and possess a valid token can access these routes

// --- NOTIFICATION METHODS (Static paths are at the top) ---
// Get -> It is used solely to retrieve data from the server
// Put -> Used to modify all or part of an existing record in the database
// Delete -> Used to remove a record from the daabase
router.get('/notifications', authMiddleware, controller.getMyNotifications);
router.put('/notifications/read-all', authMiddleware, controller.markAllNotificationsAsRead);
router.put('/notifications/:id/read', authMiddleware, controller.markNotificationAsRead);
router.delete('/notifications/:id', authMiddleware, controller.deleteNotification);

// --- GENERAL REPORTING METHODS ---
// Post -> Used to send new data to the server and create a “new record” in the database
// '/' -> Root Directory: Works when you go directly to the /reports address
// '/all' -> A dedicated path created for everyone to submit complaints (/reports/all)
router.post('/', authMiddleware, controller.createReport);
router.get('/all', authMiddleware, controller.getAllReports);
router.get('/', authMiddleware, controller.getMyReports);

// --- INDIVIDUAL OPERATIONS ---
// '/:id' (Dynamic Path): The colon (:) at the beginning indicates that this is a variable. If the user goes to the address /reports/12345, 12345 is automatically assigned to the id variable (req.params.id).
router.get('/:id', authMiddleware, controller.getReportById);
router.put('/:id/assign', authMiddleware, controller.assignReport);
router.put('/:id/status', authMiddleware, controller.updateReportStatus);

// --- CATEGORY UPDATE ROUTE ---
router.put('/:id/category', authMiddleware, controller.updateReportCategory);

export default router;