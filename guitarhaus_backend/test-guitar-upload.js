const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

// Create a test image file
const testImagePath = path.join(__dirname, 'test-guitar-image.jpg');
const testImageData = Buffer.from('fake guitar image data for testing');

// Write test image
fs.writeFileSync(testImagePath, testImageData);

console.log('Testing guitar upload API...');

// Create form data
const form = new FormData();
form.append('name', 'Test Guitar');
form.append('brand', 'Test Brand');
form.append('category', 'Electric');
form.append('description', 'Test guitar description');
form.append('price', '1000');
form.append('stock', '10');
form.append('specifications', JSON.stringify({
  color: 'Red',
  material: 'Wood',
  strings: '6'
}));
form.append('image', fs.createReadStream(testImagePath));

console.log('Sending request to: http://127.0.0.1:3000/api/v1/guitars');
console.log('Form data created with image file');

// Make the request
const http = require('http');
const options = {
  hostname: '127.0.0.1',
  port: 3000,
  path: '/api/v1/guitars',
  method: 'POST',
  headers: {
    ...form.getHeaders(),
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4N2JlNWU5NjRjNmRmMzFiYWI1ZjUwYyIsImlhdCI6MTc1Mjk1MDU3MCwiZXhwIjoxNzU1NTQyNTcwfQ.Yk9o-NPfLSIJmH7GrRQPmgp5DhxlngA17L11uXhkfiE'
  }
};

const req = http.request(options, (res) => {
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
  // Clean up test file
  if (fs.existsSync(testImagePath)) {
    fs.unlinkSync(testImagePath);
  }
});

form.pipe(req); 