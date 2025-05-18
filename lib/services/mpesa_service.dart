import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Custom implementation of M-Pesa API functionality without using the mpesadaraja package
class MpesaService {
  final String _consumerKey;
  final String _consumerSecret;
  final String _passKey;
  final bool _isProduction;
  String? _accessToken;
  DateTime? _tokenExpiry;

  // Base URLs
  late final String _baseUrl;

  // Constructor with configuration
  MpesaService({
    required String consumerKey,
    required String consumerSecret,
    required String passKey,
    bool isProduction = false,
  }) : _consumerKey = consumerKey,
        _consumerSecret = consumerSecret,
        _passKey = passKey,
        _isProduction = isProduction {
    _baseUrl = isProduction
        ? 'https://api.safaricom.co.ke'
        : 'https://sandbox.safaricom.co.ke';
  }

  // Example of how to create the service in your app
  static MpesaService initialize({required bool isProduction}) {
    return MpesaService(
      consumerKey: isProduction ? 'YOUR_PRODUCTION_CONSUMER_KEY' : 'YOUR_SANDBOX_CONSUMER_KEY',
      consumerSecret: isProduction ? 'YOUR_PRODUCTION_CONSUMER_SECRET' : 'YOUR_SANDBOX_CONSUMER_SECRET',
      passKey: isProduction ? 'YOUR_PRODUCTION_PASSKEY' : 'YOUR_SANDBOX_PASSKEY',
      isProduction: isProduction,
    );
  }

