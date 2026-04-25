import { Router } from 'express';
import authRoutes from './modules/auth/routes';
import userRoutes from './modules/users/routes';
import reportRoutes from './modules/reports/routes';

import announcementRoutes from './modules/announcement/announcement.routes';

// Multer ve Dosya Sistemi
import multer from 'multer';
import path from 'path';
import fs from 'fs';

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/reports', reportRoutes);

// Buraya duyuru rotasını tekrar bağla 
router.use('/announcements', announcementRoutes);

// ==========================================
// RESİM YÜKLEME API
// ==========================================

// 1. Klasör Yoksa Oluştur
const uploadPath = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadPath)) {
    fs.mkdirSync(uploadPath, { recursive: true });
}

// 2. Multer Ayarları: Dosya Nereye ve Hangi İsimle Kaydedilecek?
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadPath);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        const ext = path.extname(file.originalname);
        cb(null, 'sikayet-' + uniqueSuffix + ext); // Örn: sikayet-16843...jpg
    }
});

const upload = multer({ storage: storage });

// 3. Flutter'dan Gelen İsteği Karşılayan Kapı (/api/v1/upload)
router.post('/upload', upload.single('image'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: 'Lütfen bir resim yükleyin.' });
    }

    const protocol = req.protocol;
    const host = req.get('host');
    
    // Uygulamanın veritabanına kaydedeceği Tam URL 
    const imageUrl = `${protocol}://${host}/uploads/${req.file.filename}`;

    console.log(`📸 Yeni resim yüklendi: ${imageUrl}`);

    res.status(200).json({
        message: 'Resim başarıyla yüklendi',
        imageUrl: imageUrl
    });
});

export default router;