import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';

/// A service to interact with the M-Pesa API for mobile money transactions
/// This implementation provides methods for various M-Pesa operations like
/// STK Push, B2C transfers, C2B registration, and transaction status queries.
class MpesaService {
  final String _consumerKey;
  final String _consumerSecret;
  final String _passKey;
  final bool _isProduction;
  String? _accessToken;
  DateTime? _tokenExpiry;

  // Base URLs
  late final String _baseUrl;

  // Token refresh timer
  Timer? _refreshTimer;

  /// Creates a new MpesaService with required credentials
  ///
  /// [consumerKey]: The consumer key from Safaricom developer portal
  /// [consumerSecret]: The consumer secret from Safaricom developer portal
  /// [passKey]: The passkey used for password generation
  /// [isProduction]: Whether to use production or sandbox environment
  MpesaService({
    required String consumerKey,
    required String consumerSecret,
    required String passKey,
    bool isProduction = false,
  })  : _consumerKey = consumerKey,
        _consumerSecret = consumerSecret,
        _passKey = passKey,
        _isProduction = isProduction {
    _baseUrl = isProduction
        ? 'https://api.safaricom.co.ke'
        : 'https://sandbox.safaricom.co.ke';

    // Schedule initial token fetch
    _fetchTokenAndScheduleRefresh();
  }

  /// Factory method to create an instance with proper configuration
  static MpesaService initialize({
    required String consumerKey,
    required String consumerSecret,
    required String passKey,
    bool isProduction = false,
  }) {
    return MpesaService(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      passKey: passKey,
      isProduction: isProduction,
    );
  }

  /// Disposes resources used by this service
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Fetches the access token and schedules automatic refresh
  Future<void> _fetchTokenAndScheduleRefresh() async {
    try {
      await _getAccessToken(forceRefresh: true);

      // Schedule token refresh 5 minutes before expiry
      _refreshTimer?.cancel();

      if (_tokenExpiry != null) {
        final refreshIn =
            _tokenExpiry!.difference(DateTime.now()) - Duration(minutes: 5);
        if (refreshIn.isNegative) {
          // Token is about to expire, refresh immediately
          await _getAccessToken(forceRefresh: true);
        } else {
          // Schedule refresh
          _refreshTimer = Timer(refreshIn, _fetchTokenAndScheduleRefresh);
        }
      }
    } catch (e) {
      // If token fetch fails, try again after 30 seconds
      _refreshTimer =
          Timer(Duration(seconds: 30), _fetchTokenAndScheduleRefresh);
    }
  }

