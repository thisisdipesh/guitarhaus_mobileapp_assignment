const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const Guitar = require('./models/Guitar');

dotenv.config({ path: path.join(__dirname, './config/config.env') });

async function main() {
  await mongoose.connect(process.env.LOCAL_DATABASE_URI);
  
  console.log('=== CHECKING DATABASE IMAGES ===');
  const guitars = await Guitar.find();
  
  for (const guitar of guitars) {
    console.log(`\nGuitar: ${guitar.name} (${guitar._id})`);
    if (guitar.images && guitar.images.length > 0) {
      console.log(`  Images in DB: ${guitar.images.join(', ')}`);
      
      for (const imageFile of guitar.images) {
        const imagePath = path.join(__dirname, './public/uploads/', imageFile);
        const exists = fs.existsSync(imagePath);
        const stats = exists ? fs.statSync(imagePath) : null;
        console.log(`    ${imageFile}: ${exists ? 'EXISTS' : 'MISSING'} ${exists ? `(${stats.size} bytes)` : ''}`);
        
        if (exists && stats.size < 1000) {
          console.log(`    ⚠️  WARNING: File is very small (${stats.size} bytes), might be corrupted`);
        }
      }
    } else {
      console.log('  No images in database');
    }
  }
  
  console.log('\n=== CHECKING UPLOADS DIRECTORY ===');
  const uploadsDir = path.join(__dirname, './public/uploads');
  if (fs.existsSync(uploadsDir)) {
    const files = fs.readdirSync(uploadsDir);
    console.log(`Files in uploads directory (${files.length}):`);
    files.forEach(file => {
      const filePath = path.join(uploadsDir, file);
      const stats = fs.statSync(filePath);
      console.log(`  ${file}: ${stats.size} bytes`);
    });
  } else {
    console.log('Uploads directory does not exist!');
  }
  
  await mongoose.disconnect();
  console.log('\nDone checking images.');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
}); 