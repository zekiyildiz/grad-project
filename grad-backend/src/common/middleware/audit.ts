import { Request, Response, NextFunction } from 'express';

export const auditMiddleware = (req: Request, res: Response, next: NextFunction) => {
    next();
};
