import { Express } from 'express';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';
import { env } from './env';

const options: swaggerJsdoc.Options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'Grad Backend API',
            version: '1.0.0',
            description: 'API Documentation for Graduation Project Backend',
        },
        servers: [
            {
                url: `http://localhost:${env.PORT}/api/v1`,
                description: 'Development Server',
            },
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                },
            },
        },
        security: [
            {
                bearerAuth: [],
            },
        ],
    },
    apis: ['./src/modules/**/*.ts', './src/common/http/response.ts'], // Path to the API docs
};

const specs = swaggerJsdoc(options);

export const setupSwagger = (app: Express) => {
    try {
        // Serve the Swagger JSON
        app.get('/api-docs.json', (req, res) => {
            res.setHeader('Content-Type', 'application/json');
            res.send(specs);
        });

        app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

        console.log(`[Swagger] Docs UI: http://localhost:${env.PORT || 3000}/api-docs`);
        console.log(`[Swagger] Specs JSON: http://localhost:${env.PORT || 3000}/api-docs.json`);
    } catch (error) {
        console.error('[Swagger] Error setting up swagger:', error);
    }
};
