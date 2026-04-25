import { getFirestore } from '../../config/firebase';

const COLLECTION = 'reports';

const getAiSuggestion = (category: string) => {
    // Olası Türkçe karakter sorunlarını ve boşlukları temizle
    const cat = category?.toUpperCase()
        .replace(/İ/g, 'I').replace(/Ç/g, 'C').replace(/Ş/g, 'S')
        .replace(/Ğ/g, 'G').replace(/Ü/g, 'U').replace(/Ö/g, 'O').trim();
    
    // 2. Kategoriye Göre Kurum Yönlendirmeleri
    switch (cat) {
        case 'YANGIN': 
            return 'EMNIYET';
            
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
            
        // Trafik şikayetleri doğrudan UKOME'ye
        case 'TRAFIK': 
            return 'UKOME';
            
        // Bank ve Ağaç şikayetleri doğrudan Park ve Bahçeler'e
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
     * 1. YENİ RAPOR OLUŞTURMA (SİSTEM VE VATANDAŞ AYRIMI)
     */
    async createReport(data: any) {
        const db = getFirestore();
        
        const categoryUpper = (data.category || '').toUpperCase();
        const urgentKeywords = ['YANGIN', 'GAZ', 'SU PATLAĞI', 'ELEKTRİK', 'YOL ÇÖKMESİ'];
        
        // Eğer vatandaş "Acil" ekranından gönderdiyse (isUrgent true ise) kelimeye bakmaksızın acil kabul et!
        const isUrgent = data.isUrgent === true || data.isUrgent === 'true' || urgentKeywords.some(keyword => categoryUpper.includes(keyword));

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

            await this.createNotification(data.userId, notifTitle, notifMessage);
        }

        return { id: docRef.id, ...reportData };
    }

    /**
     * 2. KURUMA ATAMA
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
     * 3. DURUM GÜNCELLEME (ÇÖZÜLDÜ)
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
     * 4. BİLDİRİMLERİ GETİR
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
     * 5. MERKEZİ BİLDİRİM OLUŞTURUCU
     */
    private async createNotification(userId: string, title: string, message: string) {
        try {
            const db = getFirestore();
            await db.collection('notifications').add({
                userId, title, message, isRead: false, createdAt: new Date()
            });
        } catch (error) {
            console.error(`❌ Bildirim yazılamadı:`, error);
        }
    }

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

    async updateReportCategory(id: string, category: string) {
        const db = getFirestore();
        await db.collection(COLLECTION).doc(id).update({ 
            category: category, 
            updatedAt: new Date() 
        });
        return { success: true };
    }

    private _formatReport(doc: any) {
        const data = doc.data();
        return {
            id: doc.id,
            ...data,
            createdAt: data.createdAt?.toDate?.() ? data.createdAt.toDate().toISOString() : data.createdAt,
            updatedAt: data.updatedAt?.toDate?.() ? data.updatedAt.toDate().toISOString() : data.updatedAt,
        };
    }
}