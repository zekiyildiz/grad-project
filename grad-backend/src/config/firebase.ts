import * as admin from 'firebase-admin';

const serviceAccount = require('./serviceAccountKey.json');

export const initFirebase = () => {
    if (admin.apps.length === 0) {
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log('Firebase Admin Initialized');
    }
};

export const getAuth = () => admin.auth();
export const getFirestore = () => admin.firestore();
