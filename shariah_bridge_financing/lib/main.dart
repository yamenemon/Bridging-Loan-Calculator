import 'package:flutter/material.dart';
import 'package:shariah_bridge_financing/loan_calculator_screen.dart';

void main() {
  runApp(BridgingLoanApp());
}

class BridgingLoanApp extends StatelessWidget {
  const BridgingLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bridging Loan Calculator',
      home: LoanCalculatorScreen(),
    );
  }
}
