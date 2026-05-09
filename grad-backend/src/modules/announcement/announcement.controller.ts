import { Request, Response } from 'express';
import admin from 'firebase-admin';

export const getAnnouncements = async (req: Request, res: Response) => {
    try {
        const db = admin.firestore();
        // It must be the same as your collection name in Firebase
        const snapshot = await db.collection('announcements').orderBy('date', 'desc').get();
        
        const announcements = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        res.status(200).json(announcements);
    } catch (error) {
        res.status(500).json({ message: "Duyurular getirilirken hata oluştu.", error });
    }
};