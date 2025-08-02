import 'package:flutter_test/flutter_test.dart';

// Mock cart item class for testing
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  double get totalPrice => price * quantity;
}

// Cart utility functions for testing
class CartUtils {
  static List<CartItem> _items = [];

  static void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((element) => element.id == item.id);
    if (existingIndex != -1) {
      _items[existingIndex] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: _items[existingIndex].quantity + item.quantity,
        image: item.image,
      );
    } else {
      _items.add(item);
    }
  }

  static void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
  }

  static void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = CartItem(
          id: _items[index].id,
          name: _items[index].name,
          price: _items[index].price,
          quantity: quantity,
          image: _items[index].image,
        );
      }
    }
  }

  static double getTotalPrice() {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  static int getTotalItems() {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  static List<CartItem> getItems() {
    return List.from(_items);
  }

  static void clearCart() {
    _items.clear();
  }

  static bool isEmpty() {
    return _items.isEmpty;
  }

  static bool isValidItem(CartItem item) {
    return item.id.isNotEmpty &&
        item.name.isNotEmpty &&
        item.price > 0 &&
        item.quantity > 0 &&
        item.image.isNotEmpty;
  }

  static bool isValidQuantity(int quantity) {
    return quantity > 0 && quantity <= 99;
  }

  static bool isValidPrice(double price) {
    return price > 0 && price <= 99999.99;
  }
}

void main() {
  group('CartUtils Unit Tests', () {
    setUp(() {
      CartUtils.clearCart();
    });

    group('Cart Item Management Tests', () {
      test('should add new item to cart', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        CartUtils.addItem(item);
        expect(CartUtils.getItems().length, 1);
        expect(CartUtils.getItems().first.name, 'Test Guitar');
      });

      test('should update quantity when adding existing item', () {
        final item1 = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        final item2 = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 2,
          image: 'test_image.jpg',
        );

        CartUtils.addItem(item1);
        CartUtils.addItem(item2);

        expect(CartUtils.getItems().length, 1);
        expect(CartUtils.getItems().first.quantity, 3);
      });

      test('should remove item from cart', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        CartUtils.addItem(item);
        expect(CartUtils.getItems().length, 1);

        CartUtils.removeItem('1');
        expect(CartUtils.getItems().length, 0);
      });

      test('should update item quantity', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        CartUtils.addItem(item);
        CartUtils.updateQuantity('1', 3);

        expect(CartUtils.getItems().first.quantity, 3);
      });

      test('should remove item when quantity is zero', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        CartUtils.addItem(item);
        CartUtils.updateQuantity('1', 0);

        expect(CartUtils.getItems().length, 0);
      });
    });

    group('Cart Calculation Tests', () {
      test('should calculate total price correctly', () {
        final item1 = CartItem(
          id: '1',
          name: 'Guitar 1',
          price: 299.99,
          quantity: 2,
          image: 'image1.jpg',
        );

        final item2 = CartItem(
          id: '2',
          name: 'Guitar 2',
          price: 199.99,
          quantity: 1,
          image: 'image2.jpg',
        );

        CartUtils.addItem(item1);
        CartUtils.addItem(item2);

        final expectedTotal = (299.99 * 2) + (199.99 * 1);
        expect(CartUtils.getTotalPrice(), expectedTotal);
      });

      test('should calculate total items correctly', () {
        final item1 = CartItem(
          id: '1',
          name: 'Guitar 1',
          price: 299.99,
          quantity: 2,
          image: 'image1.jpg',
        );

        final item2 = CartItem(
          id: '2',
          name: 'Guitar 2',
          price: 199.99,
          quantity: 3,
          image: 'image2.jpg',
        );

        CartUtils.addItem(item1);
        CartUtils.addItem(item2);

        expect(CartUtils.getTotalItems(), 5);
      });

      test('should return zero for empty cart', () {
        expect(CartUtils.getTotalPrice(), 0.0);
        expect(CartUtils.getTotalItems(), 0);
      });
    });

    group('Cart State Tests', () {
      test('should identify empty cart', () {
        expect(CartUtils.isEmpty(), true);
      });

      test('should identify non-empty cart', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        CartUtils.addItem(item);
        expect(CartUtils.isEmpty(), false);
      });

      test('should clear cart completely', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        CartUtils.addItem(item);
        expect(CartUtils.isEmpty(), false);

        CartUtils.clearCart();
        expect(CartUtils.isEmpty(), true);
        expect(CartUtils.getTotalPrice(), 0.0);
      });
    });

    group('Validation Tests', () {
      test('should validate valid cart item', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        expect(CartUtils.isValidItem(item), true);
      });

      test('should reject invalid cart item with empty id', () {
        final item = CartItem(
          id: '',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 1,
          image: 'test_image.jpg',
        );

        expect(CartUtils.isValidItem(item), false);
      });

      test('should reject invalid cart item with negative price', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: -10.0,
          quantity: 1,
          image: 'test_image.jpg',
        );

        expect(CartUtils.isValidItem(item), false);
      });

      test('should reject invalid cart item with zero quantity', () {
        final item = CartItem(
          id: '1',
          name: 'Test Guitar',
          price: 299.99,
          quantity: 0,
          image: 'test_image.jpg',
        );

        expect(CartUtils.isValidItem(item), false);
      });

      test('should validate valid quantity', () {
        expect(CartUtils.isValidQuantity(1), true);
        expect(CartUtils.isValidQuantity(50), true);
        expect(CartUtils.isValidQuantity(99), true);
      });

      test('should reject invalid quantity', () {
        expect(CartUtils.isValidQuantity(0), false);
        expect(CartUtils.isValidQuantity(-1), false);
        expect(CartUtils.isValidQuantity(100), false);
      });

      test('should validate valid price', () {
        expect(CartUtils.isValidPrice(1.0), true);
        expect(CartUtils.isValidPrice(999.99), true);
        expect(CartUtils.isValidPrice(99999.99), true);
      });

      test('should reject invalid price', () {
        expect(CartUtils.isValidPrice(0.0), false);
        expect(CartUtils.isValidPrice(-10.0), false);
        expect(CartUtils.isValidPrice(100000.0), false);
      });
    });
  });
}
