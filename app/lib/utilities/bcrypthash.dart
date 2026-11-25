import 'package:bcrypt/bcrypt.dart';


class Hasher {
  static String hashPassword(String password) {
    final salt = BCrypt.gensalt();
    final hashed = BCrypt.hashpw(password, salt);
    return hashed;
  }

  static bool verifyPassword(String password, String storedHash) {
   return BCrypt.checkpw(password, storedHash);
  }

}