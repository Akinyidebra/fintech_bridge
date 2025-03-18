// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/flutter_flow/flutter_flow_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// import 'login_page_model.dart';
// export 'login_page_model.dart';
//
// class LoginPageWidget extends StatefulWidget {
//   const LoginPageWidget({super.key});
//
//   static String routeName = 'LoginPage';
//   static String routePath = '/loginPage';
//
//   @override
//   State<LoginPageWidget> createState() => _LoginPageWidgetState();
// }
//
// class _LoginPageWidgetState extends State<LoginPageWidget> {
//   late LoginPageModel _model;
//
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => LoginPageModel());
//
//     _model.textController1 ??= TextEditingController();
//     _model.textFieldFocusNode1 ??= FocusNode();
//
//     _model.textController2 ??= TextEditingController();
//     _model.textFieldFocusNode2 ??= FocusNode();
//   }
//
//   @override
//   void dispose() {
//     _model.dispose();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
//         body: Padding(
//           padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
//           child: SingleChildScrollView(
//             primary: false,
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 140,
//                   height: 140,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(70),
//                   ),
//                   child: Image.network(
//                     '',
//                     width: 140,
//                     height: 140,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 Column(
//                   mainAxisSize: MainAxisSize.max,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Welcome Back',
//                       style: FlutterFlowTheme.of(context).displaySmall.override(
//                             fontFamily: 'Inter Tight',
//                             letterSpacing: 0.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     Text(
//                       'Sign in to access your student loans',
//                       style: FlutterFlowTheme.of(context).bodyLarge.override(
//                             fontFamily: 'Inter',
//                             color: FlutterFlowTheme.of(context).secondaryText,
//                             letterSpacing: 0.0,
//                           ),
//                     ),
//                   ].divide(const SizedBox(height: 12)),
//                 ),
//                 Material(
//                   color: Colors.transparent,
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Container(
//                     width: MediaQuery.sizeOf(context).width,
//                     decoration: BoxDecoration(
//                       color: FlutterFlowTheme.of(context).secondaryBackground,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           TextFormField(
//                             controller: _model.textController1,
//                             focusNode: _model.textFieldFocusNode1,
//                             autofocus: false,
//                             obscureText: false,
//                             decoration: InputDecoration(
//                               labelText: 'University Email',
//                               labelStyle: FlutterFlowTheme.of(context)
//                                   .bodyMedium
//                                   .override(
//                                     fontFamily: 'Inter',
//                                     letterSpacing: 0.0,
//                                   ),
//                               hintStyle: FlutterFlowTheme.of(context)
//                                   .bodyMedium
//                                   .override(
//                                     fontFamily: 'Inter',
//                                     letterSpacing: 0.0,
//                                   ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0xFFE0E0E0),
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0x00000000),
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0x00000000),
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               focusedErrorBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0x00000000),
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               filled: true,
//                               fillColor: FlutterFlowTheme.of(context)
//                                   .secondaryBackground,
//                               prefixIcon: const Icon(
//                                 Icons.mail,
//                               ),
//                             ),
//                             style:
//                                 FlutterFlowTheme.of(context).bodyLarge.override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                             minLines: 1,
//                             keyboardType: TextInputType.emailAddress,
//                             validator: _model.textController1Validator
//                                 .asValidator(context),
//                           ),
//                           TextFormField(
//                             controller: _model.textController2,
//                             focusNode: _model.textFieldFocusNode2,
//                             autofocus: false,
//                             obscureText: !_model.passwordVisibility,
//                             decoration: InputDecoration(
//                               labelText: 'Password',
//                               labelStyle: FlutterFlowTheme.of(context)
//                                   .bodyMedium
//                                   .override(
//                                     fontFamily: 'Inter',
//                                     letterSpacing: 0.0,
//                                   ),
//                               hintStyle: FlutterFlowTheme.of(context)
//                                   .bodyMedium
//                                   .override(
//                                     fontFamily: 'Inter',
//                                     letterSpacing: 0.0,
//                                   ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0xFFE0E0E0),
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0x00000000),
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0x00000000),
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               focusedErrorBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Color(0x00000000),
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               filled: true,
//                               fillColor: FlutterFlowTheme.of(context)
//                                   .secondaryBackground,
//                               prefixIcon: const Icon(
//                                 Icons.lock,
//                               ),
//                               suffixIcon: InkWell(
//                                 onTap: () => safeSetState(
//                                   () => _model.passwordVisibility =
//                                       !_model.passwordVisibility,
//                                 ),
//                                 focusNode: FocusNode(skipTraversal: true),
//                                 child: Icon(
//                                   _model.passwordVisibility
//                                       ? Icons.visibility_outlined
//                                       : Icons.visibility_off_outlined,
//                                   size: 22,
//                                 ),
//                               ),
//                             ),
//                             style:
//                                 FlutterFlowTheme.of(context).bodyLarge.override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                             minLines: 1,
//                             validator: _model.textController2Validator
//                                 .asValidator(context),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Text(
//                                 'Forgot Password?',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyMedium
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: const Color(0xFF1A2980),
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           FFButtonWidget(
//                             onPressed: () {
//                               print('Button pressed ...');
//                             },
//                             text: 'Log In',
//                             options: FFButtonOptions(
//                               width: MediaQuery.sizeOf(context).width,
//                               height: 56,
//                               padding: const EdgeInsets.all(8),
//                               iconPadding:
//                                   const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
//                               color: const Color(0xFF1A2980),
//                               textStyle: FlutterFlowTheme.of(context)
//                                   .titleMedium
//                                   .override(
//                                     fontFamily: 'Inter Tight',
//                                     color: Colors.white,
//                                     letterSpacing: 0.0,
//                                   ),
//                               elevation: 2,
//                               borderRadius: BorderRadius.circular(28),
//                             ),
//                           ),
//                         ].divide(const SizedBox(height: 20)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Don\'t have an account? ',
//                       style: FlutterFlowTheme.of(context).bodyMedium.override(
//                             fontFamily: 'Inter',
//                             color: FlutterFlowTheme.of(context).secondaryText,
//                             letterSpacing: 0.0,
//                           ),
//                     ),
//                     Text(
//                       'Register',
//                       style: FlutterFlowTheme.of(context).bodyMedium.override(
//                             fontFamily: 'Inter',
//                             color: const Color(0xFF1A2980),
//                             letterSpacing: 0.0,
//                             fontWeight: FontWeight.w600,
//                           ),
//                     ),
//                   ].divide(const SizedBox(width: 4)),
//                 ),
//                 SizedBox(
//                   width: MediaQuery.sizeOf(context).width,
//                   height: 200,
//                   child: Image.network(
//                     '',
//                     width: MediaQuery.sizeOf(context).width,
//                     height: 200,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ].divide(const SizedBox(height: 32)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
