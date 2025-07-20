const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

// Create a test image file
const testImagePath = path.join(__dirname, 'test-image.jpg');
const testImageData = Buffer.from('fake image data');

// Write test image
fs.writeFileSync(testImagePath, testImageData);

// Create form data
const form = new FormData();
form.append('image', fs.createReadStream(testImagePath));
form.append('name', 'Test Guitar');
form.append('brand', 'Test Brand');
form.append('category', 'Electric');
form.append('description', 'Test description');
form.append('price', '1000');
form.append('stock', '10');

// Make the request
const https = require('https');
const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/v1/guitars',
  method: 'POST',
  headers: {
    ...form.getHeaders(),
    'Authorization': 'Bearer YOUR_TOKEN_HERE' // You'll need to replace this with a valid admin token
  }
};

const req = https.request(options, (res) => {
  console.log(`Status: ${res.statusCode}`);
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    console.log('Response:', data);
    // Clean up test file
    fs.unlinkSync(testImagePath);
  });
});

req.on('error', (e) => {
  console.error(`Problem with request: ${e.message}`);
});

form.pipe(req); 