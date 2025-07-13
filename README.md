# 🎸 GuitarHaus - High Quality Guitar Store

A complete e-commerce solution for selling high-quality guitars, featuring a Flutter mobile app with a Node.js backend API.

## 📱 Project Overview

GuitarHaus is a comprehensive guitar store application with:

- **Flutter Mobile App**: Clean architecture with BLoC pattern, modern UI/UX
- **Node.js Backend**: RESTful API with MongoDB database
- **Full E-commerce Features**: Authentication, Product catalog, Shopping cart, Orders, Wishlist, Reviews

## 🏗️ Architecture

### Frontend (Flutter)
- **Clean Architecture**: Feature-based organization with proper separation of concerns
- **State Management**: BLoC pattern for reactive state management
- **Dependency Injection**: GetIt service locator for dependency management
- **Network Layer**: Dio for HTTP requests with interceptors
- **Local Storage**: Hive for data persistence, SharedPreferences for settings

### Backend (Node.js)
- **Express.js**: RESTful API framework
- **MongoDB**: NoSQL database with Mongoose ODM
- **JWT Authentication**: Secure token-based authentication
- **Role-based Access**: Admin and Customer roles
- **File Upload**: Multer for image uploads
- **Security**: Helmet, XSS protection, CORS, MongoDB sanitization

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.7.2+)
- Node.js (16+)
- MongoDB (4.4+)
- Git

### Backend Setup
```bash
# Navigate to backend
cd guitarhaus_backend

# Install dependencies
npm install

# Create environment file
cp config/config.env.example config/config.env
# Edit config/config.env with your settings

# Start MongoDB
# Windows: Start MongoDB service
# Mac: brew services start mongodb-community
# Linux: sudo systemctl start mongod

# Import sample data
npm run data:import

# Start development server
npm run dev
```

### Frontend Setup
```bash
# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

## 📊 Features

### 🔐 Authentication
- User registration and login
- JWT token management
- Role-based access control (Admin/Customer)
- Secure password hashing with bcrypt

### 🎸 Guitar Catalog
- Browse guitars by category (Electric, Acoustic, Bass, Classical, Ukulele)
- Search and filtering capabilities
- Detailed guitar specifications
- Product images and ratings
- Featured products showcase

### 🛒 Shopping Features
- Add/remove items from cart
- Update quantities
- Wishlist functionality
- Order management
- Real-time stock tracking

### 👤 User Profile
- View and edit profile information
- Order history
- Review management
- Secure logout

### ⭐ Reviews & Ratings
- Customer reviews for guitars
- Rating system
- Review management

## 🛠️ API Endpoints

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
- `DELETE /api/v1/cart/clear` - Clear cart

### Orders
- `POST /api/v1/orders` - Create new order
- `GET /api/v1/orders` - Get user's orders
- `GET /api/v1/orders/:id` - Get single order
- `PUT /api/v1/orders/:id/cancel` - Cancel order

### Wishlist
- `GET /api/v1/wishlist` - Get user's wishlist
- `POST /api/v1/wishlist/add` - Add to wishlist
- `DELETE /api/v1/wishlist/remove/:guitarId` - Remove from wishlist
- `GET /api/v1/wishlist/check/:guitarId` - Check if in wishlist
- `DELETE /api/v1/wishlist/clear` - Clear wishlist

### Reviews
- `GET /api/v1/reviews/guitar/:guitarId` - Get guitar reviews
- `POST /api/v1/reviews/guitar/:guitarId` - Add review
- `PUT /api/v1/reviews/:id` - Update review
- `DELETE /api/v1/reviews/:id` - Delete review

## 📱 App Screenshots

### Authentication
- Splash screen with GuitarHaus branding
- Login screen with email/password validation
- Signup screen with form validation
- Google OAuth integration (UI ready)

### Dashboard
- Featured guitars showcase
- Category browsing
- Search functionality
- Bottom navigation

### Shopping
- Cart with quantity management
- Wishlist with add/remove functionality
- Product details with specifications
- Checkout process

### Profile
- User information display
- Order history
- Settings and preferences
- Logout functionality

## 🔧 Development

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

## 📊 Database Models

### Backend Models
- **Customer**: User management with roles
- **Guitar**: Product information with specifications
- **Cart**: Shopping cart functionality
- **Order**: Order management with status tracking
- **Wishlist**: User favorites
- **Review**: Customer reviews and ratings

### Frontend Models
- **User Entity**: User data models
- **Guitar Entity**: Product data models
- **Cart Entity**: Shopping cart models
- **Order Entity**: Order data models

## 🔒 Security Features

- JWT Authentication with configurable expiration
- Role-based Access Control (Admin/Customer)
- Password encryption with bcrypt
- Input sanitization and XSS protection
- CORS configuration for cross-origin requests
- File upload security with size limits
- MongoDB injection protection

## 🎯 Sample Data

The backend includes sample data:
- **6 Sample Guitars**: Fender, Gibson, Martin, Yamaha, Kala brands
- **Admin User**: admin@guitarhaus.com / admin123
- **Categories**: Electric, Acoustic, Bass, Classical, Ukulele
- **Realistic Pricing**: $59.99 - $3,299.99 range

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

## 📝 Environment Variables

### Backend (.env)
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

### Frontend Configuration
- Update `lib/core/network/api_service.dart` for different environments
- Android emulator: `http://10.0.2.2:3000/api/v1`
- iOS simulator: `http://localhost:3000/api/v1`
- Production: Your production API URL

## 🎯 Next Steps

1. **Payment Integration**: Add payment gateways (Stripe, PayPal)
2. **Push Notifications**: Order updates and promotions
3. **Analytics**: User behavior tracking
4. **Testing**: Unit and integration tests
5. **Real Images**: Replace placeholder images with actual guitar photos
6. **Advanced Features**: Guitar comparison, recommendations
7. **Admin Panel**: Web-based admin interface

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review API documentation
3. Check console logs for errors
4. Verify all prerequisites are installed

---

**Happy Coding! 🎸**

*GuitarHaus - Where Quality Meets Music*
