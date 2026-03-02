const fs = require('fs');
const path = require('path');

const resourcePath = GetResourcePath(GetCurrentResourceName());
const BACKUP_DIR = path.join(resourcePath, 'backups');

exports('DeleteBackup', (filename) => {
    const targetPath = path.join(BACKUP_DIR, filename);

    if (!targetPath.startsWith(BACKUP_DIR)) {
        console.error(`[Archiver] Unauthorized file access attempt: ${filename}`);
        return;
    }

    if (fs.existsSync(targetPath)) {
        try {
            fs.unlinkSync(targetPath);
            console.info(`[Archiver] Deleted backup: ${filename}`);
        } catch (err) {
            console.error(`[Archiver] Failed to delete ${filename}:`, err);
        }
    }
});
