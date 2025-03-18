// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/flutter_flow/flutter_flow_widgets.dart';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// import 'loan_status_page_model.dart';
// export 'loan_status_page_model.dart';
//
// class LoanStatusPageWidget extends StatefulWidget {
//   const LoanStatusPageWidget({super.key});
//
//   static String routeName = 'LoanStatusPage';
//   static String routePath = '/loanStatusPage';
//
//   @override
//   State<LoanStatusPageWidget> createState() => _LoanStatusPageWidgetState();
// }
//
// class _LoanStatusPageWidgetState extends State<LoanStatusPageWidget> {
//   late LoanStatusPageModel _model;
//
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => LoanStatusPageModel());
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
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Loan Status',
//                   style: FlutterFlowTheme.of(context).displaySmall.override(
//                         fontFamily: 'Inter Tight',
//                         letterSpacing: 0.0,
//                         fontWeight: FontWeight.bold,
//                       ),
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
//                             'Application Progress',
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
//                                     color: Color(0xFFFFF8E1),
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
//                                   'Applied',
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
//                                   'Under Review',
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
//                                   'Approved',
//                                   textAlign: TextAlign.center,
//                                   style: FlutterFlowTheme.of(context)
//                                       .bodySmall
//                                       .override(
//                                         fontFamily: 'Inter',
//                                         color: Color(0xFFFF6F00),
//                                         letterSpacing: 0.0,
//                                       ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   'Disbursed',
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
//                             'Loan Details',
//                             style: FlutterFlowTheme.of(context)
//                                 .headlineSmall
//                                 .override(
//                                   fontFamily: 'Inter Tight',
//                                   letterSpacing: 0.0,
//                                 ),
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Loan Amount',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyMedium
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Text(
//                                 '\$25,000',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Purpose',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyMedium
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Text(
//                                 'Education',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Application Date',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyMedium
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Text(
//                                 'June 15, 2023',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Expected Disbursement',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyMedium
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Text(
//                                 'July 1, 2023',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Repayment Terms',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyMedium
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Text(
//                                 '60 months',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                             ],
//                           ),
//                         ].divide(SizedBox(height: 16)),
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
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Current Stage',
//                                 style: FlutterFlowTheme.of(context)
//                                     .headlineSmall
//                                     .override(
//                                       fontFamily: 'Inter Tight',
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFFFF8E1),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       8, 16, 8, 16),
//                                   child: Text(
//                                     'Under Review',
//                                     style: FlutterFlowTheme.of(context)
//                                         .bodyMedium
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color: Color(0xFFFF6F00),
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             'Your application is currently being reviewed by our loan committee. This process typically takes 3-5 business days. We\'ll notify you once a decision has been made.',
//                             style: FlutterFlowTheme.of(context)
//                                 .bodyMedium
//                                 .override(
//                                   fontFamily: 'Inter',
//                                   color: FlutterFlowTheme.of(context)
//                                       .secondaryText,
//                                   letterSpacing: 0.0,
//                                 ),
//                           ),
//                           FFButtonWidget(
//                             onPressed: () {
//                               print('Button pressed ...');
//                             },
//                             text: 'View Full Application',
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
//                         ].divide(SizedBox(height: 16)),
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
//                             'Application Updates',
//                             style: FlutterFlowTheme.of(context)
//                                 .headlineSmall
//                                 .override(
//                                   fontFamily: 'Inter Tight',
//                                   letterSpacing: 0.0,
//                                 ),
//                           ),
//                           Column(
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Container(
//                                     width: 40,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: Color(0xFFE8F5E9),
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Icon(
//                                       Icons.check_circle,
//                                       color: Color(0xFF2E7D32),
//                                       size: 24,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.max,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Application Submitted',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyLarge
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                         Text(
//                                           'June 15, 2023 - 9:30 AM',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodySmall
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 color:
//                                                     FlutterFlowTheme.of(context)
//                                                         .secondaryText,
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ].divide(SizedBox(width: 12)),
//                               ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Container(
//                                     width: 40,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: Color(0xFFE8F5E9),
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Icon(
//                                       Icons.check_circle,
//                                       color: Color(0xFF2E7D32),
//                                       size: 24,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.max,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Document Verification Complete',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyLarge
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                         Text(
//                                           'June 16, 2023 - 2:15 PM',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodySmall
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 color:
//                                                     FlutterFlowTheme.of(context)
//                                                         .secondaryText,
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ].divide(SizedBox(width: 12)),
//                               ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Container(
//                                     width: 40,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: Color(0xFFFFF8E1),
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Icon(
//                                       Icons.pending,
//                                       color: Color(0xFFFF6F00),
//                                       size: 24,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.max,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Under Committee Review',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyLarge
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                         Text(
//                                           'June 17, 2023 - 10:45 AM',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodySmall
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 color:
//                                                     FlutterFlowTheme.of(context)
//                                                         .secondaryText,
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ].divide(SizedBox(width: 12)),
//                               ),
//                             ].divide(SizedBox(height: 16)),
//                           ),
//                         ].divide(SizedBox(height: 16)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 FFButtonWidget(
//                   onPressed: () {
//                     print('Button pressed ...');
//                   },
//                   text: 'Contact Support',
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
//               ].divide(SizedBox(height: 24)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
