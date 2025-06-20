import 'package:guitarhaus_mobileapp_assignment/features/auth/data/model/user_hive_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static const String userBox = 'userBox';

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    Hive.registerAdapter(UserHiveModelAdapter());
  }

  // Add/register user (stores using username as key)
  Future<void> register(UserHiveModel user) async {
    final box = await Hive.openBox<UserHiveModel>(userBox);
    await box.put(user.username, user); // using username as key
  }

  // Delete user by username
  Future<void> deleteUser(String username) async {
    final box = await Hive.openBox<UserHiveModel>(userBox);
    await box.delete(username);
  }

  // Get all users
  Future<List<UserHiveModel>> getAllUsers() async {
    final box = await Hive.openBox<UserHiveModel>(userBox);
    return box.values.toList();
  }

  // Login by checking username & password
  Future<UserHiveModel?> login(String username, String password) async {
    final box = await Hive.openBox<UserHiveModel>(userBox);
    try {
      return box.values.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // Clear all users
  Future<void> clearAll() async {
    final box = await Hive.openBox<UserHiveModel>(userBox);
    await box.clear();
  }

  // Close Hive
  Future<void> close() async {
    await Hive.close();
  }
}
