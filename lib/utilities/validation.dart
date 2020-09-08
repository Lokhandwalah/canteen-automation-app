class Validation {
  static bool emptyCheck(value) => value.isEmpty;

  static bool emailvalidation(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return !regex.hasMatch(value);
  }

  static bool lengthCheck(String value, int len) => value.length < len;

  static bool phoneNoValidation(String value) => value.length != 10;
}
