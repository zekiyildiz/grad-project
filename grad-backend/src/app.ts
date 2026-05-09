import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path'; 
import { setupSecurity } from './config/security';
import { setupSwagger } from './config/swagger';
import { errorHandler } from './common/http/error-handler';
import routes from './index';

const app = express();

app.use(helmet({
    contentSecurityPolicy: false, // Required for Swagger UI
}));
app.use(cors()); // CORS: Allows API requests from other domains or devices.
app.use(express.json()); // Parses the incoming JSON data (Flutter req.body) to read it

// We export the uploads folder so Flutter can see the images
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

// A simple ping route to check if the server is down or up
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date() });
});

setupSwagger(app);
setupSecurity(app);

app.use('/api/v1', routes);

app.use(errorHandler); // No matter where an error occurs in the system (throw error), this layer catches the error to prevent the server from crashing

export default app;