import { getFirestore } from '../../config/firebase';

const COLLECTION = 'reports';

export class ReportService {

    /**
     * Yeni rapor oluştur ve Firestore'a kaydet
     */
    async createReport(data: {
        userId: string;
        category: string;
        description: string;
        location: { latitude: number; longitude: number; address?: string };
        images?: string[];
    }) {
        const db = getFirestore();
        const reportData = {
            userId: data.userId,
            category: data.category,
            description: data.description,
            location: data.location,
            images: data.images || [],
            status: 'PENDING',
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        const docRef = await db.collection(COLLECTION).add(reportData);
        console.log(`✅ Rapor Firestore'a kaydedildi: ${docRef.id}`);

        return { id: docRef.id, ...reportData };
    }

    /**
     * Kullanıcının tüm raporlarını getir (yeniden eskiye)
     */
    async getMyReports(userId: string) {
        const db = getFirestore();
        const snapshot = await db
            .collection(COLLECTION)
            .where('userId', '==', userId)
            .orderBy('createdAt', 'desc')
            .get();

        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt?.toDate?.()
                ? doc.data().createdAt.toDate().toISOString()
                : doc.data().createdAt,
            updatedAt: doc.data().updatedAt?.toDate?.()
                ? doc.data().updatedAt.toDate().toISOString()
                : doc.data().updatedAt,
        }));
    }

    /**
     * Tek bir raporu ID ile getir
     */
    async getReportById(id: string) {
        const db = getFirestore();
        const doc = await db.collection(COLLECTION).doc(id).get();

        if (!doc.exists) {
            return null;
        }

        const data = doc.data()!;
        return {
            id: doc.id,
            ...data,
            createdAt: data.createdAt?.toDate?.()
                ? data.createdAt.toDate().toISOString()
                : data.createdAt,
            updatedAt: data.updatedAt?.toDate?.()
                ? data.updatedAt.toDate().toISOString()
                : data.updatedAt,
        };
    }

    /**
     * Rapor durumunu güncelle
     */
    async updateReportStatus(id: string, status: string, comment?: string) {
        const db = getFirestore();
        const updateData: any = {
            status,
            updatedAt: new Date(),
        };
        if (comment) updateData.statusComment = comment;

        await db.collection(COLLECTION).doc(id).update(updateData);
        return this.getReportById(id);
    }
}
