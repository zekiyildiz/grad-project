import { z } from 'zod';

// Update Profile DTO
export const updateProfileSchema = z.object({
    fullName: z.string().min(1, 'Full name is required').optional(),
    phone: z.string().min(10, 'Phone number must be at least 10 characters').optional(),
    address: z.string().min(1, 'Address is required').optional(),
    displayName: z.string().optional(),
    photoURL: z.string().url('Invalid URL').optional(),
});

export type UpdateProfileDto = z.infer<typeof updateProfileSchema>;
