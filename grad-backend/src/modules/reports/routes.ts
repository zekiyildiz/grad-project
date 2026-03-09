import { Router } from 'express';
import * as controller from './controller';
import { authMiddleware } from '../../common/middleware/auth';

const router = Router();

// Tüm rapor endpointleri auth gerektirir
router.post('/', authMiddleware, controller.createReport);
router.get('/', authMiddleware, controller.getMyReports);
router.get('/:id', authMiddleware, controller.getReportById);

export default router;