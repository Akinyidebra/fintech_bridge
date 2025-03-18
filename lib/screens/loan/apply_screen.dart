// import '/flutter_flow/flutter_flow_choice_chips.dart';
// import '/flutter_flow/flutter_flow_icon_button.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/flutter_flow/flutter_flow_widgets.dart';
// import '/flutter_flow/form_field_controller.dart';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// import 'loan_application_page_model.dart';
// export 'loan_application_page_model.dart';
//
// class LoanApplicationPageWidget extends StatefulWidget {
//   const LoanApplicationPageWidget({super.key});
//
//   static String routeName = 'LoanApplicationPage';
//   static String routePath = '/loanApplicationPage';
//
//   @override
//   State<LoanApplicationPageWidget> createState() =>
//       _LoanApplicationPageWidgetState();
// }
//
// class _LoanApplicationPageWidgetState extends State<LoanApplicationPageWidget> {
//   late LoanApplicationPageModel _model;
//
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => LoanApplicationPageModel());
//
//     WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
//                 Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'New Loan Application',
//                       style: FlutterFlowTheme.of(context).displaySmall.override(
//                             fontFamily: 'Inter Tight',
//                             letterSpacing: 0.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     FFButtonWidget(
//                       onPressed: () {
//                         print('Button pressed ...');
//                       },
//                       text: 'Save Draft',
//                       options: FFButtonOptions(
//                         width: 120,
//                         height: 40,
//                         padding: EdgeInsets.all(8),
//                         iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
//                         color: Color(0x00FFFFFF),
//                         textStyle:
//                             FlutterFlowTheme.of(context).bodyMedium.override(
//                                   fontFamily: 'Inter',
//                                   color: Color(0xFF1A2980),
//                                   letterSpacing: 0.0,
//                                 ),
//                         elevation: 0,
//                         borderSide: BorderSide(
//                           color: Color(0xFF1A2980),
//                           width: 1,
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   'Step 1: Loan Details',
//                   style: FlutterFlowTheme.of(context).headlineSmall.override(
//                         fontFamily: 'Inter Tight',
//                         color: FlutterFlowTheme.of(context).secondaryText,
//                         letterSpacing: 0.0,
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
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Progress',
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
//                                 '1 of 3',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyMedium
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: Color(0xFF1A2980),
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFF1A2980),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFE0E0E0),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFE0E0E0),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                               ),
//                             ].divide(SizedBox(width: 8)),
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
//                           Column(
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Text(
//                                     'Loan Amount',
//                                     style: FlutterFlowTheme.of(context)
//                                         .headlineSmall
//                                         .override(
//                                           fontFamily: 'Inter Tight',
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                   FlutterFlowIconButton(
//                                     buttonSize: 24,
//                                     icon: Icon(
//                                       Icons.info_outline,
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       size: 18,
//                                     ),
//                                     onPressed: () {
//                                       print('IconButton pressed ...');
//                                     },
//                                   ),
//                                 ].divide(SizedBox(width: 8)),
//                               ),
//                               Text(
//                                 '\$5,000',
//                                 style: FlutterFlowTheme.of(context)
//                                     .displaySmall
//                                     .override(
//                                       fontFamily: 'Inter Tight',
//                                       color: Color(0xFF1A2980),
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Container(
//                                 width: double.infinity,
//                                 child: Slider(
//                                   activeColor: Color(0xFF1A2980),
//                                   inactiveColor: Color(0xFFE0E0E0),
//                                   min: 1000,
//                                   max: 10000,
//                                   value: _model.sliderValue ??= 5000,
//                                   onChanged: (newValue) {
//                                     newValue = double.parse(
//                                         newValue.toStringAsFixed(4));
//                                     safeSetState(
//                                         () => _model.sliderValue = newValue);
//                                   },
//                                 ),
//                               ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '\$1,000',
//                                     style: FlutterFlowTheme.of(context)
//                                         .bodySmall
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color: FlutterFlowTheme.of(context)
//                                               .secondaryText,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                   Text(
//                                     '\$10,000',
//                                     style: FlutterFlowTheme.of(context)
//                                         .bodySmall
//                                         .override(
//                                           fontFamily: 'Inter',
//                                           color: FlutterFlowTheme.of(context)
//                                               .secondaryText,
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                 ],
//                               ),
//                             ].divide(SizedBox(height: 8)),
//                           ),
//                           Column(
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Text(
//                                     'Loan Purpose',
//                                     style: FlutterFlowTheme.of(context)
//                                         .headlineSmall
//                                         .override(
//                                           fontFamily: 'Inter Tight',
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                   FlutterFlowIconButton(
//                                     buttonSize: 24,
//                                     icon: Icon(
//                                       Icons.info_outline,
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       size: 18,
//                                     ),
//                                     onPressed: () {
//                                       print('IconButton pressed ...');
//                                     },
//                                   ),
//                                 ].divide(SizedBox(width: 8)),
//                               ),
//                               Container(
//                                 width: MediaQuery.sizeOf(context).width,
//                                 decoration: BoxDecoration(
//                                   color: FlutterFlowTheme.of(context)
//                                       .secondaryBackground,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: Color(0xFFE0E0E0),
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       16, 16, 16, 16),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.max,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Select Purpose',
//                                         style: FlutterFlowTheme.of(context)
//                                             .bodyLarge
//                                             .override(
//                                               fontFamily: 'Inter',
//                                               letterSpacing: 0.0,
//                                             ),
//                                       ),
//                                       Icon(
//                                         Icons.keyboard_arrow_down,
//                                         color: FlutterFlowTheme.of(context)
//                                             .secondaryText,
//                                         size: 24,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ].divide(SizedBox(height: 8)),
//                           ),
//                           Column(
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Text(
//                                     'Loan Duration',
//                                     style: FlutterFlowTheme.of(context)
//                                         .headlineSmall
//                                         .override(
//                                           fontFamily: 'Inter Tight',
//                                           letterSpacing: 0.0,
//                                         ),
//                                   ),
//                                   FlutterFlowIconButton(
//                                     buttonSize: 24,
//                                     icon: Icon(
//                                       Icons.info_outline,
//                                       color: FlutterFlowTheme.of(context)
//                                           .secondaryText,
//                                       size: 18,
//                                     ),
//                                     onPressed: () {
//                                       print('IconButton pressed ...');
//                                     },
//                                   ),
//                                 ].divide(SizedBox(width: 8)),
//                               ),
//                               FlutterFlowChoiceChips(
//                                 options: [
//                                   ChipData('1 Month'),
//                                   ChipData('2 Months'),
//                                   ChipData('3 Months'),
//                                   ChipData('4 Months'),
//                                   ChipData('5 Months'),
//                                   ChipData('6 Months')
//                                 ],
//                                 onChanged: (val) => safeSetState(() =>
//                                     _model.choiceChipsValue = val?.firstOrNull),
//                                 selectedChipStyle: ChipStyle(
//                                   backgroundColor: Color(0xFF1A2980),
//                                   textStyle: FlutterFlowTheme.of(context)
//                                       .bodyMedium
//                                       .override(
//                                         fontFamily: 'Inter',
//                                         color:
//                                             FlutterFlowTheme.of(context).info,
//                                         letterSpacing: 0.0,
//                                       ),
//                                   iconColor:
//                                       FlutterFlowTheme.of(context).primaryText,
//                                   iconSize: 18,
//                                   elevation: 0,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 unselectedChipStyle: ChipStyle(
//                                   backgroundColor: FlutterFlowTheme.of(context)
//                                       .secondaryBackground,
//                                   textStyle: FlutterFlowTheme.of(context)
//                                       .bodySmall
//                                       .override(
//                                         fontFamily: 'Inter',
//                                         color: FlutterFlowTheme.of(context)
//                                             .secondaryText,
//                                         letterSpacing: 0.0,
//                                       ),
//                                   iconColor:
//                                       FlutterFlowTheme.of(context).primaryText,
//                                   iconSize: 18,
//                                   elevation: 0,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 chipSpacing: 8,
//                                 rowSpacing: 8,
//                                 multiselect: false,
//                                 alignment: WrapAlignment.start,
//                                 controller:
//                                     _model.choiceChipsValueController ??=
//                                         FormFieldController<List<String>>(
//                                   [],
//                                 ),
//                                 wrapped: true,
//                               ),
//                             ].divide(SizedBox(height: 8)),
//                           ),
//                         ].divide(SizedBox(height: 24)),
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
//                             'Loan Summary',
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
//                                 'Monthly Payment',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Text(
//                                 '\$865.83',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: Color(0xFF1A2980),
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
//                                 'Interest Rate',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Text(
//                                 '3.9% APR',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: Color(0xFF1A2980),
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
//                                 'Total Repayment',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       letterSpacing: 0.0,
//                                     ),
//                               ),
//                               Text(
//                                 '\$5,194.98',
//                                 style: FlutterFlowTheme.of(context)
//                                     .bodyLarge
//                                     .override(
//                                       fontFamily: 'Inter',
//                                       color: Color(0xFF1A2980),
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
//                 FFButtonWidget(
//                   onPressed: () {
//                     print('Button pressed ...');
//                   },
//                   text: 'Next Step',
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
