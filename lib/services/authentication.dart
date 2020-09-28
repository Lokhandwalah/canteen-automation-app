import 'package:canteen/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'database.dart';

abstract class BaseAuth {
  User getCurrentUser();
  bool isUserLoggedIn();
  Future signUp(UserData user);
  Future googleSignUp();
  Future sigIn(String email, String password);
  Future googleSignIn();
  Future signOut();
  Future resetPassword(String email);
}

class AuthService extends BaseAuth {
  static final _auth = FirebaseAuth.instance;
  static final exceptionHandler = AuthExceptionHandler();
  @override
  User getCurrentUser() => _auth.currentUser;

  @override
  bool isUserLoggedIn() => getCurrentUser() != null;

  @override
  Future<Map> googleSignIn() async {
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    GoogleSignInAccount googleUser;
    GoogleSignInAuthentication googleAuth;
    try {
      try {
        googleUser = await googleSignIn.signIn();
        googleAuth = await googleUser.authentication;
      } catch (e) {
        print(e.toString());
        return {"success": false, 'msg': 'Google Signin Cancelled'};
      }
      final userDoc = await DBService().getUserDoc(googleUser.email);
      if (userDoc == null) {
        await googleSignIn.signOut();
        return {
          "success": false,
          'msg': exceptionHandler
              .getExceptionMessage(AuthResultStatus.userNotFound)
        };
      }
      final user =
          (await _auth.signInWithCredential(GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      )))
              .user;
      final currentUser = await UserData.setData(user.email, userDoc.data());
      return {'success': true, 'user': user, "current": currentUser};
    } catch (e) {
      print(e.toString());
      await googleSignIn.signOut();
      String msg = exceptionHandler
          .getExceptionMessage(exceptionHandler.getAuthStatus(e));
      return {"success": false, 'msg': msg};
    }
  }

  @override
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<Map> sigIn(String email, String password) async {
    try {
      final user = (await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;
      final currentUser = await UserData.setData(email);
      return {'success': true, 'user': user, 'current': currentUser};
    } catch (e) {
      String msg = exceptionHandler
          .getExceptionMessage(exceptionHandler.getAuthStatus(e));
      print(msg);
      return {'success': false, 'msg': msg};
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await UserData.resetData();
      await GoogleSignIn().signOut();
      await _auth.signOut();
      print('Signed Out');
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<Map> signUp(UserData userData) async {
    try {
      final user = (await _auth.createUserWithEmailAndPassword(
              email: userData.email, password: userData.password))
          .user;
      await user.updateProfile(displayName: userData.name);
      return {'success': true, 'user': user, 'uid': user.uid};
    } catch (e) {
      String msg = exceptionHandler
          .getExceptionMessage(exceptionHandler.getAuthStatus(e));
      return {'success': false, 'msg': msg};
    }
  }

  @override
  Future<Map> googleSignUp() async {
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    GoogleSignInAccount googleUser;
    GoogleSignInAuthentication googleAuth;
    try {
      try {
        googleUser = await googleSignIn.signIn();
        googleAuth = await googleUser.authentication;
      } catch (e) {
        print(e.toString());
        return {"success": false, 'msg': 'Google Signin Cancelled'};
      }
      final userDoc = await DBService().getUserDoc(googleUser.email);
      if (userDoc != null) {
        await googleSignIn.signOut();
        return {
          "success": false,
          'msg': exceptionHandler
              .getExceptionMessage(AuthResultStatus.emailAlreadyExists)
        };
      }
      return {
        'success': true,
        'email': googleUser.email,
        'name': googleUser.displayName
      };
    } catch (e) {
      print(e.toString());
      String msg = exceptionHandler
          .getExceptionMessage(exceptionHandler.getAuthStatus(e));
      return {"success": false, 'msg': msg};
    }
  }
}

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  credentialAlreadyExists,
  wrongPassword,
  invalidEmail,
  invalidCredential,
  invalidOTP,
  invalidVerificationID,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class AuthExceptionHandler {
  AuthResultStatus getAuthStatus(e) {
    print(e.toString());
    AuthResultStatus status;
    try {
      print(e.code);
      switch (e.code) {
        case "invalid-email":
          status = AuthResultStatus.invalidEmail;
          break;
        case "invalid-credential":
          status = AuthResultStatus.invalidCredential;
          break;
        case "invalid-verification-code":
          status = AuthResultStatus.invalidOTP;
          break;
        case "invalid-verificaction-id":
          status = AuthResultStatus.invalidVerificationID;
          break;
        case "wrong-password":
          status = AuthResultStatus.wrongPassword;
          break;
        case "user-not-found":
          status = AuthResultStatus.userNotFound;
          break;
        case "user-disabled":
          status = AuthResultStatus.userDisabled;
          break;
        case "too-many-requests":
          status = AuthResultStatus.tooManyRequests;
          break;
        case "operation-not-allowed":
          status = AuthResultStatus.operationNotAllowed;
          break;
        case "email-already-in-use":
          status = AuthResultStatus.emailAlreadyExists;
          break;
        case "account-exists-with-different-credential":
          status = AuthResultStatus.credentialAlreadyExists;
          break;
        default:
          status = AuthResultStatus.undefined;
      }
    } catch (_) {
      status = AuthResultStatus.undefined;
    }
    return status;
  }

  String getExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage =
            "Your email address appears to be malformed or badly formatted.";
        break;
      case AuthResultStatus.invalidCredential:
        errorMessage = "There appears to be a problem with your credentials.";
        break;
      case AuthResultStatus.invalidOTP:
        errorMessage = "This verification code is wrong.";
        break;
      case AuthResultStatus.invalidVerificationID:
        errorMessage = "This verifiaction code appears to be wrong.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Your password is wrong.";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "User with this email doesn't exist.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "User with this email has been disabled.";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Too many requests. Try again later.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage =
            "The email has already been registered. Please try again with another email address.";
        break;
      case AuthResultStatus.credentialAlreadyExists:
        errorMessage =
            "The email has already been registered with some other account. Please try again with another email address.";
        break;
      default:
        errorMessage = "Something went Wrong. try again later";
    }
    return errorMessage;
  }
}
