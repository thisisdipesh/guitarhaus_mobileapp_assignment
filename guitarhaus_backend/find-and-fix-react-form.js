const fs = require('fs');
const path = require('path');

console.log('🔍 Finding your React form to fix the image upload issue...\n');

// Common locations where React forms might be
const possibleLocations = [
    '../src/components/AddGuitar.jsx',
    '../src/components/AddGuitarForm.jsx',
    '../src/components/GuitarForm.jsx',
    '../src/pages/AddGuitar.jsx',
    '../src/pages/admin/AddGuitar.jsx',
    '../src/views/AddGuitar.jsx',
    '../src/views/admin/AddGuitar.jsx',
    '../components/AddGuitar.jsx',
    '../components/GuitarForm.jsx',
    '../pages/AddGuitar.jsx',
    '../pages/admin/AddGuitar.jsx',
    './src/components/AddGuitar.jsx',
    './src/pages/AddGuitar.jsx',
    './components/AddGuitar.jsx',
    './pages/AddGuitar.jsx'
];

console.log('📋 Looking for React form files in common locations...\n');

let foundFiles = [];

// Check each possible location
possibleLocations.forEach(location => {
    try {
        if (fs.existsSync(location)) {
            foundFiles.push(location);
            console.log(`✅ Found: ${location}`);
        }
    } catch (error) {
        // File doesn't exist, continue
    }
});

if (foundFiles.length === 0) {
    console.log('❌ No React form files found in common locations.');
    console.log('\n🔧 Manual Instructions:');
    console.log('1. Find your React project folder (where your admin panel is running)');
    console.log('2. Look for files like: AddGuitar.jsx, GuitarForm.jsx, or similar');
    console.log('3. Open the file and look for the image upload code');
    console.log('4. Change the field name to "image"');
} else {
    console.log(`\n✅ Found ${foundFiles.length} potential React form file(s):`);
    foundFiles.forEach(file => {
        console.log(`   - ${file}`);
    });
    
    console.log('\n🔧 To fix your React form:');
    console.log('1. Open each file above');
    console.log('2. Look for FormData.append() calls');
    console.log('3. Change any field name to "image"');
    console.log('4. Make sure file input has name="image"');
}

console.log('\n📝 Exact Code Changes Needed:');
console.log('\n❌ Find this (causing error):');
console.log('   formData.append("file", imageFile);');
console.log('   formData.append("guitarImage", imageFile);');
console.log('   formData.append("photo", imageFile);');

console.log('\n✅ Change to this (will fix error):');
console.log('   formData.append("image", imageFile);');

console.log('\n📋 Also check your file input:');
console.log('❌ Wrong: <input name="file" ... />');
console.log('✅ Correct: <input name="image" ... />');

console.log('\n🎯 Quick Test:');
console.log('1. Open: guitarhaus_backend/fix-react-form.html');
console.log('2. Test the form - it should work perfectly');
console.log('3. Apply the same fix to your React form');

console.log('\n🔑 Admin Token (use this in your React form):');
console.log('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4N2JlNWU5NjRjNmRmMzFiYWI1ZjUwYyIsImlhdCI6MTc1Mjk1MTIwMiwiZXhwIjoxNzU1NTQzMjAyfQ.hcUlJ6DIgbBHogMs1ks2W0wu8-XWmOXjEoNFeRygntE');

console.log('\n🚀 After fixing, your React form should work perfectly!'); 