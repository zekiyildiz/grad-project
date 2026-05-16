import { Router } from 'express';
import { getAnnouncements } from './announcement.controller';

const router = Router();

// It will be called as GET /api/v1/announcements
router.get('/', getAnnouncements);

export default router;