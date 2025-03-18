// import '/flutter_flow/flutter_flow_icon_button.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/flutter_flow/flutter_flow_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// import 'home_page_model.dart';
// export 'home_page_model.dart';
//
// class HomePageWidget extends StatefulWidget {
//   const HomePageWidget({super.key});
//
//   static String routeName = 'HomePage';
//   static String routePath = '/homePage';
//
//   @override
//   State<HomePageWidget> createState() => _HomePageWidgetState();
// }
//
// class _HomePageWidgetState extends State<HomePageWidget> {
//   late HomePageModel _model;
//
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => HomePageModel());
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
//         body: SingleChildScrollView(
//           primary: false,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                   child: Container(
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
//                         stops: [0, 1],
//                         begin: AlignmentDirectional(1, 0),
//                         end: AlignmentDirectional(-1, 0),
//                       ),
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(16),
//                         bottomRight: Radius.circular(16),
//                         topLeft: Radius.circular(0),
//                         topRight: Radius.circular(0),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 mainAxisSize: MainAxisSize.max,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Welcome back,',
//                                     style: FlutterFlowTheme.of(context)
//                                         .bodyMedium
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color:
//                                               FlutterFlowTheme.of(context).info,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                   Text(
//                                     'Sarah Johnson',
//                                     style: FlutterFlowTheme.of(context)
//                                         .headlineMedium
//                                         .override(
//                                           fontFamily: 'Inter Tight',
//                                           color:
//                                               FlutterFlowTheme.of(context).info,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Stack(
//                                     children: [
//                                       FlutterFlowIconButton(
//                                         borderColor: Colors.transparent,
//                                         borderRadius: 23,
//                                         buttonSize: 46,
//                                         fillColor: const Color(0x33FFFFFF),
//                                         icon: Icon(
//                                           Icons.notifications_rounded,
//                                           color:
//                                               FlutterFlowTheme.of(context).info,
//                                           size: 24,
//                                         ),
//                                         onPressed: () {
//                                           print('IconButton pressed ...');
//                                         },
//                                       ),
//                                       Align(
//                                         alignment:
//                                             const AlignmentDirectional(0.8, -0.2),
//                                         child: Container(
//                                           width: 20,
//                                           height: 20,
//                                           decoration: BoxDecoration(
//                                             color: FlutterFlowTheme.of(context)
//                                                 .error,
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                           ),
//                                           child: Align(
//                                             alignment:
//                                                 const AlignmentDirectional(0.5, 0.5),
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(8),
//                                               child: Text(
//                                                 '3',
//                                                 style:
//                                                     FlutterFlowTheme.of(context)
//                                                         .labelSmall
//                                                         .override(
//                                                           fontFamily: 'Inter',
//                                                           color: FlutterFlowTheme
//                                                                   .of(context)
//                                                               .info,
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Container(
//                                     width: 46,
//                                     height: 46,
//                                     decoration: BoxDecoration(
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryBackground,
//                                       borderRadius: BorderRadius.circular(23),
//                                     ),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(23),
//                                       child: Image.network(
//                                         '',
//                                         width: 46,
//                                         height: 46,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                 ].divide(const SizedBox(width: 16)),
//                               ),
//                             ].divide(const SizedBox(width: 8)),
//                           ),
//                         ].divide(const SizedBox(height: 12)),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
//                     child: Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: FlutterFlowTheme.of(context).secondaryBackground,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: FlutterFlowTheme.of(context).alternate,
//                           width: 1,
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Padding(
//                               padding:
//                                   const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     mainAxisSize: MainAxisSize.max,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Current Loan Status',
//                                         style: FlutterFlowTheme.of(context)
//                                             .headlineSmall
//                                             .override(
//                                               fontFamily: 'Inter Tight',
//                                               letterSpacing: 0.0,
//                                             ),
//                                       ),
//                                       Text(
//                                         'Active - In Good Standing',
//                                         style: FlutterFlowTheme.of(context)
//                                             .bodyMedium
//                                             .override(
//                                               fontFamily: 'Inter',
//                                               color:
//                                                   FlutterFlowTheme.of(context)
//                                                       .success,
//                                               letterSpacing: 0.0,
//                                             ),
//                                       ),
//                                     ],
//                                   ),
//                                   Container(
//                                     width: 60,
//                                     height: 60,
//                                     decoration: BoxDecoration(
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryBackground,
//                                     ),
//                                     child: Stack(
//                                       children: [
//                                         Container(
//                                           width: 60,
//                                           height: 60,
//                                           decoration: BoxDecoration(
//                                             color: FlutterFlowTheme.of(context)
//                                                 .alternate,
//                                             borderRadius:
//                                                 BorderRadius.circular(30),
//                                           ),
//                                         ),
//                                         Align(
//                                           alignment:
//                                               const AlignmentDirectional(0.5, 0.5),
//                                           child: Text(
//                                             '75%',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .labelMedium
//                                                 .override(
//                                                   fontFamily: 'Inter',
//                                                   color: FlutterFlowTheme.of(
//                                                           context)
//                                                       .primary,
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Text(
//                                     '\$250,000',
//                                     style: FlutterFlowTheme.of(context)
//                                         .displaySmall
//                                         .override(
//                                           fontFamily: 'Inter Tight',
//                                           color: FlutterFlowTheme.of(context)
//                                               .primaryText,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                   Text(
//                                     'Total Loan Amount',
//                                     style: FlutterFlowTheme.of(context)
//                                         .labelMedium
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ].divide(const SizedBox(height: 8)),
//                               ),
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: FlutterFlowTheme.of(context)
//                                       .primaryBackground,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(12),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.max,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Column(
//                                         mainAxisSize: MainAxisSize.max,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Next Payment Due',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .bodyMedium
//                                                 .override(
//                                                   fontFamily: 'Inter',
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                           Text(
//                                             'March 15, 2024',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .titleSmall
//                                                 .override(
//                                                   fontFamily: 'Inter Tight',
//                                                   color: FlutterFlowTheme.of(
//                                                           context)
//                                                       .primary,
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                         ],
//                                       ),
//                                       Column(
//                                         mainAxisSize: MainAxisSize.max,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             'Remaining Balance',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .bodyMedium
//                                                 .override(
//                                                   fontFamily: 'Inter',
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                           Text(
//                                             '\$187,500',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .titleSmall
//                                                 .override(
//                                                   fontFamily: 'Inter Tight',
//                                                   color: FlutterFlowTheme.of(
//                                                           context)
//                                                       .primary,
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                               child: FFButtonWidget(
//                                 onPressed: () {
//                                   print('Button pressed ...');
//                                 },
//                                 text: 'View Loan Details',
//                                 options: FFButtonOptions(
//                                   width: double.infinity,
//                                   height: 45,
//                                   padding: const EdgeInsets.all(8),
//                                   iconPadding: const EdgeInsetsDirectional.fromSTEB(
//                                       0, 0, 0, 0),
//                                   color: FlutterFlowTheme.of(context)
//                                       .secondaryBackground,
//                                   textStyle: FlutterFlowTheme.of(context)
//                                       .bodyMedium
//                                       .override(
//                                         fontFamily: 'Inter',
//                                         color: FlutterFlowTheme.of(context)
//                                             .primary,
//                                         letterSpacing: 0.0,
//                                       ),
//                                   elevation: 0,
//                                   borderSide: BorderSide(
//                                     color: FlutterFlowTheme.of(context).primary,
//                                     width: 2,
//                                   ),
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                               ),
//                             ),
//                           ].divide(const SizedBox(height: 16)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
//                           child: Text(
//                             'Quick Actions',
//                             style: FlutterFlowTheme.of(context)
//                                 .headlineSmall
//                                 .override(
//                                   fontFamily: 'Inter Tight',
//                                   letterSpacing: 0.0,
//                                 ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
//                           child: GridView(
//                             padding: EdgeInsets.zero,
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               crossAxisSpacing: 12,
//                               mainAxisSpacing: 12,
//                               childAspectRatio: 1,
//                             ),
//                             shrinkWrap: true,
//                             scrollDirection: Axis.vertical,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsetsDirectional.fromSTEB(
//                                     12, 12, 12, 12),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: FlutterFlowTheme.of(context)
//                                         .secondaryBackground,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: FlutterFlowTheme.of(context)
//                                           .alternate,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsetsDirectional.fromSTEB(
//                                         8, 8, 8, 8),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.account_balance_rounded,
//                                           color: FlutterFlowTheme.of(context)
//                                               .primary,
//                                           size: 32,
//                                         ),
//                                         Text(
//                                           'Apply for Loan',
//                                           textAlign: TextAlign.center,
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyMedium
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                       ].divide(const SizedBox(height: 8)),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsetsDirectional.fromSTEB(
//                                     12, 12, 12, 12),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: FlutterFlowTheme.of(context)
//                                         .secondaryBackground,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: FlutterFlowTheme.of(context)
//                                           .alternate,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsetsDirectional.fromSTEB(
//                                         8, 8, 8, 8),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.payments_rounded,
//                                           color: FlutterFlowTheme.of(context)
//                                               .primary,
//                                           size: 32,
//                                         ),
//                                         Text(
//                                           'Make Payment',
//                                           textAlign: TextAlign.center,
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyMedium
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                       ].divide(const SizedBox(height: 8)),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsetsDirectional.fromSTEB(
//                                     12, 12, 12, 12),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: FlutterFlowTheme.of(context)
//                                         .secondaryBackground,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: FlutterFlowTheme.of(context)
//                                           .alternate,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsetsDirectional.fromSTEB(
//                                         8, 8, 8, 8),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.history_rounded,
//                                           color: FlutterFlowTheme.of(context)
//                                               .primary,
//                                           size: 32,
//                                         ),
//                                         Text(
//                                           'View History',
//                                           textAlign: TextAlign.center,
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyMedium
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                       ].divide(const SizedBox(height: 8)),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ].divide(const SizedBox(height: 12)),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                   child: Card(
//                     clipBehavior: Clip.antiAliasWithSaveLayer,
//                     color: FlutterFlowTheme.of(context).secondaryBackground,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Padding(
//                             padding:
//                                 const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Loan Summary',
//                                   style: FlutterFlowTheme.of(context)
//                                       .headlineSmall
//                                       .override(
//                                         fontFamily: 'Inter Tight',
//                                         letterSpacing: 0.0,
//                                       ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       4, 8, 4, 8),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color:
//                                           FlutterFlowTheme.of(context).primary,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8),
//                                       child: Text(
//                                         '2024',
//                                         style: FlutterFlowTheme.of(context)
//                                             .labelMedium
//                                             .override(
//                                               fontFamily: 'Inter',
//                                               color:
//                                                   FlutterFlowTheme.of(context)
//                                                       .info,
//                                               letterSpacing: 0.0,
//                                             ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding:
//                                 const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 SizedBox(
//                                   width: 160,
//                                   height: 160,
//                                   child: Stack(
//                                     children: [
//                                       Container(
//                                         width: 160,
//                                         height: 160,
//                                         decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                             colors: [
//                                               FlutterFlowTheme.of(context)
//                                                   .primary,
//                                               FlutterFlowTheme.of(context)
//                                                   .secondary,
//                                               FlutterFlowTheme.of(context)
//                                                   .tertiary,
//                                               FlutterFlowTheme.of(context)
//                                                   .alternate
//                                             ],
//                                             stops: const [0, 0.35, 0.65, 1],
//                                             begin: const AlignmentDirectional(-1, 0),
//                                             end: const AlignmentDirectional(1, 0),
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(80),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 120,
//                                         height: 120,
//                                         decoration: BoxDecoration(
//                                           color: FlutterFlowTheme.of(context)
//                                               .secondaryBackground,
//                                           borderRadius:
//                                               BorderRadius.circular(60),
//                                         ),
//                                         child: Padding(
//                                           padding:
//                                               const EdgeInsetsDirectional.fromSTEB(
//                                                   12, 12, 12, 12),
//                                           child: Column(
//                                             mainAxisSize: MainAxisSize.max,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Text(
//                                                 '\$42,500',
//                                                 textAlign: TextAlign.center,
//                                                 style:
//                                                     FlutterFlowTheme.of(context)
//                                                         .headlineSmall
//                                                         .override(
//                                                           fontFamily:
//                                                               'Inter Tight',
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                               ),
//                                               Text(
//                                                 'Total Borrowed',
//                                                 textAlign: TextAlign.center,
//                                                 style:
//                                                     FlutterFlowTheme.of(context)
//                                                         .labelSmall
//                                                         .override(
//                                                           fontFamily: 'Inter',
//                                                           color: FlutterFlowTheme
//                                                                   .of(context)
//                                                               .secondaryText,
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         mainAxisSize: MainAxisSize.max,
//                                         children: [
//                                           Container(
//                                             width: 12,
//                                             height: 12,
//                                             decoration: BoxDecoration(
//                                               color:
//                                                   FlutterFlowTheme.of(context)
//                                                       .primary,
//                                               borderRadius:
//                                                   BorderRadius.circular(6),
//                                             ),
//                                           ),
//                                           Text(
//                                             'Student Loan - 45%',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .bodyMedium
//                                                 .override(
//                                                   fontFamily: 'Inter',
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                         ].divide(const SizedBox(width: 8)),
//                                       ),
//                                       Row(
//                                         mainAxisSize: MainAxisSize.max,
//                                         children: [
//                                           Container(
//                                             width: 12,
//                                             height: 12,
//                                             decoration: BoxDecoration(
//                                               color:
//                                                   FlutterFlowTheme.of(context)
//                                                       .secondary,
//                                               borderRadius:
//                                                   BorderRadius.circular(6),
//                                             ),
//                                           ),
//                                           Text(
//                                             'Car Loan - 30%',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .bodyMedium
//                                                 .override(
//                                                   fontFamily: 'Inter',
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                         ].divide(const SizedBox(width: 8)),
//                                       ),
//                                       Row(
//                                         mainAxisSize: MainAxisSize.max,
//                                         children: [
//                                           Container(
//                                             width: 12,
//                                             height: 12,
//                                             decoration: BoxDecoration(
//                                               color:
//                                                   FlutterFlowTheme.of(context)
//                                                       .tertiary,
//                                               borderRadius:
//                                                   BorderRadius.circular(6),
//                                             ),
//                                           ),
//                                           Text(
//                                             'Personal Loan - 15%',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .bodyMedium
//                                                 .override(
//                                                   fontFamily: 'Inter',
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                         ].divide(const SizedBox(width: 8)),
//                                       ),
//                                       Row(
//                                         mainAxisSize: MainAxisSize.max,
//                                         children: [
//                                           Container(
//                                             width: 12,
//                                             height: 12,
//                                             decoration: BoxDecoration(
//                                               color:
//                                                   FlutterFlowTheme.of(context)
//                                                       .alternate,
//                                               borderRadius:
//                                                   BorderRadius.circular(6),
//                                             ),
//                                           ),
//                                           Text(
//                                             'Credit Card - 10%',
//                                             style: FlutterFlowTheme.of(context)
//                                                 .bodyMedium
//                                                 .override(
//                                                   fontFamily: 'Inter',
//                                                   letterSpacing: 0.0,
//                                                 ),
//                                           ),
//                                         ].divide(const SizedBox(width: 8)),
//                                       ),
//                                     ].divide(const SizedBox(height: 8)),
//                                   ),
//                                 ),
//                               ].divide(const SizedBox(width: 16)),
//                             ),
//                           ),
//                           Padding(
//                             padding:
//                                 const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
//                             child: Container(
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 color: FlutterFlowTheme.of(context)
//                                     .primaryBackground,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(12),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Column(
//                                       mainAxisSize: MainAxisSize.max,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Next Payment',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyMedium
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                         Text(
//                                           '\$850.00',
//                                           style: FlutterFlowTheme.of(context)
//                                               .titleLarge
//                                               .override(
//                                                 fontFamily: 'Inter Tight',
//                                                 color:
//                                                     FlutterFlowTheme.of(context)
//                                                         .primary,
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                       ],
//                                     ),
//                                     Column(
//                                       mainAxisSize: MainAxisSize.max,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           'Due Date',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyMedium
//                                               .override(
//                                                 fontFamily: 'Inter',
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                         Text(
//                                           'Mar 15, 2024',
//                                           style: FlutterFlowTheme.of(context)
//                                               .titleSmall
//                                               .override(
//                                                 fontFamily: 'Inter Tight',
//                                                 color:
//                                                     FlutterFlowTheme.of(context)
//                                                         .error,
//                                                 letterSpacing: 0.0,
//                                               ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ].divide(const SizedBox(height: 12)),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                     child: Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: FlutterFlowTheme.of(context).secondaryBackground,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Repayment Schedule',
//                                   style: FlutterFlowTheme.of(context)
//                                       .headlineSmall
//                                       .override(
//                                         fontFamily: 'Inter Tight',
//                                         letterSpacing: 0.0,
//                                       ),
//                                 ),
//                                 Text(
//                                   'Total: \$12,450',
//                                   style: FlutterFlowTheme.of(context)
//                                       .bodyLarge
//                                       .override(
//                                         fontFamily: 'Inter',
//                                         color: FlutterFlowTheme.of(context)
//                                             .primary,
//                                         letterSpacing: 0.0,
//                                       ),
//                                 ),
//                               ],
//                             ),
//                             ListView(
//                               padding: EdgeInsets.zero,
//                               primary: false,
//                               shrinkWrap: true,
//                               scrollDirection: Axis.vertical,
//                               children: [
//                                 Container(
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                     color: FlutterFlowTheme.of(context)
//                                         .secondaryBackground,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                       color: FlutterFlowTheme.of(context)
//                                           .alternate,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsetsDirectional.fromSTEB(
//                                         12, 12, 12, 12),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Padding(
//                                           padding:
//                                               const EdgeInsetsDirectional.fromSTEB(
//                                                   12, 0, 12, 0),
//                                           child: Row(
//                                             mainAxisSize: MainAxisSize.max,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Column(
//                                                 mainAxisSize: MainAxisSize.max,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     'Payment #1',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .bodyLarge
//                                                         .override(
//                                                           fontFamily: 'Inter',
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                                   ),
//                                                   Text(
//                                                     'Due March 15, 2024',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .bodySmall
//                                                         .override(
//                                                           fontFamily: 'Inter',
//                                                           color: FlutterFlowTheme
//                                                                   .of(context)
//                                                               .secondaryText,
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsetsDirectional
//                                                     .fromSTEB(4, 8, 4, 8),
//                                                 child: Container(
//                                                   decoration: BoxDecoration(
//                                                     color: const Color(0x1A4CAF50),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             12),
//                                                   ),
//                                                   child: Padding(
//                                                     padding: const EdgeInsets.all(8),
//                                                     child: Text(
//                                                       'On Track',
//                                                       style: FlutterFlowTheme
//                                                               .of(context)
//                                                           .labelSmall
//                                                           .override(
//                                                             fontFamily: 'Inter',
//                                                             color: FlutterFlowTheme
//                                                                     .of(context)
//                                                                 .success,
//                                                             letterSpacing: 0.0,
//                                                           ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding:
//                                               const EdgeInsetsDirectional.fromSTEB(
//                                                   12, 0, 12, 0),
//                                           child: Container(
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.max,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   'Amount Due:',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .bodyMedium
//                                                       .override(
//                                                         fontFamily: 'Inter',
//                                                         letterSpacing: 0.0,
//                                                       ),
//                                                 ),
//                                                 Text(
//                                                   '\$2,075',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .bodyLarge
//                                                       .override(
//                                                         fontFamily: 'Inter',
//                                                         color:
//                                                             FlutterFlowTheme.of(
//                                                                     context)
//                                                                 .primary,
//                                                         letterSpacing: 0.0,
//                                                       ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                     color: FlutterFlowTheme.of(context)
//                                         .secondaryBackground,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                       color: FlutterFlowTheme.of(context)
//                                           .alternate,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsetsDirectional.fromSTEB(
//                                         12, 12, 12, 12),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Padding(
//                                           padding:
//                                               const EdgeInsetsDirectional.fromSTEB(
//                                                   12, 0, 12, 0),
//                                           child: Row(
//                                             mainAxisSize: MainAxisSize.max,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Column(
//                                                 mainAxisSize: MainAxisSize.max,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     'Payment #2',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .bodyLarge
//                                                         .override(
//                                                           fontFamily: 'Inter',
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                                   ),
//                                                   Text(
//                                                     'Due April 15, 2024',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .bodySmall
//                                                         .override(
//                                                           fontFamily: 'Inter',
//                                                           color: FlutterFlowTheme
//                                                                   .of(context)
//                                                               .secondaryText,
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsetsDirectional
//                                                     .fromSTEB(4, 8, 4, 8),
//                                                 child: Container(
//                                                   decoration: BoxDecoration(
//                                                     color: const Color(0x1A4CAF50),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             12),
//                                                   ),
//                                                   child: Padding(
//                                                     padding: const EdgeInsets.all(8),
//                                                     child: Text(
//                                                       'On Track',
//                                                       style: FlutterFlowTheme
//                                                               .of(context)
//                                                           .labelSmall
//                                                           .override(
//                                                             fontFamily: 'Inter',
//                                                             color: FlutterFlowTheme
//                                                                     .of(context)
//                                                                 .success,
//                                                             letterSpacing: 0.0,
//                                                           ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding:
//                                               const EdgeInsetsDirectional.fromSTEB(
//                                                   12, 0, 12, 0),
//                                           child: Container(
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.max,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   'Amount Due:',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .bodyMedium
//                                                       .override(
//                                                         fontFamily: 'Inter',
//                                                         letterSpacing: 0.0,
//                                                       ),
//                                                 ),
//                                                 Text(
//                                                   '\$2,075',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .bodyLarge
//                                                       .override(
//                                                         fontFamily: 'Inter',
//                                                         color:
//                                                             FlutterFlowTheme.of(
//                                                                     context)
//                                                                 .primary,
//                                                         letterSpacing: 0.0,
//                                                       ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                     color: FlutterFlowTheme.of(context)
//                                         .secondaryBackground,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                       color: FlutterFlowTheme.of(context)
//                                           .alternate,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsetsDirectional.fromSTEB(
//                                         12, 12, 12, 12),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Padding(
//                                           padding:
//                                               const EdgeInsetsDirectional.fromSTEB(
//                                                   12, 0, 12, 0),
//                                           child: Row(
//                                             mainAxisSize: MainAxisSize.max,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Column(
//                                                 mainAxisSize: MainAxisSize.max,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     'Payment #3',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .bodyLarge
//                                                         .override(
//                                                           fontFamily: 'Inter',
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                                   ),
//                                                   Text(
//                                                     'Due May 15, 2024',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .bodySmall
//                                                         .override(
//                                                           fontFamily: 'Inter',
//                                                           color: FlutterFlowTheme
//                                                                   .of(context)
//                                                               .secondaryText,
//                                                           letterSpacing: 0.0,
//                                                         ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsetsDirectional
//                                                     .fromSTEB(4, 8, 4, 8),
//                                                 child: Container(
//                                                   decoration: BoxDecoration(
//                                                     color: const Color(0x1AFF5963),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             12),
//                                                   ),
//                                                   child: Padding(
//                                                     padding: const EdgeInsets.all(8),
//                                                     child: Text(
//                                                       'At Risk',
//                                                       style: FlutterFlowTheme
//                                                               .of(context)
//                                                           .labelSmall
//                                                           .override(
//                                                             fontFamily: 'Inter',
//                                                             color: FlutterFlowTheme
//                                                                     .of(context)
//                                                                 .error,
//                                                             letterSpacing: 0.0,
//                                                           ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding:
//                                               const EdgeInsetsDirectional.fromSTEB(
//                                                   12, 0, 12, 0),
//                                           child: Container(
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.max,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   'Amount Due:',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .bodyMedium
//                                                       .override(
//                                                         fontFamily: 'Inter',
//                                                         letterSpacing: 0.0,
//                                                       ),
//                                                 ),
//                                                 Text(
//                                                   '\$2,075',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .bodyLarge
//                                                       .override(
//                                                         fontFamily: 'Inter',
//                                                         color:
//                                                             FlutterFlowTheme.of(
//                                                                     context)
//                                                                 .primary,
//                                                         letterSpacing: 0.0,
//                                                       ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ].divide(const SizedBox(height: 8)),
//                             ),
//                           ].divide(const SizedBox(height: 12)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
//                 child: Container(
//                   width: double.infinity,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: FlutterFlowTheme.of(context).secondaryBackground,
//                     boxShadow: const [
//                       BoxShadow(
//                         blurRadius: 3,
//                         color: Color(0x33000000),
//                         offset: Offset(
//                           0,
//                           -1,
//                         ),
//                         spreadRadius: 0,
//                       )
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           mainAxisSize: MainAxisSize.max,
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       8, 0, 8, 0),
//                                   child: Container(
//                                     width: 56,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color:
//                                           FlutterFlowTheme.of(context).primary,
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Icon(
//                                       Icons.home_rounded,
//                                       color: FlutterFlowTheme.of(context).info,
//                                       size: 24,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       8, 0, 8, 0),
//                                   child: Text(
//                                     'Home',
//                                     style: FlutterFlowTheme.of(context)
//                                         .labelSmall
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color: FlutterFlowTheme.of(context)
//                                               .primary,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ),
//                               ].divide(const SizedBox(height: 4)),
//                             ),
//                             Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       8, 0, 8, 0),
//                                   child: Container(
//                                     width: 56,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryBackground,
//                                     ),
//                                     child: Icon(
//                                       Icons.account_balance_rounded,
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       size: 24,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       8, 0, 8, 0),
//                                   child: Text(
//                                     'Loans',
//                                     style: FlutterFlowTheme.of(context)
//                                         .labelSmall
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color: FlutterFlowTheme.of(context)
//                                               .secondaryText,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ),
//                               ].divide(const SizedBox(height: 4)),
//                             ),
//                             Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       8, 0, 8, 0),
//                                   child: Container(
//                                     width: 56,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryBackground,
//                                     ),
//                                     child: Icon(
//                                       Icons.payments_rounded,
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       size: 24,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       8, 0, 8, 0),
//                                   child: Text(
//                                     'Payments',
//                                     style: FlutterFlowTheme.of(context)
//                                         .labelSmall
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color: FlutterFlowTheme.of(context)
//                                               .secondaryText,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ),
//                               ].divide(const SizedBox(height: 4)),
//                             ),
//                             Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       8, 0, 8, 0),
//                                   child: Container(
//                                     width: 56,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryBackground,
//                                     ),
//                                     child: Icon(
//                                       Icons.person_rounded,
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       size: 24,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsetsDirectional.fromSTEB(
//                                       8, 0, 8, 0),
//                                   child: Text(
//                                     'Profile',
//                                     style: FlutterFlowTheme.of(context)
//                                         .labelSmall
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color: FlutterFlowTheme.of(context)
//                                               .secondaryText,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ),
//                               ].divide(const SizedBox(height: 4)),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ].divide(const SizedBox(height: 24)),
//           ),
//         ),
//       ),
//     );
//   }
// }
