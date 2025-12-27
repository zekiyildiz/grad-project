import { Request, Response, NextFunction } from 'express';

export const rbacMiddleware = (roles: string[]) => (req: Request, res: Response, next: NextFunction) => {
    next();
};
