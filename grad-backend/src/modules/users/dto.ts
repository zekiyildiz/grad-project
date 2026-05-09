import { z } from 'zod';

// Update Profile DTO
export const updateProfileSchema = z.object({
    // The name cannot be empty, it is optional but must be at least 1 character long if provided.
    fullName: z.string().min(1, 'Full name is required').optional(),
    // If a phone number is entered, it must be at least 10 characters long.
    phone: z.string().min(10, 'Phone number must be at least 10 characters').optional(),
    address: z.string().min(1, 'Address is required').optional(),
    displayName: z.string().optional(),
    photoURL: z.string().url('Invalid URL').optional(), // If a photo link is provided, check to see if it is in a valid URL format.
});

// Export so that TypeScript can recognize these rules as types
export type UpdateProfileDto = z.infer<typeof updateProfileSchema>;