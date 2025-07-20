const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const Guitar = require('./models/Guitar');

dotenv.config({ path: path.join(__dirname, './config/config.env') });

async function main() {
  await mongoose.connect(process.env.LOCAL_DATABASE_URI);
  
  console.log('=== FIXING MISSING IMAGES ===');
  const guitars = await Guitar.find();
  
  for (const guitar of guitars) {
    if (guitar.images && guitar.images.length > 0) {
      const validImages = [];
      
      for (const imageFile of guitar.images) {
        const imagePath = path.join(__dirname, './public/uploads/', imageFile);
        const exists = fs.existsSync(imagePath);
        const stats = exists ? fs.statSync(imagePath) : null;
        
        if (exists && stats.size > 1000) {
          // File exists and is not corrupted (more than 1KB)
          validImages.push(imageFile);
          console.log(`✅ Keeping valid image: ${imageFile} (${stats.size} bytes)`);
        } else {
          console.log(`❌ Removing invalid image: ${imageFile} (${exists ? stats.size + ' bytes' : 'missing'})`);
        }
      }
      
      // Update the guitar with only valid images
      if (validImages.length !== guitar.images.length) {
        guitar.images = validImages;
        await guitar.save();
        console.log(`Updated guitar "${guitar.name}" - kept ${validImages.length} valid images`);
      }
    }
  }
  
  await mongoose.disconnect();
  console.log('\nDone fixing missing images.');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
}); 