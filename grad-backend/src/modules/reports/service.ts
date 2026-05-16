import { getFirestore } from '../../config/firebase';

const COLLECTION = 'reports';

const getAiSuggestion = (category: string) => {
    //Flutter can send “ÇUKUR” using a Turkish keyboard, but since the YOLO model was trained on English, it may send “CUKUR.” For normalization
    const cat = category?.toUpperCase()
        .replace(/İ/g, 'I').replace(/Ç/g, 'C').replace(/Ş/g, 'S')
        .replace(/Ğ/g, 'G').replace(/Ü/g, 'U').replace(/Ö/g, 'O').trim();
    
    // Institutional Links by Category
    switch (cat) {
        case 'YANGIN': 
            return 'ITFAIYE';
            
        case 'GAZ KACAGI':
        case 'ELEKTRIK ARIZASI':
        case 'ELEKTRIK': 
            return 'TEDAS';
            
        case 'SU PATLAGI': 
            return 'ASKI';
            
        case 'COPLUK': 
            return 'TEMIZLIK';
            
        case 'SCOOTER':
        case 'POSTER': 
            return 'ZABITA';
            
        case 'TRAFIK': // Traffic complaints to UKOME
            return 'UKOME';
            
        // Complaints regarding benches and trees should be directed to the Parks and Gardens Department
        case 'KIRIK_BANK':
        case 'AGAC': 
            return 'PARK_BAHCE';
            
        case 'YOL COKMESI':
        case 'CUKUR': 
            return 'FEN_ISLERI';
            
        default: 
            return 'DIGER'; 
    }
};

export class ReportService {

