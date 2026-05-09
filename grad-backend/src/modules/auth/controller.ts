import { Request, Response, NextFunction } from 'express';
import { authService } from './service';
import { registerSchema, loginSchema, forgotPasswordSchema, verifyTokenSchema } from './dto';

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Authentication endpoints
 */

class AuthController {
    /**
     * @swagger
     * /auth/register:
     *   post:
     *     summary: Register a new user with email and password
     *     tags: [Auth]
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             type: object
     *             required:
     *               - email
     *               - password
     *               - fullName
     *               - phone
     *               - address
     *             properties:
     *               email:
     *                 type: string
     *                 format: email
     *               password:
     *                 type: string
     *                 minLength: 6
     *               fullName:
     *                 type: string
     *                 description: Full name of the user
     *               phone:
     *                 type: string
     *                 description: Phone number
     *               address:
     *                 type: string
     *                 description: User address
     *               displayName:
     *                 type: string
     *                 description: Optional display name
     *     responses:
     *       200:
     *         description: User registered successfully
     *       400:
     *         description: Invalid input or email already exists
     */
    async register(req: Request, res: Response, next: NextFunction) {
        try {
            // Does the data from Flutter comply with our rules?
            const data = registerSchema.parse(req.body);
            // If the data is valid, forward the user to the Service layer for creation.
            const result = await authService.register(data);
            // Return the token and user information to the user with a 200 OK response
            res.json({ success: true, data: result });
        } catch (error: any) {
            // If Zod validation fails, return a 400 (Bad Request) status code and specify the reason.
            if (error.name === 'ZodError') {
                res.status(400).json({ success: false, message: 'Validation error', errors: error.errors });
                return;
            }
            // Use custom statusCode if available
            const statusCode = error.statusCode || 500;
            res.status(statusCode).json({ success: false, message: error.message });
        }
    }

    /**
     * @swagger
     * /auth/login/email:
     *   post:
     *     summary: Login with email and password
     *     tags: [Auth]
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             type: object
     *             required:
     *               - email
     *               - password
     *             properties:
     *               email:
     *                 type: string
     *                 format: email
     *               password:
     *                 type: string
     *     responses:
     *       200:
     *         description: Login successful
     *       401:
     *         description: Invalid credentials
     */
    async loginWithEmail(req: Request, res: Response, next: NextFunction) {
        try {
            const data = loginSchema.parse(req.body);
            const result = await authService.loginWithEmail(data);
            res.json({ success: true, data: result });
        } catch (error: any) {
            if (error.name === 'ZodError') {
                res.status(400).json({ success: false, message: 'Validation error', errors: error.errors });
                return;
            }
            // Use custom statusCode if available
            const statusCode = error.statusCode || 401;
            res.status(statusCode).json({ success: false, message: error.message });
        }
    }

    /**
     * @swagger
     * /auth/forgot-password:
     *   post:
     *     summary: Request password reset email
     *     tags: [Auth]
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             type: object
     *             required:
     *               - email
     *             properties:
     *               email:
     *                 type: string
     *                 format: email
     *     responses:
     *       200:
     *         description: Password reset link sent
     */
    async forgotPassword(req: Request, res: Response, next: NextFunction) {
        try {
            const data = forgotPasswordSchema.parse(req.body);
            const result = await authService.forgotPassword(data);
            res.json({ success: true, data: result });
        } catch (error: any) {
            if (error.name === 'ZodError') {
                res.status(400).json({ success: false, message: 'Validation error', errors: error.errors });
                return;
            }
            next(error);
        }
    }

    /**
     * @swagger
     * /auth/login:
     *   post:
     *     summary: Login with Firebase ID Token
     *     tags: [Auth]
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             type: object
     *             properties:
     *               token:
     *                 type: string
     *                 description: Firebase ID Token
     *     responses:
     *       200:
     *         description: User logged in successfully
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 success:
     *                   type: boolean
     *                 data:
     *                   type: object
     *                   properties:
     *                     user:
     *                       type: object
     *       401:
     *         description: Invalid token
     */
    async login(req: Request, res: Response, next: NextFunction) {
        try {
            const { token } = verifyTokenSchema.parse(req.body);

            const result = await authService.login(token);
            res.json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    /**
     * @swagger
     * /auth/me:
     *   get:
     *     summary: Get current logged in user
     *     tags: [Auth]
     *     security:
     *       - bearerAuth: []
     *     responses:
     *       200:
     *         description: Current user profile
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 user:
     *                   type: object
     *       401:
     *         description: Unauthorized
     */
    async getMe(req: Request, res: Response, next: NextFunction) {
        try {
            // req.user is populated by authMiddleware
            res.json({ success: true, data: { user: (req as any).user } });
        } catch (error) {
            next(error);
        }
    }
}

export const authController = new AuthController();
