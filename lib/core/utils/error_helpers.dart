import 'dart:io';

class ErrorHelper {
  static String getErrorMessage(Object error) {
    final String message = error.toString();
    
    if (error is SocketException || message.contains('SocketException') || message.contains('Failed host lookup')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (message.contains('ClientException')) {
       if (message.contains('SocketException')) {
          return 'Network error. Please check your internet connection.';
       }
       return 'Server connection failed. Please try again.';
    }

    // Supabase specific errors often come as strings or specific types
    // Add more checks as needed
    
    // Clean up "Exception: " prefix if present
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    
    return message;
  }
}
