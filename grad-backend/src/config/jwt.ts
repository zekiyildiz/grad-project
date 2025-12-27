import jwt from 'jsonwebtoken';

// JWT Secret - In production, use environment variable
const JWT_SECRET = process.env.JWT_SECRET || 'akilli-belediye-secret-key-2024';
const JWT_EXPIRES_IN = '7d'; // Token expires in 7 days

interface TokenPayload {
    uid: string;
    email: string;
}

/**
 * Generate a JWT token for authenticated user
 */
export function generateToken(uid: string, email: string): string {
    const payload: TokenPayload = { uid, email };
    return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

/**
 * Verify and decode a JWT token
 * Returns the decoded payload or throws an error
 */
export function verifyToken(token: string): TokenPayload {
    try {
        const decoded = jwt.verify(token, JWT_SECRET) as TokenPayload;
        return decoded;
    } catch (error) {
        throw new Error('Invalid or expired token');
    }
}
