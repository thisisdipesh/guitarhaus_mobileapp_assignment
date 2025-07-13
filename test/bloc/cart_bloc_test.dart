import 'package:flutter_test/flutter_test.dart';

// Cart item model
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

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? image,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.image == image;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode ^ quantity.hashCode ^ image.hashCode;
}

// Cart state
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? errorMessage;
  final double total;

  CartState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  }) : total = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartState &&
        other.items == items &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => items.hashCode ^ isLoading.hashCode ^ errorMessage.hashCode;
}

// Cart BLoC
class CartBloc {
  CartState _state = CartState();

  CartState get state => _state;

  void addItem(CartItem item) {
    final existingItemIndex = _state.items.indexWhere((element) => element.id == item.id);

    if (existingItemIndex != -1) {
      // Update quantity of existing item
      final updatedItems = List<CartItem>.from(_state.items);
      final existingItem = updatedItems[existingItemIndex];
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
      );
      _state = _state.copyWith(items: updatedItems);
    } else {
      // Add new item
      final updatedItems = List<CartItem>.from(_state.items)..add(item);
      _state = _state.copyWith(items: updatedItems);
    }
  }

  void removeItem(String itemId) {
    final updatedItems = _state.items.where((item) => item.id != itemId).toList();
    _state = _state.copyWith(items: updatedItems);
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final updatedItems = _state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    _state = _state.copyWith(items: updatedItems);
  }

  void clearCart() {
    _state = CartState();
  }

  void setLoading(bool isLoading) {
    _state = _state.copyWith(isLoading: isLoading);
  }

  void setError(String? errorMessage) {
    _state = _state.copyWith(errorMessage: errorMessage, isLoading: false);
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
  }
}

