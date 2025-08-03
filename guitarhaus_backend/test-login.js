const axios = require('axios');

async function testLogin() {
    try {
        console.log('Testing login endpoint...');
        
        const response = await axios.post('http://127.0.0.1:3003/api/v1/customers/login', {
            email: 'admin@guitarhaus.com',
            password: 'admin123'
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        console.log('✅ Login successful!');
        console.log('Response:', response.data);
        
    } catch (error) {
        console.log('❌ Login failed!');
        if (error.response) {
            console.log('Status:', error.response.status);
            console.log('Data:', error.response.data);
        } else {
            console.log('Error:', error.message);
        }
    }
}

async function testServerHealth() {
    try {
        console.log('Testing server health...');
        
        const response = await axios.get('http://127.0.0.1:3003/test');
        
        console.log('✅ Server is healthy!');
        console.log('Response:', response.data);
        
    } catch (error) {
        console.log('❌ Server health check failed!');
        console.log('Error:', error.message);
    }
}

// Run tests
async function runTests() {
    console.log('Starting tests...\n');
    
    await testServerHealth();
    console.log('');
    
    await testLogin();
}

runTests(); 