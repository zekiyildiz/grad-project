import { Request, Response, NextFunction } from 'express';
import { ReportService } from './service';

//It receives the request from routes.ts, processes the data within it, and forwards it to service.ts to handle the actual task

const reportService = new ReportService();

// Get Notifications
export const getMyNotifications = async (req: any, res: Response) => {
    try {
        const notifications = await reportService.getMyNotifications(req.user.uid);
        res.status(200).json(notifications);
    } catch (error) {
        res.status(500).json({ message: "Bildirim hatası" });
    }
};

// Mark as Read
export const markNotificationAsRead = async (req: Request, res: Response) => {
    try {
        await reportService.markAsRead(req.params.id); // Send the ID from the URL to the service
        res.status(200).json({ success: true }); // If successful, return 200
    } catch (error) {
        res.status(500).json({ message: "Güncellenemedi" }); // If it fails, return 500 (Server Error)
    }
};

// Mark All as Read
export const markAllNotificationsAsRead = async (req: any, res: Response) => {
    try {
        await reportService.markAllAsRead(req.user.uid);
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ message: "İşlem başarısız" });
    }
};

// Delete Notification
export const deleteNotification = async (req: Request, res: Response) => {
    try {
        await reportService.deleteNotification(req.params.id);
        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ message: "Silinemedi" });
    }
};

// CURRENT REPORT FUNCTIONS
export const createReport = async (req: any, res: Response) => {
    try {
        //Urgency Check
        const isUrgentFlag = req.body.isUrgent === true || req.body.isUrgent === 'true';

        // We're collecting the location data coming in from Flutter into the “location” field (object)
        const reportData = {
            userId: req.user.uid, // The user ID of the user passing through the firewall (authMiddleware)
            ...req.body, // Save all other data from Flutter (photo link, category, etc.) to the package
            // Flutter had sent the latitude and longitude separately. To keep the database clean, we're storing them in a new subfolder named “location.”
            location: {
                latitude: req.body.latitude,
                longitude: req.body.longitude,
                address: req.body.address
            },
            isUrgent: isUrgentFlag //Add the urgency status to the package
        };

        //Garbage Collection: We delete the copies of the data we’ve placed in the `location` object that are still in the main array.
        delete reportData.latitude;
        delete reportData.longitude;
        delete reportData.address;

        // We're passing it to service.ts to perform the actual save.
        const report = await reportService.createReport(reportData);
        res.status(201).json(report); // HTTP status code 201 means “Created (Something new has been created).”
    } catch (error) {
        res.status(500).json({ message: "Şikayet oluşturulamadı" }); // We return a 500 code (Internal Server Error) to prevent the system from crashing
    }
};

export const getMyReports = async (req: any, res: Response) => {
    const reports = await reportService.getMyReports(req.user.uid); //Retrieve all reports for this user
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

export const updateReportCategory = async (req: any, res: any, next: any) => {
    try {
        const { id } = req.params;
        const { category } = req.body;

        if (!category) {
            return res.status(400).json({ error: 'Yeni kategori belirtilmedi.' });
        }

        // We are delegating the database operation directly to the service layer
        await reportService.updateReportCategory(id, category);

        return res.status(200).json({ 
            message: 'Kategori başarıyla güncellendi',
            updatedCategory: category 
        });
    } catch (error) {
        console.error('Kategori güncellenirken hata:', error);
        res.status(500).json({ message: "Kategori güncellenemedi" });
    }
};