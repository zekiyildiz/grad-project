import { Request, Response, NextFunction } from 'express';
import { ReportService } from './service';

const reportService = new ReportService();

export const createReport = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = (req as any).user?.uid;
        if (!userId) {
            res.status(401).json({ success: false, message: 'Kullanıcı kimliği bulunamadı' });
            return;
        }

        console.log("📥 Rapor oluşturma isteği alındı:", req.body);

        const report = await reportService.createReport({
            userId,
            category: req.body.category,
            description: req.body.description,
            location: req.body.location,
            images: req.body.images,
        });

        res.status(201).json({
            success: true,
            message: "Rapor başarıyla oluşturuldu",
            data: report
        });
    } catch (error) {
        console.error("❌ Rapor oluşturma hatası:", error);
        next(error);
    }
};

export const getMyReports = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = (req as any).user?.uid;
        if (!userId) {
            res.status(401).json({ success: false, message: 'Kullanıcı kimliği bulunamadı' });
            return;
        }

        console.log(`📥 Geçmiş ihbarlar isteği (user: ${userId})`);
        const reports = await reportService.getMyReports(userId);
        console.log(`📦 ${reports.length} adet rapor dönülüyor`);

        res.status(200).json(reports);
    } catch (error) {
        console.error("❌ Raporları getirme hatası:", error);
        next(error);
    }
};

export const getReportById = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const report = await reportService.getReportById(req.params.id);
        if (!report) {
            res.status(404).json({ success: false, message: 'Rapor bulunamadı' });
            return;
        }
        res.status(200).json(report);
    } catch (error) {
        next(error);
    }
};