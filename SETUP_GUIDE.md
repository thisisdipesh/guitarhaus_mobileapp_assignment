# GuitarHaus Project Setup Guide

This guide will help you set up and run the GuitarHaus mobile app with its backend API.

## 🎸 Project Overview

GuitarHaus is a high-quality guitar store with:
- **Flutter Mobile App**: Clean architecture with BLoC pattern
- **Node.js Backend**: RESTful API with MongoDB
- **Features**: Authentication, Guitar catalog, Shopping cart, Orders, Wishlist, Reviews

## 📋 Prerequisites

- **Flutter SDK** (3.7.2 or higher)
- **Node.js** (16 or higher)
- **MongoDB** (4.4 or higher)
- **Git**

## 🚀 Quick Setup

### 1. Clone and Setup Backend

```bash
# Navigate to backend directory
cd guitarhaus_backend

# Install dependencies
npm install

# Create environment file
cp config/config.env.example config/config.env
# Edit config/config.env with your settings

# Start MongoDB (make sure MongoDB is running)
# On Windows: Start MongoDB service
# On Mac: brew services start mongodb-community
# On Linux: sudo systemctl start mongod

# Import sample data
npm run data:import

# Start the server
npm run dev
```

### 2. Setup Flutter App

```bash
# Navigate to project root
cd ..

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

## 🔧 Detailed Setup

### Backend Configuration

1. **Database Setup**
   ```bash
   # Start MongoDB
   mongod
   
   # Create database
   use guitarhaus_db
   ```

2. **Environment Variables** (`guitarhaus_backend/config/config.env`)
   ```env
   NODE_ENV=development
   PORT=3000
   LOCAL_DATABASE_URI=mongodb://127.0.0.1:27017/guitarhaus_db
   FILE_UPLOAD_PATH=./public/uploads
   MAX_FILE_UPLOAD=20000
   JWT_SECRET=your_secure_jwt_secret_here
   JWT_EXPIRE=30d
   JWT_COOKIE_EXPIRE=30
   ```

3. **Sample Data**
   ```bash
   # Import sample guitars and admin user
   npm run data:import
   
   # Admin credentials:
   # Email: admin@guitarhaus.com
   # Password: admin123
   ```

### Flutter App Configuration

1. **API Configuration**
   - Update `lib/core/network/api_service.dart` if needed
   - Default base URL: `http://localhost:3000/api/v1`
   - For Android emulator: `http://10.0.2.2:3000/api/v1`
   - For iOS simulator: `http://localhost:3000/api/v1`

2. **Authentication Setup**
   - The app uses JWT tokens for authentication
   - Tokens are stored in shared preferences
   - Auto-login functionality included

## 📱 App Features

### Authentication
- Login/Register with email and password
- Google OAuth (UI ready)
- JWT token management
- Role-based access (Admin/Customer)

### Guitar Catalog
- Browse guitars by category (Electric, Acoustic, Bass, Classical, Ukulele)
- Search functionality
- Filter by brand, price, availability
- Detailed guitar specifications
- Ratings and reviews

### Shopping Features
- Add guitars to cart
- Update quantities
- Remove items
- Wishlist functionality
- Order management

### User Profile
- View and edit profile
- Order history
- Review management

## 🛠️ Development

### Backend Development

```bash
# Start development server with auto-reload
npm run dev

# Run tests
npm test

# Import fresh data
npm run data:import

# Clear all data
npm run data:destroy
```

### Flutter Development

```bash
# Run in debug mode
flutter run

# Build for release
flutter build apk
flutter build ios

# Run tests
flutter test
```

## 📊 API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `GET /api/v1/auth/getCustomer/:id` - Get user profile
- `PUT /api/v1/auth/updateCustomer/:id` - Update profile

### Guitars
- `GET /api/v1/guitars` - Get all guitars (with filtering)
- `GET /api/v1/guitars/:id` - Get single guitar
- `GET /api/v1/guitars/featured` - Get featured guitars
- `GET /api/v1/guitars/category/:category` - Get by category
- `GET /api/v1/guitars/search` - Search guitars

### Cart
- `GET /api/v1/cart` - Get user's cart
- `POST /api/v1/cart/add` - Add to cart
- `PUT /api/v1/cart/update/:itemId` - Update quantity
- `DELETE /api/v1/cart/remove/:itemId` - Remove item

### Orders
- `POST /api/v1/orders` - Create order
- `GET /api/v1/orders` - Get user's orders
- `GET /api/v1/orders/:id` - Get single order

### Wishlist
- `GET /api/v1/wishlist` - Get wishlist
- `POST /api/v1/wishlist/add` - Add to wishlist
- `DELETE /api/v1/wishlist/remove/:guitarId` - Remove from wishlist

### Reviews
- `GET /api/v1/reviews/guitar/:guitarId` - Get guitar reviews
- `POST /api/v1/reviews/guitar/:guitarId` - Add review
- `PUT /api/v1/reviews/:id` - Update review

## 🔒 Security Features

- JWT Authentication
- Role-based Access Control
- Password encryption with bcrypt
- Input sanitization
- XSS protection
- CORS configuration
- File upload security

## 🐛 Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   ```bash
   # Check if MongoDB is running
   mongo --eval "db.runCommand('ping')"
   
   # Start MongoDB service
   sudo systemctl start mongod
   ```

2. **Port Already in Use**
   ```bash
   # Check what's using port 3000
   lsof -i :3000
   
   # Kill the process
   kill -9 <PID>
   ```

3. **Flutter Dependencies**
   ```bash
   # Clean and get dependencies
   flutter clean
   flutter pub get
   ```

4. **API Connection Issues**
   - Check if backend is running on port 3000
   - Verify API base URL in `api_service.dart`
   - Check network connectivity

### Debug Mode

```bash
# Backend debug
NODE_ENV=development npm run dev

# Flutter debug
flutter run --debug
```

## 📝 Sample Data

The seeder creates:
- 6 sample guitars (Fender, Gibson, Martin, etc.)
- Admin user (admin@guitarhaus.com / admin123)
- Various categories and specifications

## 🚀 Deployment

### Backend Deployment
1. Set `NODE_ENV=production`
2. Use environment variables for sensitive data
3. Set up MongoDB Atlas or production MongoDB
4. Use PM2 or similar for process management

### Flutter App Deployment
1. Update API base URL for production
2. Build release versions
3. Test thoroughly before deployment

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review API documentation
3. Check console logs for errors
4. Verify all prerequisites are installed

## 🎯 Next Steps

1. **Customize the UI**: Update colors, fonts, and layouts
2. **Add Real Images**: Replace placeholder images with actual guitar photos
3. **Implement Payment**: Integrate payment gateways
4. **Add Push Notifications**: For order updates and promotions
5. **Analytics**: Add user behavior tracking
6. **Testing**: Add unit and integration tests

---

**Happy Coding! 🎸** 