import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:task01/core/constants/strings/app_constants.dart';
import 'package:task01/core/constants/strings/error_strings.dart';

enum Method { get, post, put, delete, patch }

class ApiClient {
  ApiClient();
  static var client = http.Client();

  final Map<String, String> _mainHeaders = {
    'Content-Type': 'application/json',
    'Vary': 'Accept',
  };

  ///post http request supported
Future<http.Response> apiRequest(
    String url, {
    Method method = Method.get,
    dynamic body,
    Map<String, String>? headers,
    int? timeOut,
    String? token,
  }) async {
    http.Response response;
    Map<String, String> finalHeaders = headers ?? (token != null ? currentUserHeader(token:token) : _mainHeaders);
    dynamic finalBody = jsonEncode(body);
    int finalTimeOut = timeOut ?? AppConstant.timeoutRequest; 
    Uri finalUri = Uri.parse(url);

    log('====> Http Call: $url');

    if (method == Method.put) {
      response = await client
          .put(
        finalUri,
        body: finalBody,
        headers: finalHeaders,
      )
          .timeout(
        Duration(seconds: finalTimeOut),
        onTimeout: () {
          return http.Response(addedErrorMessage(), 408);
        },
      );
    } else if (method == Method.delete) {
      response = await client
          .delete(
        finalUri,
        body: finalBody,
        headers: finalHeaders,
      )
          .timeout(
        Duration(seconds: finalTimeOut),
        onTimeout: () {
          return http.Response(addedErrorMessage(), 408);
        },
      );
    } else if (method == Method.patch) {
      response = await client
          .patch(
        finalUri,
        body: finalBody,
        headers: finalHeaders,
      )
          .timeout(
        Duration(seconds: finalTimeOut),
        onTimeout: () {
          return http.Response(addedErrorMessage(), 408);
        },
      );
    } else if (method == Method.post) {
      response = await client
          .post(
        finalUri,
        body: finalBody,
        headers: finalHeaders,
      )
          .timeout(
        Duration(seconds: finalTimeOut),
        onTimeout: () {
          return http.Response(addedErrorMessage(), 408);
        },
      );
    } else {
      response = await client
          .get(
        finalUri,
        headers: finalHeaders,
      )
          .timeout(
        Duration(seconds: finalTimeOut),
        onTimeout: () {
          return http.Response(addedErrorMessage(), 408);
        },
      );
    }

    if (response.statusCode == 401) {
      
    }
    
    return response; 
  }

  ///Multipart http request for image with from data
  // Future<http.Response> multipartHttpRequest({
  //   required String apiRequestType,
  //   required String url,
  //   required Map<String, String> fields, //?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>old is String
  //   required Map<String, MultipartFileWithName> filePaths,
  //   required String? token,
  //   int? timeOut,
  // }) async {
  //   http.Response response;
  //   int finalTimeOut = timeOut ?? AppConstant.timeoutRequest;
  //   final multiPartRequest = http.MultipartRequest(apiRequestType, Uri.parse(url));

  //   fields.forEach((key, value) {
  //     multiPartRequest.fields[key] = value;
  //   });

  //   filePaths.forEach((key, value) async {
  //     multiPartRequest.files.add(
  //       await http.MultipartFile.fromPath(
  //         key,
  //         value.filePath ?? '', //?...............................................need tobe change according to recuirement.
  //         filename: value.fileName,
  //       ),
  //     );
  //   });

  //   multiPartRequest.headers.addAll(
  //     token != null ? multipartHeaderWithToken(token) : multipartHeaderWithoutToken(),
  //   );

