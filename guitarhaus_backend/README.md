# GuitarHaus Backend API

Backend API for GuitarHaus - High Quality Guitar Store

## Features

- **Authentication & Authorization**: JWT-based authentication with role-based access control
- **Guitar Management**: CRUD operations for guitar products with categories and specifications
- **Shopping Cart**: Add, update, remove items from cart
- **Order Management**: Create, track, and manage orders
- **Wishlist**: Add/remove guitars to wishlist
- **Reviews & Ratings**: Customer reviews and rating system
- **File Upload**: Image upload for guitars and user profiles
- **Search & Filtering**: Advanced search and filtering capabilities

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT with bcrypt password hashing
- **File Upload**: Multer
- **Security**: Helmet, XSS protection, CORS, MongoDB sanitization

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/auth/getCustomer/:id` - Get user profile
- `PUT /api/v1/auth/updateCustomer/:id` - Update user profile

### Guitars
- `GET /api/v1/guitars` - Get all guitars (with filtering)
- `GET /api/v1/guitars/:id` - Get single guitar
- `GET /api/v1/guitars/featured` - Get featured guitars
- `GET /api/v1/guitars/category/:category` - Get guitars by category
- `GET /api/v1/guitars/search` - Search guitars
- `POST /api/v1/guitars` - Create guitar (Admin only)
- `PUT /api/v1/guitars/:id` - Update guitar (Admin only)
- `DELETE /api/v1/guitars/:id` - Delete guitar (Admin only)

### Cart
- `GET /api/v1/cart` - Get user's cart
- `POST /api/v1/cart/add` - Add item to cart
- `PUT /api/v1/cart/update/:itemId` - Update cart item quantity
- `DELETE /api/v1/cart/remove/:itemId` - Remove item from cart
- `DELETE /api/v1/cart/clear` - Clear cart

### Orders
- `POST /api/v1/orders` - Create new order
- `GET /api/v1/orders` - Get user's orders
- `GET /api/v1/orders/:id` - Get single order
- `PUT /api/v1/orders/:id/cancel` - Cancel order
- `GET /api/v1/orders/admin/all` - Get all orders (Admin only)
- `PUT /api/v1/orders/:id/status` - Update order status (Admin only)

### Wishlist
- `GET /api/v1/wishlist` - Get user's wishlist
- `POST /api/v1/wishlist/add` - Add guitar to wishlist
- `DELETE /api/v1/wishlist/remove/:guitarId` - Remove from wishlist
- `GET /api/v1/wishlist/check/:guitarId` - Check if guitar is in wishlist
- `DELETE /api/v1/wishlist/clear` - Clear wishlist

### Reviews
- `GET /api/v1/reviews/guitar/:guitarId` - Get reviews for guitar
- `POST /api/v1/reviews/guitar/:guitarId` - Add review
- `PUT /api/v1/reviews/:id` - Update review
- `DELETE /api/v1/reviews/:id` - Delete review
- `GET /api/v1/reviews/user` - Get user's reviews

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file in `config/` directory:
```env
NODE_ENV=development
PORT=3000
LOCAL_DATABASE_URI=mongodb://127.0.0.1:27017/guitarhaus_db
FILE_UPLOAD_PATH=./public/uploads
MAX_FILE_UPLOAD=20000
JWT_SECRET=your_jwt_secret
JWT_EXPIRE=30d
JWT_COOKIE_EXPIRE=30
```

3. Start the server:
```bash
npm run dev
```

## Database Models

- **Customer**: User management with roles
- **Guitar**: Product information with specifications
- **Cart**: Shopping cart functionality
- **Order**: Order management with status tracking
- **Wishlist**: User favorites
- **Review**: Customer reviews and ratings

## Security Features

- JWT Authentication
- Role-based Access Control (Admin/Customer)
- Password encryption with bcrypt
- Input sanitization and XSS protection
- CORS configuration
- File upload security
