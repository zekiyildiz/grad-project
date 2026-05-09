import { getAuth, getFirestore } from '../../config/firebase';
import { generateToken } from '../../config/jwt';
import { RegisterDto, LoginDto, ForgotPasswordDto } from './dto';

export class AuthService {
    /**
     * Register a new user with email and password
     */
    async register(data: RegisterDto) {
        try {
            console.log('[AuthService] Register attempt for:', data.email);

            // Create user in Firebase Auth
            const userRecord = await getAuth().createUser({
                email: data.email,
                password: data.password,
                displayName: data.displayName || '',
            });

            console.log('[AuthService] User created in Firebase Auth:', userRecord.uid);

            // Create user document in Firestore
            const fullName = data.fullName || data.name;

            // Format phone number: add +90 prefix if phone is provided
            let formattedPhone = '';
            if (data.phone) {
                // Remove spaces and any existing +90
                const cleanPhone = data.phone.replace(/\s/g, '').replace(/^\+90/, '');
                formattedPhone = `+90${cleanPhone}`;
            }

            const userData = {
                uid: userRecord.uid,
                email: userRecord.email,
                name: data.name,
                fullName: fullName,
                phone: formattedPhone,
                address: data.address || '',
                district: data.district || '',
                neighborhood: data.neighborhood || '',
                displayName: data.displayName || fullName,
                photoURL: '',
                role: 'user',
                roleId: 1, // Default roleId: 0=admin, 1=user, 2=employee
                createdAt: new Date(),
                updatedAt: new Date(),
            };

            await getFirestore().collection('users').doc(userRecord.uid).set(userData);
            console.log('[AuthService] User document created in Firestore');

            // Generate JWT token for immediate login
            const token = generateToken(userRecord.uid, data.email);
            console.log('[AuthService] JWT token generated');

            return {
                user: userData,
                token,
                message: 'User registered successfully',
            };
        } catch (error: any) {
            console.error('[AuthService] Register error:', error);
            if (error.code === 'auth/email-already-exists') {
                const err = new Error('Bu e-posta adresi zaten kullanılıyor');
                (err as any).statusCode = 409;
                throw err;
            }
            if (error.code === 'auth/invalid-email') {
                const err = new Error('Geçersiz e-posta formatı');
                (err as any).statusCode = 400;
                throw err;
            }
            if (error.code === 'auth/weak-password') {
                const err = new Error('Şifre en az 6 karakter olmalıdır');
                (err as any).statusCode = 400;
                throw err;
            }
            throw error;
        }
    }

    /**
     * Login with email and password
     * Uses Firebase REST API to verify password since Admin SDK cannot verify passwords
     */
    async loginWithEmail(data: LoginDto) {
        // Firebase Web API Key
        const FIREBASE_API_KEY = 'AIzaSyCEveyR9O7mq-7ezSym_lLMwJgyWgCknzw';

        try {
            // Step 0: First check if user exists using Admin SDK
            // This allows us to give specific error for non-existent email
            try {
                await getAuth().getUserByEmail(data.email);
            } catch (userError: any) {
                if (userError.code === 'auth/user-not-found') {
                    const err = new Error('Bu e-posta adresiyle kayıtlı bir hesap bulunamadı');
                    (err as any).statusCode = 404;
                    throw err;
                }
                if (userError.code === 'auth/invalid-email') {
                    const err = new Error('Geçersiz e-posta formatı');
                    (err as any).statusCode = 400;
                    throw err;
                }
                throw userError;
            }

            // Step 1: Verify password using Firebase REST API
            const verifyResponse = await fetch(
                `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`,
                {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        email: data.email,
                        password: data.password,
                        returnSecureToken: true,
                    }),
                }
            );

            const verifyResult = await verifyResponse.json();

            if (!verifyResponse.ok) {
                console.error('[AuthService] Firebase verify error:', verifyResult);
                // At this point we know user exists, so any error is password related
                const errorCode = verifyResult?.error?.message;
                if (errorCode === 'USER_DISABLED') {
                    const err = new Error('Bu hesap devre dışı bırakılmış');
                    (err as any).statusCode = 403;
                    throw err;
                }
                // Any other error (INVALID_PASSWORD, INVALID_LOGIN_CREDENTIALS, etc.) means wrong password
                const err = new Error('Şifre hatalı. Lütfen tekrar deneyin.');
                (err as any).statusCode = 401;
                throw err;
            }

            // Step 2: Get user data from Firestore
            const uid = verifyResult.localId;
            let userData;

            try {
                const userDoc = await getFirestore().collection('users').doc(uid).get();
                if (userDoc.exists) {
                    userData = userDoc.data();
                    // Update last login
                    await getFirestore().collection('users').doc(uid).update({
                        updatedAt: new Date(),
                    });
                } else {
                    // User not in Firestore, create basic data
                    userData = {
                        uid: uid,
                        email: data.email,
                        displayName: verifyResult.displayName || '',
                        photoURL: '',
                        role: 'user',
                        roleId: 1, // Default roleId for users not in Firestore
                    };
                }
            } catch (firestoreError) {
                console.warn('[AuthService] Firestore not available, using basic data');
                userData = {
                    uid: uid,
                    email: data.email,
                    displayName: verifyResult.displayName || '',
                    photoURL: '',
                    role: 'user',
                    roleId: 1, // Default roleId
                };
            }

            // Step 3: Generate JWT token
            const token = generateToken(uid, data.email);

            return {
                user: userData,
                token,
                message: 'Login successful',
            };
        } catch (error: any) {
            console.error('[AuthService] Login error:', error);
            // Re-throw if already processed
            if (error.statusCode) {
                throw error;
            }
            // Generic error
            const err = new Error('Giriş yapılırken bir hata oluştu');
            (err as any).statusCode = 500;
            throw err;
        }
    }

    /**
     * Send password reset email
     */
    async forgotPassword(data: ForgotPasswordDto) {
        try {
            // Verify user exists
            await getAuth().getUserByEmail(data.email);

            // Generate password reset link
            const resetLink = await getAuth().generatePasswordResetLink(data.email);

            // TODO: Send email with resetLink using your email service
            // For now, we'll return the link (in production, send via email)

            return {
                message: 'Password reset link sent to your email',
                resetLink, // Remove this in production
            };
        } catch (error: any) {
            if (error.code === 'auth/user-not-found') {
                // Don't reveal if user exists or not for security
                return {
                    message: 'If the email exists, a password reset link has been sent',
                };
            }
            throw error;
        }
    }

    /**
     * Verify Firebase ID Token (existing method)
     */
    async login(token: string) {
        try {
            const decodedToken = await getAuth().verifyIdToken(token);
            const { uid, email, name, picture } = decodedToken;

            const userRef = getFirestore().collection('users').doc(uid);
            const userDoc = await userRef.get();

            let userData;

            if (!userDoc.exists) {
                // Register new user
                userData = {
                    uid,
                    email,
                    displayName: name || '',
                    photoURL: picture || '',
                    role: 'user', // default role
                    roleId: 1, // default roleId: 0=admin, 1=user, 2=employee
                    createdAt: new Date(),
                    updatedAt: new Date()
                };
                await userRef.set(userData);
            } else {
                // Update existing user last login or details
                userData = userDoc.data();
                await userRef.update({
                    updatedAt: new Date()
                });
            }

            return {
                user: userData,
                token // echo back the token or generate a session token if needed
            };
        } catch (error) {
            throw error;
        }
    }
}

export const authService = new AuthService();