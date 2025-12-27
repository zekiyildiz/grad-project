import { z } from 'zod';

const envSchema = z.object({
    PORT: z.string().default('3001'),
    NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
    // Add other env variables here
});

export const env = envSchema.parse(process.env);
