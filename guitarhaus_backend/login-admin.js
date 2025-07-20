const http = require('http');

const postData = JSON.stringify({
  email: 'admin@guitarhaus.com',
  password: 'admin123'
});

const options = {
  hostname: '127.0.0.1',
  port: 3000,
  path: '/api/v1/customers/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
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
    try {
      const response = JSON.parse(data);
      if (response.token) {
        console.log('\n✅ Admin token obtained:');
        console.log('Token:', response.token);
        console.log('\nUse this token in your web admin panel!');
      }
    } catch (error) {
      console.log('Could not parse response');
    }
  });
});

req.on('error', (e) => {
  console.error(`Problem with request: ${e.message}`);
});

req.write(postData);
req.end(); 