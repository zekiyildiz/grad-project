import { Request, Response, NextFunction } from 'express';
import { ReportService } from './service';

const reportService = new ReportService();

// Bildirimleri Getir
export const getMyNotifications = async (req: any, res: Response) => {
    try {
        const notifications = await reportService.getMyNotifications(req.user.uid);
        res.status(200).json(notifications);
    } catch (error) {
        res.status(500).json({ message: "Bildirim hatası" });
    }
};

// Okundu Yap
export const markNotificationAsRead = async (req: Request, res: Response) => {
    try {
        await reportService.markAsRead(req.params.id);
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ message: "Güncellenemedi" });
    }
};

// Hepsini Okundu Yap
export const markAllNotificationsAsRead = async (req: any, res: Response) => {
    try {
        await reportService.markAllAsRead(req.user.uid);
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ message: "İşlem başarısız" });
    }
};

// Bildirim Sil
export const deleteNotification = async (req: Request, res: Response) => {
    try {
        await reportService.deleteNotification(req.params.id);
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ message: "Silinemedi" });
    }
};

// --- MEVCUT RAPOR FONKSİYONLARI ---
export const createReport = async (req: any, res: Response) => {
    try {
        const isUrgentFlag = req.body.isUrgent === true || req.body.isUrgent === 'true';

        // 🌟 ÇÖZÜM: Flutter'dan dağınık gelen konum verilerini "location" kutusunda (objesinde) topluyoruz
        const reportData = {
            userId: req.user.uid,
            ...req.body,
            location: {
                latitude: req.body.latitude,
                longitude: req.body.longitude,
                address: req.body.address
            },
            isUrgent: isUrgentFlag 
        };

        // Root dizinindeki eski dağınık verileri veritabanında kalabalık yapmasın diye siliyoruz
        delete reportData.latitude;
        delete reportData.longitude;
        delete reportData.address;

        const report = await reportService.createReport(reportData);
        
        res.status(201).json(report);
    } catch (error) {
        res.status(500).json({ message: "Şikayet oluşturulamadı" });
    }
};

export const getMyReports = async (req: any, res: Response) => {
    const reports = await reportService.getMyReports(req.user.uid);
    res.status(200).json(reports);
};

export const getAllReports = async (req: Request, res: Response) => {
    const reports = await reportService.getAllReports();
    res.status(200).json(reports);
};

export const assignReport = async (req: Request, res: Response) => {
    const result = await reportService.assignInstitution(req.params.id, req.body.institutionCode);
    res.status(200).json(result);
};

export const updateReportStatus = async (req: Request, res: Response) => {
    const result = await reportService.updateReportStatus(req.params.id, req.body.status);
    res.status(200).json(result);
};

export const getReportById = async (req: Request, res: Response) => {
    const report = await reportService.getReportById(req.params.id);
    res.status(200).json(report);
};

import * as admin from 'firebase-admin'; 

export const updateReportCategory = async (req: any, res: any, next: any) => {
    try {
        const { id } = req.params;
        const { category } = req.body;

        if (!category) {
            return res.status(400).json({ error: 'Yeni kategori belirtilmedi.' });
        }

        // Firestore veritabanında şikayetin kategorisini güncelle
        const db = admin.firestore();
        await db.collection('reports').doc(id).update({
            category: category,
            updatedAt: new Date().toISOString()
        });

        console.log(`✅ Rapor (${id}) kategorisi '${category}' olarak güncellendi.`);

        return res.status(200).json({ 
            message: 'Kategori başarıyla güncellendi',
            updatedCategory: category 
        });
    } catch (error) {
        console.error('Kategori güncellenirken hata:', error);
        next(error); // Hata yakalayıcıya gönder
    }
};