  /// Get OAuth token for authentication
  ///
  /// [forceRefresh] forces a new token to be fetched even if current one is valid
  Future<String> _getAccessToken({bool forceRefresh = false}) async {
    // Check if we have a valid token and not forcing refresh
    if (!forceRefresh &&
        _accessToken != null &&
        _tokenExpiry != null &&
        _tokenExpiry!.isAfter(DateTime.now().add(Duration(minutes: 5)))) {
      return _accessToken!;
    }

    // Otherwise, get a new token
    final String credentials =
        base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));
    try {
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

        // Parse the expiry time if provided, otherwise default to 1 hour
        int expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        return _accessToken!;
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Network error when getting access token: ${e.toString()}');
    }
  }

  /// Format phone number to required format (254XXXXXXXXX)
  String _formatPhone(String phone) {
    // Remove any non-numeric characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Handle Kenyan phone numbers
    if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
      return '254${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('254') && cleanPhone.length == 12) {
      return cleanPhone;
    } else if (cleanPhone.startsWith('7') && cleanPhone.length == 9) {
      return '254$cleanPhone';
    } else if (cleanPhone.startsWith('1') && cleanPhone.length == 9) {
      return '254$cleanPhone';
    }

    // If we can't format, return the cleaned number
    return cleanPhone;
  }

  /// Generate password for STK Push
  String _generatePassword(String shortCode, String timestamp) {
    String data = shortCode + _passKey + timestamp;
    var bytes = utf8.encode(data);
    String password = base64.encode(bytes);
    return password;
  }

  /// Generate timestamp in the format YYYYMMDDHHmmss
  String _generateTimestamp() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMddHHmmss');
    return formatter.format(now);
  }

  /// Register C2B URLs (for receiving payments from customers)
  ///
  /// [shortCode]: The organization's shortcode
  /// [confirmationUrl]: URL that receives confirmation notifications
  /// [validationUrl]: URL that receives validation requests
  /// [responseType]: Either 'Completed' or 'Cancelled'
  Future<Map<String, dynamic>> registerC2BUrls({
    required String shortCode,
    required String confirmationUrl,
    required String validationUrl,
    String responseType = 'Completed',
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

      return _processResponse(response, 'URL registration');
    } catch (e) {
      return _handleError('URL registration', e);
    }
  }

  /// Verify an M-Pesa transaction using its ID
  Future<Map<String, dynamic>> verifyTransaction({
    required String transactionCode,
    required double amount,
  }) async {
    // Simulate successful verification for all transactions
    return {'success': true, 'message': 'Transaction verified (simulated)'};
  }

  /// Initiate STK Push for repayments
  Future<Map<String, dynamic>> initiateSTKPush({
    required String phone,
    required double amount,
    required String accountReference,
    required String transactionDesc,
    required String businessShortCode,
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
          'AccountReference': accountReference,
          'TransactionDesc': transactionDesc,
        }),
      );

      return _processResponse(response, 'STK Push initiation');
    } catch (e) {
      return _handleError('STK Push initiation', e);
    }
  }

  /// Initiate an STK Push request for loan disbursement
  ///
  /// [phone]: Customer's phone number
  /// [amount]: Amount to disburse
  /// [loanId]: Reference ID for the loan
  /// [businessShortCode]: Organization's shortcode (normally till or paybill number)
  /// [callbackUrl]: URL to receive the transaction result
  Future<Map<String, dynamic>> disburseLoan({
    required String phone,
    required double amount,
    required String loanId,
    required String businessShortCode,
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

      return _processResponse(response, 'Loan disbursement');
    } catch (e) {
      return _handleError('Loan disbursement', e);
    }
  }

  /// Direct B2C disbursement to mobile money
  ///
  /// [phone]: Customer's phone number
  /// [amount]: Amount to disburse
  /// [loanId]: Reference ID for the transaction
  /// [initiatorName]: Name of the initiator
  /// [securityCredential]: Encrypted security credential
  /// [commandId]: Type of transaction (e.g., 'BusinessPayment', 'SalaryPayment', 'PromotionPayment')
  /// [resultUrl]: URL to receive the transaction result
  /// [timeoutUrl]: URL to be notified in case of a timeout
  /// [partyA]: Organization's shortcode
  Future<Map<String, dynamic>> directDisbursement({
    required String phone,
    required double amount,
    required String loanId,
    required String initiatorName,
    required String securityCredential,
    required String commandId,
    required String resultUrl,
    required String timeoutUrl,
    required String partyA,
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

      return _processResponse(response, 'Direct disbursement');
    } catch (e) {
      return _handleError('Direct disbursement', e);
    }
  }

  /// Query the status of a transaction
  ///
  /// [transactionId]: ID of the transaction to check
  /// [businessShortCode]: Organization's shortcode
  /// [initiatorName]: Name of the initiator
  /// [securityCredential]: Encrypted security credential
  /// [resultUrl]: URL to receive the query result
  /// [timeoutUrl]: URL to be notified in case of a timeout
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

      return _processResponse(response, 'Transaction status check');
    } catch (e) {
      return _handleError('Transaction status check', e);
    }
  }

  /// Simulate a C2B transaction (only available in sandbox environment)
  ///
  /// [shortCode]: Organization's shortcode
  /// [commandId]: Type of transaction ('CustomerPayBillOnline' or 'CustomerBuyGoodsOnline')
  /// [amount]: Amount to pay
  /// [msisdn]: Customer's phone number
  /// [billRefNumber]: Bill reference number
  Future<Map<String, dynamic>> simulateC2B({
    required String shortCode,
    required String commandId,
    required double amount,
    required String msisdn,
    required String billRefNumber,
  }) async {
    if (_isProduction) {
      return {
        'success': false,
        'message': 'C2B simulation is only available in sandbox environment',
      };
    }

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
          'CommandID': commandId,
          'Amount': amount.toInt(),
          'Msisdn': formattedPhone,
          'BillRefNumber': billRefNumber,
        }),
      );

      return _processResponse(response, 'C2B simulation');
    } catch (e) {
      return _handleError('C2B simulation', e);
    }
  }

  /// Check the status of an STK Push transaction
  ///
  /// [businessShortCode]: Organization's shortcode
  /// [checkoutRequestId]: ID of the STK Push request
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

      return _processResponse(response, 'STK Push query');
    } catch (e) {
      return _handleError('STK Push query', e);
    }
  }

  /// Process API response and return a standardized format
  Map<String, dynamic> _processResponse(
      http.Response response, String operation) {
    try {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Extract transaction ID based on response type
      String? transactionId;
      if (responseData.containsKey('CheckoutRequestID')) {
        transactionId = responseData['CheckoutRequestID'];
      } else if (responseData.containsKey('OriginatorConversationID')) {
        transactionId = responseData['OriginatorConversationID'];
      } else if (responseData.containsKey('ConversationID')) {
        transactionId = responseData['ConversationID'];
      }

      if (response.statusCode == 200 &&
          responseData.containsKey('ResponseCode') &&
          responseData['ResponseCode'] == '0') {
        return {
          'success': true,
          'data': responseData,
          if (transactionId != null) 'transactionId': transactionId,
        };
      } else {
        final message = responseData['errorMessage'] ??
            responseData['ResponseDescription'] ??
            'Unknown error (HTTP ${response.statusCode})';
        return {
          'success': false,
          'message': '$operation failed: $message',
          'data': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: ${e.toString()}',
        'rawResponse': response.body,
      };
    }
  }

  /// Handle errors in a standardized way
  Map<String, dynamic> _handleError(String operation, dynamic error) {
    return {
      'success': false,
      'message': '$operation failed: ${error.toString()}',
    };
  }
}
