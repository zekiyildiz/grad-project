import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path'; // 🌟 YENİ EKLENDİ
import { setupSecurity } from './config/security';
import { setupSwagger } from './config/swagger';
import { errorHandler } from './common/http/error-handler';
import routes from './index';

const app = express();

app.use(helmet({
    contentSecurityPolicy: false, // Required for Swagger UI
}));
app.use(cors());
app.use(express.json());

// 🌟 YENİ EKLENDİ: Flutter'ın resimleri görebilmesi için uploads klasörünü dışa açıyoruz
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date() });
});

setupSwagger(app);
setupSecurity(app);

app.use('/api/v1', routes);

app.use(errorHandler);

export default app;