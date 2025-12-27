import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../../config/jwt';

export const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            res.status(401).json({ success: false, message: 'Unauthorized: No token provided' });
            return;
        }

        const token = authHeader.split(' ')[1];
        try {
            const decoded = verifyToken(token);
            (req as any).user = decoded;
            next();
        } catch (error) {
            console.error('Info: Token verification failed', error);
            res.status(401).json({ success: false, message: 'Unauthorized: Invalid token' });
            return;
        }
    } catch (error) {
        next(error);
    }
};
