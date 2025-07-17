const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const Guitar = require('../models/Guitar');

dotenv.config({ path: path.join(__dirname, '../config/config.env') });

async function main() {
  await mongoose.connect(process.env.LOCAL_DATABASE_URI);
  const guitars = await Guitar.find();
  for (const guitar of guitars) {
    if (guitar.images && guitar.images.length > 0) {
      const imageFile = guitar.images[0];
      const imagePath = path.join(__dirname, '../public/uploads/', imageFile);
      if (fs.existsSync(imagePath)) {
        const imageData = fs.readFileSync(imagePath);
        guitar.imageData = imageData;
        await guitar.save();
        console.log(`Updated guitar ${guitar._id} with image data from ${imageFile}`);
      } else {
        console.warn(`Image file not found for guitar ${guitar._id}: ${imageFile}`);
      }
    } else {
      console.warn(`No images array for guitar ${guitar._id}`);
    }
  }
  await mongoose.disconnect();
  console.log('Done updating guitars with image data.');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
}); 