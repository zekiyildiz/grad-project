import { Router } from 'express';
import * as controller from './controller'; 

const router = Router();

// POST isteğini karşılayan satır (EKSİK OLAN BUYDU)
// Adres: /api/v1/reports/
router.post('/', controller.createReport);

// İleride lazım olacak diğer rotalar (Şimdilik yorum satırı kalsın)
// router.get('/', controller.getMyReports);
// router.get('/:id', controller.getReportById);

export default router;