    /**
     * 1. CREATING A NEW REPORT (DISTINCTION BETWEEN SYSTEM AND CITIZEN)
     */
    async createReport(data: any) {
        const db = getFirestore();
        
        const categoryUpper = (data.category || '').toUpperCase();
        
        // If the citizen submitted it via the “Urgent” screen (if isUrgent is true), mark it as urgent regardless of the content
        const isUrgent = data.isUrgent === true || data.isUrgent === 'true';

        const reportData = {
            ...data,
            status: 'PENDING',
            isUrgent: isUrgent, 
            aiSuggestedInstitution: getAiSuggestion(data.category),
            assignedInstitution: '',
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        const docRef = await db.collection(COLLECTION).add(reportData);
        console.log(`📝 Rapor eklendi. ID: ${docRef.id}. Acil mi?: ${isUrgent}`);

        if (data.userId) {
            const categoryName = data.category ? data.category.toUpperCase() : "DURUM";
            const notifTitle = isUrgent ? `🚨 ACİL ${categoryName} İHBARI` : `${categoryName} Şikayetiniz Alındı`;
            const notifMessage = isUrgent 
                ? `${categoryName} ihbarınız sistemimize acil koduyla kaydedildi.` 
                : `${categoryName} konulu şikayetiniz sisteme kaydedildi.`;
            //as soon as the process is complete, an instant notification is sent to the citizen by calling `this.createNotification` within the same function.
            await this.createNotification(data.userId, notifTitle, notifMessage);
        }
        return { id: docRef.id, ...reportData };
    }

    /**
     * 2. SUBMITTING A COMPLAINT TO AN ORGANIZATION
     */
    async assignInstitution(id: string, institutionCode: string) {
        const db = getFirestore();
        const reportDoc = await db.collection(COLLECTION).doc(id).get();
        if (!reportDoc.exists) return { success: false, message: "Rapor bulunamadı" };
        
        const reportData = reportDoc.data();

        await db.collection(COLLECTION).doc(id).update({
            assignedInstitution: institutionCode,
            status: 'IN_PROGRESS',
            updatedAt: new Date(),
        });

        if (reportData && reportData.userId) {
            await this.createNotification(
                reportData.userId, 
                "Şikayetiniz İşleme Alındı", 
                `Şikayetiniz ilgili kuruma (${institutionCode}) iletildi.`
            );
        }
        
        return { id, success: true };
    }

    /**
     * 3. STATUS UPDATE
     */
    async updateReportStatus(id: string, status: string, comment?: string) {
        const db = getFirestore();
        const reportDoc = await db.collection(COLLECTION).doc(id).get();
        if (!reportDoc.exists) return null;
        
        const reportData = reportDoc.data();
        const updateData: any = { status, updatedAt: new Date() };
        if (comment) updateData.statusComment = comment;

        await db.collection(COLLECTION).doc(id).update(updateData);

        if (reportData && reportData.userId) {
            let baslik = "Şikayet Durumu Güncellendi";
            if (status === 'RESOLVED') baslik = "Şikayetiniz Çözüldü!";
            
            await this.createNotification(
                reportData.userId, 
                baslik, 
                `Şikayetinizin durumu '${status}' olarak güncellenmiştir.`
            );
        }

        return this.getReportById(id);
    }

    /**
     * 4. GET NOTIFICATIONS
     */
    async getMyNotifications(userId: string) {
        const db = getFirestore();
        try {
            const snapshot = await db.collection('notifications')
                .where('userId', '==', userId)
                .orderBy('createdAt', 'desc')
                .get();

            return snapshot.docs.map(doc => {
                const data = doc.data();
                return {
                    id: doc.id,
                    ...data,
                    createdAt: data.createdAt?.toDate?.() ? data.createdAt.toDate().toISOString() : data.createdAt,
                };
            });
        } catch (error) {
            console.error("Bildirim çekme hatası:", error);
            return [];
        }
    }

    /**
     * 5. CENTRAL NOTIFICATION GENERATOR
     */
    private async createNotification(userId: string, title: string, message: string) {
        try {
            const db = getFirestore();
            await db.collection('notifications').add({
                userId, title, message, isRead: false, createdAt: new Date()
            });
        } catch (error) {
            console.error(`Bildirim yazılamadı:`, error);
        }
    }

    /**
     * 6. CATEGORY UPDATE (Service Layer)
     */ 
    async updateReportCategory(id: string, category: string) {
        const db = getFirestore();
        await db.collection(COLLECTION).doc(id).update({ 
            category: category, 
            updatedAt: new Date() 
        });
        return { success: true };
    }

    private _formatReport(doc: any) {
        const data = doc.data(); // Convert Firestore's complex document to a regular object
        return {
            id: doc.id, // Embed the ID generated randomly by Firestore into the object as “id”.
            ...data, // Copy all the data inside (photos, coordinates, etc.) exactly as it is
            // Date Conversion
            createdAt: data.createdAt?.toDate?.() ? data.createdAt.toDate().toISOString() : data.createdAt,
            updatedAt: data.updatedAt?.toDate?.() ? data.updatedAt.toDate().toISOString() : data.updatedAt,
        };
    }

    // When a user taps on an unread notification displayed in bold on their phone, the app sends the notification's ID (id) to the backend. 
    // The backend retrieves the record with that ID from the notifications table. It simply sets the isRead property (has it been read?) to true and records the current date and time (updatedAt).
    async markAsRead(id: string) {
        const db = getFirestore();
        await db.collection('notifications').doc(id).update({ isRead: true, updatedAt: new Date() });
        return { success: true };
    }

    async markAllAsRead(userId: string) {
        const db = getFirestore();
        const snapshot = await db.collection('notifications').where('userId', '==', userId).where('isRead', '==', false).get();
        const batch = db.batch();
        snapshot.docs.forEach((doc) => batch.update(doc.ref, { isRead: true }));
        await batch.commit();
        return { success: true };
    }

    async deleteNotification(id: string) {
        const db = getFirestore();
        await db.collection('notifications').doc(id).delete();
        return { success: true };
    }

    async getMyReports(userId: string) {
        const db = getFirestore();
        const snapshot = await db.collection(COLLECTION).where('userId', '==', userId).orderBy('createdAt', 'desc').get();
        return snapshot.docs.map(doc => this._formatReport(doc));
    }

    async getAllReports() {
        const db = getFirestore();
        const snapshot = await db.collection(COLLECTION).orderBy('createdAt', 'desc').get();
        return snapshot.docs.map(doc => this._formatReport(doc));
    }

    async getReportById(id: string) {
        const db = getFirestore();
        const doc = await db.collection(COLLECTION).doc(id).get();
        return doc.exists ? this._formatReport(doc) : null;
    }
    
}