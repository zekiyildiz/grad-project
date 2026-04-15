import { getAuth, getFirestore } from '../../config/firebase';
import { UpdateProfileDto } from './dto';

export class UserService {
    
    /**
     * Get user profile with statistics
     */
    async getProfile(uid: string) {
        try {
            // Get user data from Firestore
            const userDoc = await getFirestore().collection('users').doc(uid).get();

            if (!userDoc.exists) {
                throw new Error('User not found');
            }

            const userData = userDoc.data();

            // Get user statistics from reports collection
            const reportsSnapshot = await getFirestore()
                .collection('reports')
                .where('userId', '==', uid)
                .get();

            const totalReports = reportsSnapshot.size;
            const resolvedReports = reportsSnapshot.docs.filter(
            doc => doc.data().status?.toUpperCase() === 'RESOLVED' || doc.data().status?.toUpperCase() === 'COMPLETED'
            ).length;

            // Get survey participation count
            const surveysSnapshot = await getFirestore()
                .collection('survey_responses')
                .where('userId', '==', uid)
                .get();

            const surveyCount = surveysSnapshot.size;

            return {
                user: userData,
                statistics: {
                    totalReports,
                    resolvedReports,
                    surveyCount,
                },
            };
        } catch (error) {
            throw error;
        }
    }

    /**
     * Update user profile
     */
    async updateProfile(uid: string, data: UpdateProfileDto) {
        try {
            const userRef = getFirestore().collection('users').doc(uid);
            const userDoc = await userRef.get();

            if (!userDoc.exists) {
                throw new Error('User not found');
            }

            // Update only provided fields
            const updateData: any = {
                updatedAt: new Date(),
            };

            if (data.fullName) updateData.fullName = data.fullName;
            if (data.phone) updateData.phone = data.phone;
            if (data.address) updateData.address = data.address;
            if (data.displayName) updateData.displayName = data.displayName;
            if (data.photoURL) updateData.photoURL = data.photoURL;

            await userRef.update(updateData);

            // Get updated user data
            const updatedDoc = await userRef.get();
            return updatedDoc.data();
        } catch (error) {
            throw error;
        }
    }
    
}


export const userService = new UserService();
