import app from './app';
import { env } from './config/env';
import logger from './common/utils/logger';
import { initFirebase } from './config/firebase';

initFirebase();

const PORT = env.PORT || 3000;

app.listen(PORT, () => {
  logger.info(`Server is running on port ${PORT}`);
});
