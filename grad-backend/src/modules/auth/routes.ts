import { Router } from 'express';
import { authController } from './controller';
import { authMiddleware } from '../../common/middleware/auth';

const router = Router();

// Open ports for authentication processes
router.post('/register', authController.register); // New citizen registration
router.post('/login/email', authController.loginWithEmail); // Sign in with email and password
router.post('/forgot-password', authController.forgotPassword); // Password reset
router.post('/login', authController.login);

// GET: /me -> A hidden endpoint where only logged-in users (via authMiddleware) can retrieve their own profile information.
router.get('/me', authMiddleware, authController.getMe);

export default router;