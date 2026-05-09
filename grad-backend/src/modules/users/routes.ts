import { Router } from 'express';
import { authMiddleware } from '../../common/middleware/auth';
import { userController } from './controller';

const router = Router();

router.get('/profile', authMiddleware, userController.getProfile); // GET: When a citizen opens their profile page (to view their information)
router.put('/profile', authMiddleware, userController.updateProfile); // PUT: When a citizen updates their profile and clicks the “Save” button (to modify existing data)

export default router;