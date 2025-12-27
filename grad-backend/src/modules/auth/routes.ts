import { Router } from 'express';
import { authController } from './controller';
import { authMiddleware } from '../../common/middleware/auth';

const router = Router();

router.post('/register', authController.register);
router.post('/login/email', authController.loginWithEmail);
router.post('/forgot-password', authController.forgotPassword);
router.post('/login', authController.login);
router.get('/me', authMiddleware, authController.getMe);

export default router;
