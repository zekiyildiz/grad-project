import { Router } from 'express';
import { authMiddleware } from '../../common/middleware/auth';
import { userController } from './controller';

const router = Router();

router.get('/profile', authMiddleware, userController.getProfile);
router.put('/profile', authMiddleware, userController.updateProfile);

export default router;
