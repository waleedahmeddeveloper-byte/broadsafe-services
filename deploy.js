const fs = require('fs');
const path = require('path');

console.log('🚀 Starting deployment...\n');

// Backup directory
const backupDir = 'backup_' + new Date().toISOString().replace(/[:.]/g, '-');
fs.mkdirSync(backupDir, { recursive: true });

// Files to deploy
const filesToDeploy = [
    'index.html',
    'about.html',
    'contact.html',
    'apply-online.html'
];

// Service files
const serviceFiles = [
    'services/index.html',
    'services/alarmresponses.html',
    'services/cashintransit.html',
    'services/commercialsitesecurity.html',
    'services/constructionsitesecurity.html',
    'services/corporatesecurity.html',
    'services/eventsecurity.html',
    'services/manufacturingwarehousingsecurity.html',
    'services/mobilepatrols.html',
    'services/staticguarding.html'
];

const allFiles = [...filesToDeploy, ...serviceFiles];

// Deployment function
function deployFile(file) {
    try {
        const distPath = path.join('dist', file);
        const targetPath = file;
        const backupPath = path.join(backupDir, file);
        
        // Check if dist file exists
        if (!fs.existsSync(distPath)) {
            console.log(`⚠️  Skipping ${file} (not found in dist)`);
            return false;
        }
        
        // Backup original if it exists
        if (fs.existsSync(targetPath)) {
            const backupFileDir = path.dirname(backupPath);
            if (!fs.existsSync(backupFileDir)) {
                fs.mkdirSync(backupFileDir, { recursive: true });
            }
            fs.copyFileSync(targetPath, backupPath);
        }
        
        // Deploy new file
        const targetDir = path.dirname(targetPath);
        if (!fs.existsSync(targetDir)) {
            fs.mkdirSync(targetDir, { recursive: true });
        }
        fs.copyFileSync(distPath, targetPath);
        
        // Get file sizes
        const newSize = fs.statSync(targetPath).size;
        const oldSize = fs.existsSync(backupPath) ? fs.statSync(backupPath).size : 0;
        const reduction = oldSize > 0 ? ((oldSize - newSize) / oldSize * 100).toFixed(1) : 0;
        
        console.log(`✅ Deployed: ${file} (${(newSize/1024).toFixed(1)} KB, ${reduction}% reduction)`);
        return true;
    } catch (error) {
        console.error(`❌ Error deploying ${file}:`, error.message);
        return false;
    }
}

// Deploy all files
let successCount = 0;
let failCount = 0;

allFiles.forEach(file => {
    if (deployFile(file)) {
        successCount++;
    } else {
        failCount++;
    }
});

console.log(`\n📊 Deployment Summary:`);
console.log(`   ✅ Successful: ${successCount}`);
console.log(`   ❌ Failed: ${failCount}`);
console.log(`   💾 Backup location: ${backupDir}`);
console.log(`\n✨ Deployment complete!`);
