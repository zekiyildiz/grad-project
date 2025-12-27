import { z } from 'zod';

// Register DTO
export const registerSchema = z.object({
    email: z.string().email('Invalid email format'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
    name: z.string().min(1, 'Name is required'),
    fullName: z.string().optional(), // Optional, will default to name if not provided
    phone: z.string().optional(),
    address: z.string().optional(),
    district: z.string().optional(), // İlçe
    neighborhood: z.string().optional(), // Mahalle
    displayName: z.string().optional(),
});

export type RegisterDto = z.infer<typeof registerSchema>;

// Login DTO
export const loginSchema = z.object({
    email: z.string().email('Invalid email format'),
    password: z.string().min(1, 'Password is required'),
});

export type LoginDto = z.infer<typeof loginSchema>;

// Forgot Password DTO
export const forgotPasswordSchema = z.object({
    email: z.string().email('Invalid email format'),
});

export type ForgotPasswordDto = z.infer<typeof forgotPasswordSchema>;

// Verify Token DTO (for the existing token-based login)
export const verifyTokenSchema = z.object({
    token: z.string().min(1, 'Token is required'),
});

export type VerifyTokenDto = z.infer<typeof verifyTokenSchema>;
