import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
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

app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date() });
});

setupSwagger(app);
setupSecurity(app);

app.use('/api/v1', routes);

app.use(errorHandler);

export default app;
