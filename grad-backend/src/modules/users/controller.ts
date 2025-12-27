import { Request, Response, NextFunction } from 'express';
import { userService } from './service';
import { updateProfileSchema } from './dto';

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: User profile management
 */

class UserController {
    /**
     * @swagger
     * /users/profile:
     *   get:
     *     summary: Get current user profile with statistics
     *     tags: [Users]
     *     security:
     *       - bearerAuth: []
     *     responses:
     *       200:
     *         description: User profile retrieved successfully
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
     *                       properties:
     *                         uid:
     *                           type: string
     *                         email:
     *                           type: string
     *                         fullName:
     *                           type: string
     *                         phone:
     *                           type: string
     *                         address:
     *                           type: string
     *                         displayName:
     *                           type: string
     *                         photoURL:
     *                           type: string
     *                         role:
     *                           type: string
     *                     statistics:
     *                       type: object
     *                       properties:
     *                         totalReports:
     *                           type: number
     *                         resolvedReports:
     *                           type: number
     *                         surveyCount:
     *                           type: number
     *       401:
     *         description: Unauthorized
     */
    async getProfile(req: Request, res: Response, next: NextFunction) {
        try {
            const user = (req as any).user;
            if (!user || !user.uid) {
                res.status(401).json({ success: false, message: 'Unauthorized' });
                return;
            }

            const result = await userService.getProfile(user.uid);
            res.json({ success: true, data: result });
        } catch (error: any) {
            if (error.message === 'User not found') {
                res.status(404).json({ success: false, message: error.message });
                return;
            }
            next(error);
        }
    }

    /**
     * @swagger
     * /users/profile:
     *   put:
     *     summary: Update user profile
     *     tags: [Users]
     *     security:
     *       - bearerAuth: []
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             type: object
     *             properties:
     *               fullName:
     *                 type: string
     *               phone:
     *                 type: string
     *               address:
     *                 type: string
     *               displayName:
     *                 type: string
     *               photoURL:
     *                 type: string
     *     responses:
     *       200:
     *         description: Profile updated successfully
     *       401:
     *         description: Unauthorized
     */
    async updateProfile(req: Request, res: Response, next: NextFunction) {
        try {
            const user = (req as any).user;
            if (!user || !user.uid) {
                res.status(401).json({ success: false, message: 'Unauthorized' });
                return;
            }

            const data = updateProfileSchema.parse(req.body);
            const result = await userService.updateProfile(user.uid, data);
            res.json({ success: true, data: result, message: 'Profile updated successfully' });
        } catch (error: any) {
            if (error.name === 'ZodError') {
                res.status(400).json({ success: false, message: 'Validation error', errors: error.errors });
                return;
            }
            if (error.message === 'User not found') {
                res.status(404).json({ success: false, message: error.message });
                return;
            }
            next(error);
        }
    }
}

export const userController = new UserController();
