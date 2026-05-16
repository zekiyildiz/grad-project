import app from './app';
import { env } from './config/env';
import logger from './common/utils/logger';
import { initFirebase } from './config/firebase';

// Database connection: Set up Firebase before the server starts.
initFirebase();

//Retrieve the port from the environment variables (env); if it cannot be found, use 3000
const PORT = Number(env.PORT) || 3000;

//Thanks to 0.0.0.0, mobile phones (Flutter) connected to the same Wi-Fi network can access the server.
app.listen(PORT, '0.0.0.0', () => {
  logger.info(`Server is running on port ${PORT} (0.0.0.0)`);
});