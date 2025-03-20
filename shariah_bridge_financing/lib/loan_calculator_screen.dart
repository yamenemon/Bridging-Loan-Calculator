import 'package:flutter/material.dart';
import 'package:shariah_bridge_financing/bridge_financing_calculator.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoanCalculatorScreenState createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final TextEditingController loanAmountController =
      TextEditingController(text: "1000000");
  final TextEditingController propertyValueController =
      TextEditingController(text: "3000000");
  final TextEditingController mortgageBalanceController =
      TextEditingController(text: "10000");
  final TextEditingController monthlyInterestController =
      TextEditingController(text: "0.55");
  final TextEditingController facilityFeeController =
      TextEditingController(text: "2");
  final TextEditingController exitFeeController =
      TextEditingController(text: "1");
  final TextEditingController loanTermController =
      TextEditingController(text: "12");

  Map<String, dynamic>? result;

  void calculate() {
    BridgingLoanCalculator calculator = BridgingLoanCalculator(
      loanAmount: double.tryParse(loanAmountController.text) ?? 0,
      monthlyInterestRate: double.tryParse(monthlyInterestController.text) ?? 0,
      facilityFeeRate: double.tryParse(facilityFeeController.text) ?? 0,
      propertyValue: double.tryParse(propertyValueController.text) ?? 0,
      mortgageBalance: double.tryParse(mortgageBalanceController.text) ?? 0,
      exitFee: double.tryParse(exitFeeController.text) ?? 0,
      loanTerm: int.tryParse(loanTermController.text) ?? 0,
    );

    setState(() {
      result = calculator.calculateLoan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bridging Loan Calculator'),
        backgroundColor: Color.fromARGB(0, 25, 119, 116),
        foregroundColor: Colors.cyan,
      ),
      body: Expanded(
        flex: 7,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                    controller: loanAmountController,
                    decoration: InputDecoration(labelText: 'Loan Amount (£)')),
                TextField(
                    controller: propertyValueController,
                    decoration:
                        InputDecoration(labelText: 'Property Value (£)')),
                TextField(
                    controller: mortgageBalanceController,
                    decoration:
                        InputDecoration(labelText: 'Mortgage Balance (£)')),
                TextField(
                    controller: monthlyInterestController,
                    decoration: InputDecoration(
                        labelText: 'Monthly Interest Rate (%)')),
                TextField(
                    controller: facilityFeeController,
                    decoration: InputDecoration(labelText: 'Facility Fee (%)')),
                TextField(
                    controller: exitFeeController,
                    decoration: InputDecoration(labelText: 'Exit Fee (%)')),
                TextField(
                    controller: loanTermController,
                    decoration:
                        InputDecoration(labelText: 'Loan Term (Months)')),
                SizedBox(height: 20),
                ElevatedButton(onPressed: calculate, child: Text('Calculate')),
                SizedBox(height: 20),
                if (result != null) ...[
                  Text('Total Costs:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  for (var entry in result!["Total Costs"].entries)
                    Text('${entry.key}: £${entry.value}'),
                  SizedBox(height: 10),
                  Text('Other Costs:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  for (var entry in result!["Other Costs"].entries)
                    Text('${entry.key}: £${entry.value}'),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
