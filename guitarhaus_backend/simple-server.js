const express = require('express');
const path = require('path');
const cors = require('cors');
const app = express();

// Enable CORS
app.use(cors());

// Serve static files from public/uploads
app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));

// Test endpoint
app.get('/test', (req, res) => {
  res.json({ message: 'Server is running!' });
});

// List images endpoint
app.get('/images', (req, res) => {
  const fs = require('fs');
  const uploadsDir = path.join(__dirname, 'public/uploads');
  try {
    const files = fs.readdirSync(uploadsDir);
    res.json({ 
      success: true, 
      files: files,
      uploadsPath: uploadsDir
    });
  } catch (error) {
    res.json({ 
      success: false, 
      error: error.message
    });
  }
});

const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Simple test server running on port ${PORT}`);
  console.log(`Test URL: http://localhost:${PORT}/test`);
  console.log(`Images URL: http://localhost:${PORT}/images`);
  console.log(`Image example: http://localhost:${PORT}/uploads/IMG-1752931327664.jpg`);
}); 