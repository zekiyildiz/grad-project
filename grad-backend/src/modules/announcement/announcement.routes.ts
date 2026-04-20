import { Router } from 'express';
import { getAnnouncements } from './announcement.controller';

const router = Router();

// GET /api/v1/announcements şeklinde çağrılacak
router.get('/', getAnnouncements);

export default router;