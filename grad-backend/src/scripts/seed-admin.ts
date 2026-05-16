/**
 * Seed script for creating admin user and updating existing users with roleId
 * Run: npx ts-node src/scripts/seed-admin.ts
 */

import { initFirebase, getAuth, getFirestore } from '../config/firebase';

// Initialize Firebase first
initFirebase();

//When this script runs, it checks Firebase Authentication. If there is no user named “admin@test.com” in the system, it creates a system administrator with a password set to “string”.
async function seedAdmin() {
    console.log('🚀 Starting admin seed...');

    const ADMIN_EMAIL = 'admin@test.com';
    const ADMIN_PASSWORD = 'string';

    try {
        // 1. Check if admin already exists
        let adminUid: string;
        try {
            const existingAdmin = await getAuth().getUserByEmail(ADMIN_EMAIL);
            adminUid = existingAdmin.uid;
            console.log('⚠️  Admin user already exists:', adminUid);
        } catch (error: any) {
            if (error.code === 'auth/user-not-found') {
                // Create admin user in Firebase Auth
                const adminUser = await getAuth().createUser({
                    email: ADMIN_EMAIL,
                    password: ADMIN_PASSWORD,
                    displayName: 'Admin',
                });
                adminUid = adminUser.uid;
                console.log('✅ Admin user created in Firebase Auth:', adminUid);
            } else {
                throw error;
            }
        }

        // 2. Create/Update admin document in Firestore
        const adminData = {
            uid: adminUid,
            email: ADMIN_EMAIL,
            name: 'Admin',
            fullName: 'System Administrator',
            phone: '',
            address: '',
            district: '',
            neighborhood: '',
            displayName: 'Admin',
            photoURL: '',
            role: 'admin',
            roleId: 0, // Admin roleId
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        await getFirestore().collection('users').doc(adminUid).set(adminData, { merge: true });
        console.log('✅ Admin document created/updated in Firestore');

        // 3. Update all existing users to have roleId: 1 (if not already set)
        console.log('\n📊 Updating existing users with roleId: 1...');
        const usersSnapshot = await getFirestore().collection('users').get();

        let updatedCount = 0;
        for (const doc of usersSnapshot.docs) {
            const userData = doc.data();
            // Skip admin user and users who already have roleId
            if (userData.roleId === 0) {
                console.log(`  ⏭️  Skipping admin: ${userData.email}`);
                continue;
            }

            if (userData.roleId === undefined || userData.roleId === null) {
                await getFirestore().collection('users').doc(doc.id).update({
                    roleId: 1, // Normal user
                });
                updatedCount++;
                console.log(`  ✅ Updated: ${userData.email} -> roleId: 1`);
            } else {
                console.log(`  ⏭️  Already has roleId: ${userData.email} (${userData.roleId})`);
            }
        }

        console.log(`\n🎉 Seed complete!`);
        console.log(`   - Admin user: ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}`);
        console.log(`   - Updated ${updatedCount} users with roleId: 1`);

    } catch (error) {
        console.error('❌ Seed failed:', error);
        process.exit(1);
    }
}

// Run the seed
seedAdmin().then(() => {
    console.log('\n💤 Exiting...');
    process.exit(0);
});