  //   var request = await multiPartRequest.send().timeout(
  //     Duration(seconds: finalTimeOut),
  //     onTimeout: () {
  //       return streamTimeOutResponse(
  //         error: ErrorStrings.kServerTimeoutMessage,
  //       ); // Replace 500 with your http code.
  //     },
  //   );
  //   if (request.statusCode == 401) {
  //     ///refresh token automatic refresh
  //     /// and create the access token
  //     // String refreshToken = await UserSharedPreference.getString(SharedPreferenceHelper.refreshToken) ?? '';
  //     // String refreshToken = await sharedPrefRefreshToken.value ?? '';
  //     // if (refreshToken.isEmpty) {
  //     //   logMessage('logout;;;;;;;;;;;');
  //     //   onLogoutTapped();
  //     // }
  //     // final refreshResponse = await requestRefreshToken(timeOut: finalTimeOut, refreshToken: refreshToken);
  //     // if (refreshResponse.statusCode == 200) {
  //     //   Map js = jsonDecode(refreshResponse.body);
  //     //   String accessToken = js['access'] ?? '';
  //     //   String refreshToken = js['refresh'] ?? '';
  //     //   await sharedPrefAccessToken.updateValue(accessToken); //!-------------update access token
  //     //   await sharedPrefRefreshToken.updateValue(refreshToken); //!-------------update refresh token
  //       ///save another time of 401 code
  //       // VisitorType visitorType = await VisitorHelper().getVisitorType();
  //       // switch (visitorType) {
  //       //   case VisitorType.visitorRetailerUser:
  //       //     //sent data to firebase analytics
  //       //     UserSharedPreference.putString(SharedPreferenceHelper.accessToken, accessToken);
  //       //     break;
  //       //   case VisitorType.visitorSRUser:
  //       //     UserSharedPreference.putString(SharedPreferenceHelper.srToken, accessToken);
  //       //     break;
  //       //   case VisitorType.visitorDeliveryUser:
  //       //     UserSharedPreference.putString(SharedPreferenceHelper.srToken, accessToken);
  //       //     break;
  //       //   case VisitorType.visitorUnknown:
  //       //     break;
  //       // }
  //       // response = await multipartHttpRequest(
  //       //     apiRequestType: apiRequestType, url: url, fields: fields, filePaths: filePaths, token: accessToken, timeOut: timeOut);
  //     } 
  //   //   else if (refreshResponse.statusCode == 401) {
  //   //     response = refreshResponse;
  //   //     onLogoutTapped();
  //   //   } else {
  //   //     response = refreshResponse;
  //   //   }
  //   // } else {
  //   //   response = await http.Response.fromStream(request);
  //   // }
  //   // logMessage('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>abc = ${response.body}');

  //   // ///var streamToResponse = await http.Response.fromStream(request);
  //   return response;
  // }

  ///request refresh token and create new access token
  // Future<http.Response> requestRefreshToken({
  //   required int timeOut,
  //   required String refreshToken,
  // }) async {
  //   final body = {"refresh": refreshToken.toString()};
  //   logMessage('body...............${body}');
  //   final url = Uri.parse(ApiAccess.refreshTokenUrl);
  //   logMessage('====> Http Call: $url');
  //   http.Response request = await http
  //       .post(
  //     // Uri.parse(ApiAccess.refreshTokenUrl), //!-------------------------enter your refresh token url
  //     url,
  //     body: jsonEncode(body),
  //     headers: _mainHeaders,
  //   )
  //       .timeout(
  //     Duration(seconds: timeOut),
  //     onTimeout: () {
  //       return http.Response(addedErrorMessage(), 408); // Replace 500 with your http code.
  //     },
  //   );
  //       ///print output result log message
  //   log('====> Http Response: [${request.statusCode}] $url\n${utf8.decode(request.bodyBytes)}');
  //   return request;
  // }

  ///add server timeout error message
  String addedErrorMessage({String message = ErrorStrings.kServerTimeoutMessage}) {
    return '{"error": "$message"}';
  }

  http.StreamedResponse streamTimeOutResponse({
    required String error,
  }) {
    Map<String, dynamic> body = {
      'any': 'value',
      'error': error,
    };

    int statusCode = 408;
    String json = jsonEncode(body);

    return http.StreamedResponse(
      Stream.value(json.codeUnits),
      statusCode,
    );
  }

  //Get current user header
  static Map<String, String> currentUserHeader({String? token}) {
    Map<String, String> mainHeaders = {
      'Content-Type': 'application/json',
      'Vary': 'Accept',
      'Authorization': 'Bearer ${token ?? null}',
    };
    return mainHeaders;
  }

  static Map<String, String> multipartHeaderWithToken(String token) {
    Map<String, String> header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    return header;
  }

  static Map<String, String> multipartHeaderWithoutToken() {
    Map<String, String> header = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
    };
    return header;
  }
}
