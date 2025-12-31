import { Request, Response, NextFunction } from 'express';

export const createReport = async (req: Request, res: Response, next: NextFunction) => {
    try {
        console.log("📥 Rapor oluşturma isteği alındı:", req.body);

        // Şimdilik veritabanına kaydetmiş gibi (mock) cevap dönüyoruz
        // İleride buraya service.createReport(req.body) gelecek
        
        res.status(201).json({
            success: true,
            message: "Rapor başarıyla oluşturuldu",
            data: {
                id: "R-" + Math.floor(Math.random() * 10000),
                ...req.body,
                status: "YENİ",
                createdAt: new Date()
            }
        });
    } catch (error) {
        next(error);
    }
};