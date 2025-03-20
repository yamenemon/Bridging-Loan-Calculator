import 'package:flutter/material.dart';
import 'package:shariah_bridge_financing/loan_calculator_screen.dart';

void main() {
  runApp(BridgingLoanApp());
}

class BridgingLoanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bridging Loan Calculator',
      home: LoanCalculatorScreen(),
    );
  }
}
