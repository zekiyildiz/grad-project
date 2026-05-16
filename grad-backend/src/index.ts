import { Router } from 'express';
import authRoutes from './modules/auth/routes';
import userRoutes from './modules/users/routes';
import reportRoutes from './modules/reports/routes';

import announcementRoutes from './modules/announcement/announcement.routes';

// Multer and the File System
import multer from 'multer';
import path from 'path';
import fs from 'fs';

const router = Router();
// Forward incoming requests to the appropriate ports
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/reports', reportRoutes);

// Buraya duyuru rotasını tekrar bağla 
router.use('/announcements', announcementRoutes);

// ==========================================
// IMAGE UPLOAD API
// ==========================================

// Folder Check: If there is no ‘uploads’ folder on the server, create it automatically to prevent the script from failing.
const uploadPath = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadPath)) {
    fs.mkdirSync(uploadPath, { recursive: true });
}

// Multer Settings: Where and Under What Name Should the File Be Saved?
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadPath);
    },
    filename: function (req, file, cb) {
        // If two users upload ‘image.jpg’ at the same time, we add a millisecond and a random number to the end of the filename to prevent the older one from being deleted.
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        const ext = path.extname(file.originalname);
        cb(null, 'sikayet-' + uniqueSuffix + ext); // e.g.: sikayet-16843...jpg
    }
});

const upload = multer({ storage: storage });

// The Gateway Handling Requests from Flutter (/api/v1/upload)
router.post('/upload', upload.single('image'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: 'Lütfen bir resim yükleyin.' });
    }

    // Determine whether the server is running on localhost or on the production server.
    const protocol = req.protocol;
    const host = req.get('host');
    
    // The full URL that the app will save to its database 
    const imageUrl = `${protocol}://${host}/uploads/${req.file.filename}`;

    console.log(`📸 Yeni resim yüklendi: ${imageUrl}`);

    // Return a successful response. Flutter will take this imageUrl and send it along with the location when creating a report.
    res.status(200).json({
        message: 'Resim başarıyla yüklendi',
        imageUrl: imageUrl
    });
});

export default router;