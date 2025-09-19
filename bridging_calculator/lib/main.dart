import 'package:flutter/material.dart';
import 'dart:math'; // For pow function for EAR calculation

void main() {
  runApp(const BridgeLoanCalculatorApp());
}

class BridgeLoanCalculatorApp extends StatelessWidget {
  const BridgeLoanCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bridge Loan Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // --- Input Controllers ---
  final TextEditingController _netLoanAmountController =
      TextEditingController();
  final TextEditingController _monthlyInterestRateController =
      TextEditingController(); // as percentage, e.g., 0.59
  final TextEditingController _loanTermMonthsController =
      TextEditingController(); // in months, e.g., 12
  final TextEditingController _lenderFacilityFeeController =
      TextEditingController(); // as percentage, e.g., 0.7
  final TextEditingController _exitFeeController =
      TextEditingController(); // as percentage, e.g., 0 or 1.5

  // Other Costs (could be optional or have default values)
  final TextEditingController _valuationFeesController = TextEditingController(
    text: '0',
  ); // e.g., 2040
  final TextEditingController _lendersAdminFeeController =
      TextEditingController(text: '0'); // e.g., 145
  final TextEditingController _estimatedLegalCostsController =
      TextEditingController(text: '0'); // e.g., 1920
  final TextEditingController _telegraphicTransferFeeController =
      TextEditingController(text: '0'); // e.g., 25
  final TextEditingController _redemptionAdminFeeController =
      TextEditingController(text: '0'); // e.g., 40
  final TextEditingController _packagerBrokerFeesController =
      TextEditingController(text: '0'); // e.g., 0

  // --- Calculated Results (will be updated via setState) ---
  bool _showResults = false;

  double _calculatedNetBridgingLoanAmount = 0.0;
  double _calculatedMonthlyInterestRatePercentage = 0.0;
  double _calculatedEquivalentAnnualRate = 0.0;
  double _calculatedLenderFacilityFeeAmount = 0.0;
  double _calculatedNetLoanPlusFacilityFee = 0.0;
  double _calculatedMonthlyInterestAmount = 0.0;
  double _calculatedInterestIfFullTerm = 0.0;
  double _calculatedRedemptionAmountFullTerm =
      0.0; // This is the 'Early Settlement' and 'Gross Loan'
  double _calculatedValuationFees = 0.0;
  double _calculatedLendersAdminFee = 0.0;
  double _calculatedEstimatedLegalCosts = 0.0;
  double _calculatedTelegraphicTransferFee = 0.0;
  double _calculatedRedemptionAdminFee = 0.0;
  double _calculatedExitFeeAmount = 0.0;
  double _calculatedPackagerBrokerFees = 0.0;
  double _calculatedOverallTotalCost = 0.0;

  @override
  void dispose() {
    _netLoanAmountController.dispose();
    _monthlyInterestRateController.dispose();
    _loanTermMonthsController.dispose();
    _lenderFacilityFeeController.dispose();
    _exitFeeController.dispose();
    _valuationFeesController.dispose();
    _lendersAdminFeeController.dispose();
    _estimatedLegalCostsController.dispose();
    _telegraphicTransferFeeController.dispose();
    _redemptionAdminFeeController.dispose();
    _packagerBrokerFeesController.dispose();
    super.dispose();
  }

