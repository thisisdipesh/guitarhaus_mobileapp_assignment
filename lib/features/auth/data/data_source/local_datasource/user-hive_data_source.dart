import 'package:guitarhaus_mobileapp_assignment/core/network/hive_service.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/data/data_source/user_data_source.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/data/model/user_hive_model.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/entity/user_entity.dart';

class UserHiveDataSource implements IUserDataSource {
  final HiveService _hiveService;

  UserHiveDataSource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<String> loginUser(String username, String password) async {
    try {
      final userData = await _hiveService.login(username, password);
      if (userData != null && userData.password == password) {
        return "Login successful";
      } else {
        throw Exception("Invalid username or password");
      }
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<void> registerUser(UserEntity user) async {
    try {
      final userHiveModel = UserHiveModel.fromEntity(user);
      await _hiveService.register(userHiveModel);
    } catch (e) {
      throw Exception("Registration failed: $e");
    }
  }

  @override
  Future<String> uploadProfilePicture(String filePath) {
    // You can add actual file upload logic if needed
    throw UnimplementedError("Upload profile picture not implemented yet");
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final users = await _hiveService.getAllUsers();
    if (users.isNotEmpty) {
      return users.first.toEntity(); // You might update logic later
    } else {
      throw Exception("No user found in Hive.");
    }
  }
}