void main() {
  group('CartBloc Tests', () {
    late CartBloc cartBloc;

    setUp(() {
      cartBloc = CartBloc();
    });

    group('Initial State Tests', () {
      test('should start with empty cart', () {
        final state = cartBloc.state;
        expect(state.items, isEmpty);
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
        expect(state.total, 0.0);
      });
    });

    group('Add Item Tests', () {
      test('should add new item to cart', () {
        final item = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        cartBloc.addItem(item);

        final state = cartBloc.state;
        expect(state.items.length, 1);
        expect(state.items.first, item);
        expect(state.total, 999.99);
      });

      test('should increase quantity when adding existing item', () {
        final item1 = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        final item2 = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 2,
          image: 'guitar1.jpg',
        );

        cartBloc.addItem(item1);
        cartBloc.addItem(item2);

        final state = cartBloc.state;
        expect(state.items.length, 1);
        expect(state.items.first.quantity, 3);
        expect(state.total, 999.99 * 3);
      });

      test('should add multiple different items', () {
        final item1 = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        final item2 = CartItem(
          id: '2',
          name: 'Gibson Les Paul',
          price: 1299.99,
          quantity: 1,
          image: 'guitar2.jpg',
        );

        cartBloc.addItem(item1);
        cartBloc.addItem(item2);

        final state = cartBloc.state;
        expect(state.items.length, 2);
        expect(state.total, 999.99 + 1299.99);
      });
    });

    group('Remove Item Tests', () {
      test('should remove item from cart', () {
        final item = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        cartBloc.addItem(item);
        expect(cartBloc.state.items.length, 1);

        cartBloc.removeItem('1');
        expect(cartBloc.state.items.length, 0);
        expect(cartBloc.state.total, 0.0);
      });

      test('should remove specific item when multiple items exist', () {
        final item1 = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        final item2 = CartItem(
          id: '2',
          name: 'Gibson Les Paul',
          price: 1299.99,
          quantity: 1,
          image: 'guitar2.jpg',
        );

        cartBloc.addItem(item1);
        cartBloc.addItem(item2);
        expect(cartBloc.state.items.length, 2);

        cartBloc.removeItem('1');
        expect(cartBloc.state.items.length, 1);
        expect(cartBloc.state.items.first.id, '2');
        expect(cartBloc.state.total, 1299.99);
      });
    });

    group('Update Quantity Tests', () {
      test('should update item quantity', () {
        final item = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        cartBloc.addItem(item);
        cartBloc.updateQuantity('1', 3);

        final state = cartBloc.state;
        expect(state.items.first.quantity, 3);
        expect(state.total, 999.99 * 3);
      });

      test('should remove item when quantity is 0', () {
        final item = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        cartBloc.addItem(item);
        cartBloc.updateQuantity('1', 0);

        expect(cartBloc.state.items.length, 0);
        expect(cartBloc.state.total, 0.0);
      });

      test('should remove item when quantity is negative', () {
        final item = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        cartBloc.addItem(item);
        cartBloc.updateQuantity('1', -1);

        expect(cartBloc.state.items.length, 0);
        expect(cartBloc.state.total, 0.0);
      });
    });

    group('Clear Cart Tests', () {
      test('should clear all items from cart', () {
        final item1 = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        final item2 = CartItem(
          id: '2',
          name: 'Gibson Les Paul',
          price: 1299.99,
          quantity: 1,
          image: 'guitar2.jpg',
        );

        cartBloc.addItem(item1);
        cartBloc.addItem(item2);
        expect(cartBloc.state.items.length, 2);

        cartBloc.clearCart();
        expect(cartBloc.state.items.length, 0);
        expect(cartBloc.state.total, 0.0);
      });
    });

    group('Loading and Error State Tests', () {
      test('should set loading state', () {
        cartBloc.setLoading(true);
        expect(cartBloc.state.isLoading, true);

        cartBloc.setLoading(false);
        expect(cartBloc.state.isLoading, false);
      });

      test('should set error message', () {
        cartBloc.setError('Failed to load cart');
        expect(cartBloc.state.errorMessage, 'Failed to load cart');
        expect(cartBloc.state.isLoading, false);
      });

      test('should clear error message', () {
        cartBloc.setError('Failed to load cart');
        expect(cartBloc.state.errorMessage, 'Failed to load cart');

        cartBloc.clearError();
        expect(cartBloc.state.errorMessage, isNull);
      });
    });

    group('Total Calculation Tests', () {
      test('should calculate total correctly for single item', () {
        final item = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 2,
          image: 'guitar1.jpg',
        );

        cartBloc.addItem(item);
        expect(cartBloc.state.total, 999.99 * 2);
      });

      test('should calculate total correctly for multiple items', () {
        final item1 = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 2,
          image: 'guitar1.jpg',
        );

        final item2 = CartItem(
          id: '2',
          name: 'Gibson Les Paul',
          price: 1299.99,
          quantity: 1,
          image: 'guitar2.jpg',
        );

        cartBloc.addItem(item1);
        cartBloc.addItem(item2);

        final expectedTotal = (999.99 * 2) + (1299.99 * 1);
        expect(cartBloc.state.total, expectedTotal);
      });

      test('should update total when quantity changes', () {
        final item = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        cartBloc.addItem(item);
        expect(cartBloc.state.total, 999.99);

        cartBloc.updateQuantity('1', 3);
        expect(cartBloc.state.total, 999.99 * 3);
      });
    });

    group('State Equality Tests', () {
      test('CartState should be equal when properties are the same', () {
        final state1 = CartState(
          items: [
            CartItem(
              id: '1',
              name: 'Fender Stratocaster',
              price: 999.99,
              quantity: 1,
              image: 'guitar1.jpg',
            ),
          ],
          isLoading: false,
          errorMessage: null,
        );

        final state2 = CartState(
          items: [
            CartItem(
              id: '1',
              name: 'Fender Stratocaster',
              price: 999.99,
              quantity: 1,
              image: 'guitar1.jpg',
            ),
          ],
          isLoading: false,
          errorMessage: null,
        );

        expect(state1.items, equals(state2.items));
        expect(state1.isLoading, equals(state2.isLoading));
        expect(state1.errorMessage, equals(state2.errorMessage));
        expect(state1.total, equals(state2.total));
      });

      test('CartItem should be equal when properties are the same', () {
        final item1 = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        final item2 = CartItem(
          id: '1',
          name: 'Fender Stratocaster',
          price: 999.99,
          quantity: 1,
          image: 'guitar1.jpg',
        );

        expect(item1, equals(item2));
      });
    });
  });
} 