  void _calculateBridgeLoan() {
    // --- Parse Inputs (with error handling) ---
    final double netLoanAmount =
        double.tryParse(_netLoanAmountController.text) ?? 0.0;
    final double monthlyInterestRatePercentage =
        double.tryParse(_monthlyInterestRateController.text) ?? 0.0;
    final int loanTermMonths =
        int.tryParse(_loanTermMonthsController.text) ?? 0;
    final double lenderFacilityFeePercentage =
        double.tryParse(_lenderFacilityFeeController.text) ?? 0.0;
    final double exitFeePercentage =
        double.tryParse(_exitFeeController.text) ?? 0.0;

    final double valuationFees =
        double.tryParse(_valuationFeesController.text) ?? 0.0;
    final double lendersAdminFee =
        double.tryParse(_lendersAdminFeeController.text) ?? 0.0;
    final double estimatedLegalCosts =
        double.tryParse(_estimatedLegalCostsController.text) ?? 0.0;
    final double telegraphicTransferFee =
        double.tryParse(_telegraphicTransferFeeController.text) ?? 0.0;
    final double redemptionAdminFee =
        double.tryParse(_redemptionAdminFeeController.text) ?? 0.0;
    final double packagerBrokerFees =
        double.tryParse(_packagerBrokerFeesController.text) ?? 0.0;

    if (netLoanAmount <= 0 || loanTermMonths <= 0) {
      // Basic validation
      setState(() {
        _showResults = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid Loan Amount and Loan Term.'),
        ),
      );
      return;
    }

    // --- Convert Percentages to Decimals ---
    final double monthlyInterestRate = monthlyInterestRatePercentage / 100.0;
    final double lenderFacilityFeeDecimal = lenderFacilityFeePercentage / 100.0;
    final double exitFeeDecimal = exitFeePercentage / 100.0;

    // --- Perform Calculations ---
    final double calculatedLenderFacilityFee =
        netLoanAmount * lenderFacilityFeeDecimal;
    final double calculatedNetLoanPlusFacilityFee =
        netLoanAmount + calculatedLenderFacilityFee;
    final double calculatedMonthlyInterest =
        calculatedNetLoanPlusFacilityFee * monthlyInterestRate;
    final double calculatedInterestIfFullTerm =
        calculatedMonthlyInterest * loanTermMonths;

    final double calculatedEquivalentAnnualRate =
        (pow(1 + monthlyInterestRate, 12) - 1) * 100;

    final double calculatedExitFee = netLoanAmount * exitFeeDecimal;

    // Redemption Amount at Full Term (and Early Settlement / Gross Loan in table)
    // Based on KIS sample: Net Loan Amount + Lender Facility Fee + Redemption Admin Fee
    final double calculatedRedemptionAmount =
        calculatedNetLoanPlusFacilityFee + redemptionAdminFee;

    // All "Other Costs" (summing the individual fixed amounts)
    final double totalOtherFixedCosts =
        valuationFees +
        lendersAdminFee +
        estimatedLegalCosts +
        telegraphicTransferFee +
        packagerBrokerFees;

    // Overall Estimated Total Cost (sum of all outflows)
    final double overallTotalCost =
        netLoanAmount +
        calculatedLenderFacilityFee +
        calculatedInterestIfFullTerm +
        calculatedExitFee +
        totalOtherFixedCosts +
        redemptionAdminFee;

    setState(() {
      _showResults = true;
      _calculatedNetBridgingLoanAmount = netLoanAmount;
      _calculatedMonthlyInterestRatePercentage = monthlyInterestRatePercentage;
      _calculatedEquivalentAnnualRate = calculatedEquivalentAnnualRate;
      _calculatedLenderFacilityFeeAmount = calculatedLenderFacilityFee;
      _calculatedNetLoanPlusFacilityFee = calculatedNetLoanPlusFacilityFee;
      _calculatedMonthlyInterestAmount = calculatedMonthlyInterest;
      _calculatedInterestIfFullTerm = calculatedInterestIfFullTerm;
      _calculatedRedemptionAmountFullTerm =
          calculatedRedemptionAmount; // This is the 'Early Settlement' and 'Gross Loan'
      _calculatedValuationFees = valuationFees;
      _calculatedLendersAdminFee = lendersAdminFee;
      _calculatedEstimatedLegalCosts = estimatedLegalCosts;
      _calculatedTelegraphicTransferFee = telegraphicTransferFee;
      _calculatedRedemptionAdminFee = redemptionAdminFee;
      _calculatedExitFeeAmount = calculatedExitFee;
      _calculatedPackagerBrokerFees = packagerBrokerFees;
      _calculatedOverallTotalCost = overallTotalCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bridge Loan Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Input Loan Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              _netLoanAmountController,
              'Net Bridging Loan Amount (£)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _monthlyInterestRateController,
              'Monthly Interest Rate (%)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _loanTermMonthsController,
              'Loan Term (Months)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _lenderFacilityFeeController,
              'Lender Facility Fee (%)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _exitFeeController,
              'Exit Fee (%)',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),
            const Text(
              'Other Costs (Optional, default to 0):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              _valuationFeesController,
              'Valuation Fees (£)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _lendersAdminFeeController,
              'Lenders Administration Fee (£)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _estimatedLegalCostsController,
              'Estimated Lender Legal Costs (£)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _telegraphicTransferFeeController,
              'Telegraphic Transfer Fee (£)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _redemptionAdminFeeController,
              'Redemption Administration Fee (£)',
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              _packagerBrokerFeesController,
              'Packager and Broker Fees (£)',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculateBridgeLoan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Calculate'),
            ),

            if (_showResults) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),

              const Text(
                'Calculated Results',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Summary Header
              _buildResultCard(
                children: [
                  Text(
                    '£${_calculatedNetBridgingLoanAmount.toStringAsFixed(0)}, over ${_loanTermMonthsController.text} Months at ${_calculatedMonthlyInterestRatePercentage.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Costs Section
              _buildResultCard(
                title: 'Total Costs',
                children: [
                  _buildResultRow(
                    'Net Bridging Loan Amount',
                    '£${_calculatedNetBridgingLoanAmount.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Monthly Interest Rate',
                    '${_calculatedMonthlyInterestRatePercentage.toStringAsFixed(2)}%',
                  ),
                  _buildResultRow(
                    'Equivalent Annual Rate',
                    '${_calculatedEquivalentAnnualRate.toStringAsFixed(1)}%',
                  ),
                  _buildResultRow(
                    'Lender Facility Fee (${_lenderFacilityFeeController.text}%)',
                    '£${_calculatedLenderFacilityFeeAmount.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Net Loan Plus Facility Fee',
                    '£${_calculatedNetLoanPlusFacilityFee.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Monthly Interest',
                    '£${_calculatedMonthlyInterestAmount.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Interest if Loan Runs Full Term',
                    '£${_calculatedInterestIfFullTerm.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Redemption Amount at Full Term',
                    '£${_calculatedRedemptionAmountFullTerm.toStringAsFixed(0)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Other Costs Section
              _buildResultCard(
                title: 'Other Costs',
                children: [
                  _buildResultRow(
                    'Valuation Fees',
                    '£${_calculatedValuationFees.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Lenders Administration Fee',
                    '£${_calculatedLendersAdminFee.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Estimated Lender Legal Costs',
                    '£${_calculatedEstimatedLegalCosts.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Telegraphic Transfer Fee',
                    '£${_calculatedTelegraphicTransferFee.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Redemption Administration Fee',
                    '£${_calculatedRedemptionAdminFee.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Exit Fee (${_exitFeeController.text}%)',
                    '£${_calculatedExitFeeAmount.toStringAsFixed(0)}',
                  ),
                  _buildResultRow(
                    'Packager and Broker Fees',
                    '£${_calculatedPackagerBrokerFees.toStringAsFixed(0)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Breakdown Table
              _buildResultCard(
                title: 'Breakdown',
                children: [
                  DataTable(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    columns: const [
                      DataColumn(label: Text('Month')),
                      DataColumn(label: Text('Interest')),
                      DataColumn(label: Text('Gross Loan')),
                      DataColumn(label: Text('Early Settlement')),
                    ],
                    rows: List<DataRow>.generate(
                      int.tryParse(_loanTermMonthsController.text) ?? 0,
                      (index) {
                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(
                              Text(
                                '£${_calculatedMonthlyInterestAmount.toStringAsFixed(0)}',
                              ),
                            ),
                            DataCell(
                              Text(
                                '£${_calculatedNetLoanPlusFacilityFee.toStringAsFixed(0)}',
                              ),
                            ), // This is the 'Gross Loan' as per KIS sample
                            DataCell(
                              Text(
                                '£${_calculatedRedemptionAmountFullTerm.toStringAsFixed(0)}',
                              ),
                            ), // This is the 'Early Settlement' as per KIS sample
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overall Total
              _buildResultCard(
                children: [
                  Text(
                    'Overall Estimated Total Cost: £${_calculatedOverallTotalCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper Widget for InputFields
  Widget _buildInputField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: labelText),
      ),
    );
  }

  // Helper Widget for Result Cards
  Widget _buildResultCard({String? title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 16),
            ],
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper Widget for Result Rows
  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
