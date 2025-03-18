// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/flutter_flow/flutter_flow_widgets.dart';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// import 'verification_page_model.dart';
// export 'verification_page_model.dart';
//
// class VerificationPageWidget extends StatefulWidget {
//   const VerificationPageWidget({super.key});
//
//   static String routeName = 'VerificationPage';
//   static String routePath = '/verificationPage';
//
//   @override
//   State<VerificationPageWidget> createState() => _VerificationPageWidgetState();
// }
//
// class _VerificationPageWidgetState extends State<VerificationPageWidget> {
//   late VerificationPageModel _model;
//
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => VerificationPageModel());
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
//           padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
//           child: SingleChildScrollView(
//             primary: false,
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 200,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                   child: Image.network(
//                     '',
//                     width: 200,
//                     height: 200,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 Column(
//                   mainAxisSize: MainAxisSize.max,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Verify Your Email',
//                       style: FlutterFlowTheme.of(context).displaySmall.override(
//                             fontFamily: 'Inter Tight',
//                             letterSpacing: 0.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     Text(
//                       'We\'ve sent a verification link to your university email',
//                       textAlign: TextAlign.center,
//                       style: FlutterFlowTheme.of(context).bodyLarge.override(
//                             fontFamily: 'Inter',
//                             color: FlutterFlowTheme.of(context).secondaryText,
//                             letterSpacing: 0.0,
//                           ),
//                     ),
//                   ].divide(SizedBox(height: 12)),
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
//                       padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 width: 60,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFE8F5E9),
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                                 child: Icon(
//                                   Icons.mark_email_read,
//                                   color: Color(0xFF2E7D32),
//                                   size: 30,
//                                 ),
//                               ),
//                             ].divide(SizedBox(width: 8)),
//                           ),
//                           Text(
//                             'Check your inbox for the verification email',
//                             textAlign: TextAlign.center,
//                             style:
//                                 FlutterFlowTheme.of(context).bodyLarge.override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                           ),
//                           Container(
//                             width: MediaQuery.sizeOf(context).width,
//                             decoration: BoxDecoration(
//                               color: Color(0xFFF5F5F5),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Padding(
//                               padding: EdgeInsetsDirectional.fromSTEB(
//                                   16, 16, 16, 16),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Text(
//                                     'Code expires in:',
//                                     style: FlutterFlowTheme.of(context)
//                                         .bodyMedium
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color: FlutterFlowTheme.of(context)
//                                               .secondaryText,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                   Text(
//                                     '04:59',
//                                     style: FlutterFlowTheme.of(context)
//                                         .headlineMedium
//                                         .override(
//                                           fontFamily: 'Inter Tight',
//                                           color: Color(0xFF1A2980),
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ].divide(SizedBox(height: 8)),
//                               ),
//                             ),
//                           ),
//                           FFButtonWidget(
//                             onPressed: () {
//                               print('Button pressed ...');
//                             },
//                             text: 'Resend Code',
//                             options: FFButtonOptions(
//                               width: MediaQuery.sizeOf(context).width,
//                               height: 48,
//                               padding: EdgeInsets.all(8),
//                               iconPadding:
//                                   EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
//                               color: Color(0x00FFFFFF),
//                               textStyle: FlutterFlowTheme.of(context)
//                                   .titleSmall
//                                   .override(
//                                     fontFamily: 'Inter Tight',
//                                     color: Color(0xFF1A2980),
//                                     letterSpacing: 0.0,
//                                   ),
//                               elevation: 0,
//                               borderSide: BorderSide(
//                                 color: Color(0xFF1A2980),
//                                 width: 1,
//                               ),
//                               borderRadius: BorderRadius.circular(24),
//                             ),
//                           ),
//                         ].divide(SizedBox(height: 20)),
//                       ),
//                     ),
//                   ),
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
//                       padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Text(
//                             'Verification Progress',
//                             style: FlutterFlowTheme.of(context)
//                                 .headlineSmall
//                                 .override(
//                                   fontFamily: 'Inter Tight',
//                                   letterSpacing: 0.0,
//                                 ),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFE8F5E9),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFE8F5E9),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFF5F5F5),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                               ),
//                             ].divide(SizedBox(width: 8)),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   'Account',
//                                   textAlign: TextAlign.center,
//                                   style: FlutterFlowTheme.of(context)
//                                       .bodySmall
//                                       .override(
//                                         fontFamily: 'Inter',
//                                         color: Color(0xFF2E7D32),
//                                         letterSpacing: 0.0,
//                                       ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   'Email',
//                                   textAlign: TextAlign.center,
//                                   style: FlutterFlowTheme.of(context)
//                                       .bodySmall
//                                       .override(
//                                         fontFamily: 'Inter',
//                                         color: Color(0xFF2E7D32),
//                                         letterSpacing: 0.0,
//                                       ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   'Complete',
//                                   textAlign: TextAlign.center,
//                                   style: FlutterFlowTheme.of(context)
//                                       .bodySmall
//                                       .override(
//                                         fontFamily: 'Inter',
//                                         color: FlutterFlowTheme.of(context)
//                                             .secondaryText,
//                                         letterSpacing: 0.0,
//                                       ),
//                                 ),
//                               ),
//                             ].divide(SizedBox(width: 8)),
//                           ),
//                         ].divide(SizedBox(height: 16)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Text(
//                   'Change Email Address',
//                   style: FlutterFlowTheme.of(context).bodyMedium.override(
//                         fontFamily: 'Inter',
//                         color: Color(0xFF1A2980),
//                         letterSpacing: 0.0,
//                       ),
//                 ),
//                 FFButtonWidget(
//                   onPressed: () {
//                     print('Button pressed ...');
//                   },
//                   text: 'Continue',
//                   options: FFButtonOptions(
//                     width: MediaQuery.sizeOf(context).width,
//                     height: 56,
//                     padding: EdgeInsets.all(8),
//                     iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
//                     color: Color(0xFF1A2980),
//                     textStyle:
//                         FlutterFlowTheme.of(context).titleMedium.override(
//                               fontFamily: 'Inter Tight',
//                               color: Colors.white,
//                               letterSpacing: 0.0,
//                             ),
//                     elevation: 2,
//                     borderRadius: BorderRadius.circular(28),
//                   ),
//                 ),
//               ].divide(SizedBox(height: 32)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