  // Get OAuth token for authentication
  Future<String> _getAccessToken() async {
    // Check if we have a valid token
    if (_accessToken != null && _tokenExpiry != null && _tokenExpiry!.isAfter(DateTime.now())) {
      return _accessToken!;
    }

    // Otherwise, get a new token
    final String credentials = base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));
    final http.Response response = await http.get(
      Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      _accessToken = data['access_token'];
      // Token typically expires in 1 hour, set expiry to 50 minutes to be safe
      _tokenExpiry = DateTime.now().add(Duration(minutes: 50));
      return _accessToken!;
    } else {
      throw Exception('Failed to get access token: ${response.body}');
    }
  }

  // Format phone number to required format (254XXXXXXXXX)
  String _formatPhone(String phone) {
    // Remove any country code if present
    String formattedPhone = phone.replaceAll('+', '');

    // Handle Kenyan phone numbers
    if (formattedPhone.startsWith('0')) {
      return '254${formattedPhone.substring(1)}';
    } else if (formattedPhone.startsWith('254')) {
      return formattedPhone;
    }

    // Default case
    return '254$formattedPhone';
  }

  // Generate password for STK Push
  String _generatePassword(String shortCode, String timestamp) {
    String data = shortCode + _passKey + timestamp;
    var bytes = utf8.encode(data);
    String password = base64.encode(bytes);
    return password;
  }

  // Generate timestamp in the format YYYYMMDDHHmmss
  String _generateTimestamp() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMddHHmmss');
    return formatter.format(now);
  }

  // Register C2B URLs (for receiving payments from customers)
  Future<Map<String, dynamic>> registerC2BUrls({
    required String shortCode,
    required String confirmationUrl,
    required String validationUrl,
    required String responseType,
  }) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/c2b/v1/registerurl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ShortCode': shortCode,
          'ResponseType': responseType,
          'ConfirmationURL': confirmationUrl,
          'ValidationURL': validationUrl,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('ResponseCode') && responseData['ResponseCode'] == '0') {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'URL registration failed: ${responseData['errorMessage'] ?? responseData['ResponseDescription'] ?? 'Unknown error'}',
          'data': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'URL registration failed: ${e.toString()}',
      };
    }
  }

  // Disburse loan to student's M-Pesa using STK Push
  Future<Map<String, dynamic>> disburseLoan({
    required String phone,
    required double amount,
    required String loanId,
    required String businessShortCode,
    required String passKey,
    required String callbackUrl,
  }) async {
    try {
      final formattedPhone = _formatPhone(phone);
      final timestamp = _generateTimestamp();
      final password = _generatePassword(businessShortCode, timestamp);

      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'BusinessShortCode': businessShortCode,
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': amount.toInt(),
          'PartyA': formattedPhone,
          'PartyB': businessShortCode,
          'PhoneNumber': formattedPhone,
          'CallBackURL': callbackUrl,
          'AccountReference': 'LOAN_$loanId',
          'TransactionDesc': 'Loan Disbursement',
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('ResponseCode') && responseData['ResponseCode'] == '0') {
        return {
          'success': true,
          'data': responseData,
          'transactionId': responseData['CheckoutRequestID'],
        };
      } else {
        return {
          'success': false,
          'message': 'STK Push failed: ${responseData['errorMessage'] ?? responseData['ResponseDescription'] ?? 'Unknown error'}',
          'data': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Disbursement failed: ${e.toString()}',
      };
    }
  }

  // B2C (Business to Customer) - Direct disbursement to mobile money
  Future<Map<String, dynamic>> directDisbursement({
    required String phone,
    required double amount,
    required String loanId,
    required String initiatorName,
    required String securityCredential,
    required String commandId,
    required String resultUrl,
    required String timeoutUrl,
    required String partyA, // Your organization's shortcode
  }) async {
    try {
      final formattedPhone = _formatPhone(phone);

      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/b2c/v1/paymentrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'InitiatorName': initiatorName,
          'SecurityCredential': securityCredential,
          'CommandID': commandId,
          'Amount': amount.toInt(),
          'PartyA': partyA,
          'PartyB': formattedPhone,
          'Remarks': 'Loan Disbursement for ID: $loanId',
          'QueueTimeOutURL': timeoutUrl,
          'ResultURL': resultUrl,
          'Occasion': 'Loan',
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('ResponseCode') && responseData['ResponseCode'] == '0') {
        return {
          'success': true,
          'data': responseData,
          'transactionId': responseData['OriginatorConversationID'],
        };
      } else {
        return {
          'success': false,
          'message': 'B2C transaction failed: ${responseData['errorMessage'] ?? responseData['ResponseDescription'] ?? 'Unknown error'}',
          'data': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Direct disbursement failed: ${e.toString()}',
      };
    }
  }

  // Query transaction status
  Future<Map<String, dynamic>> checkTransactionStatus({
    required String transactionId,
    required String businessShortCode,
    required String initiatorName,
    required String securityCredential,
    required String resultUrl,
    required String timeoutUrl,
  }) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/transactionstatus/v1/query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'Initiator': initiatorName,
          'SecurityCredential': securityCredential,
          'CommandID': 'TransactionStatusQuery',
          'TransactionID': transactionId,
          'PartyA': businessShortCode,
          'IdentifierType': '4', // Organization identifier type
          'ResultURL': resultUrl,
          'QueueTimeOutURL': timeoutUrl,
          'Remarks': 'Transaction status query',
          'Occasion': 'Status check',
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('ResponseCode') && responseData['ResponseCode'] == '0') {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'Status check failed: ${responseData['errorMessage'] ?? responseData['ResponseDescription'] ?? 'Unknown error'}',
          'data': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Status check failed: ${e.toString()}',
      };
    }
  }

  // C2B (Customer to Business) - Simulate customer payment to business
  Future<Map<String, dynamic>> simulateC2B({
    required String shortCode,
    required String commandId,
    required double amount,
    required String msisdn,
    required String billRefNumber,
  }) async {
    try {
      final formattedPhone = _formatPhone(msisdn);

      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/c2b/v1/simulate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ShortCode': shortCode,
          'CommandID': commandId, // "CustomerPayBillOnline" or "CustomerBuyGoodsOnline"
          'Amount': amount.toInt(),
          'Msisdn': formattedPhone,
          'BillRefNumber': billRefNumber,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('ResponseCode') && responseData['ResponseCode'] == '0') {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'C2B simulation failed: ${responseData['errorMessage'] ?? responseData['ResponseDescription'] ?? 'Unknown error'}',
          'data': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'C2B simulation failed: ${e.toString()}',
      };
    }
  }

  // STK Push Query - Check status of an STK Push transaction
  Future<Map<String, dynamic>> stkPushQuery({
    required String businessShortCode,
    required String checkoutRequestId,
  }) async {
    try {
      final timestamp = _generateTimestamp();
      final password = _generatePassword(businessShortCode, timestamp);

      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'BusinessShortCode': businessShortCode,
          'Password': password,
          'Timestamp': timestamp,
          'CheckoutRequestID': checkoutRequestId,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('ResponseCode') && responseData['ResponseCode'] == '0') {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'STK Push query failed: ${responseData['errorMessage'] ?? responseData['ResponseDescription'] ?? 'Unknown error'}',
          'data': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'STK Push query failed: ${e.toString()}',
      };
    }
  }
}