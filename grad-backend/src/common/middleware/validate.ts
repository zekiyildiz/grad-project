import { Request, Response, NextFunction } from 'express';

export const validateRequest = (schema: any) => (req: Request, res: Response, next: NextFunction) => {
    next();
};
