class BridgingLoanCalculator {
  final double loanAmount;
  final double monthlyInterestRate;
  final double facilityFeeRate;
  final double propertyValue;
  final double mortgageBalance;
  final int loanTerm;
  final double exitFee;

  BridgingLoanCalculator({
    required this.loanAmount,
    required this.monthlyInterestRate,
    required this.facilityFeeRate,
    required this.propertyValue,
    required this.mortgageBalance,
    required this.loanTerm,
    this.exitFee = 1,
  });

  Map<String, dynamic> calculateLoan() {
    double facilityFee = loanAmount * facilityFeeRate / 100;
    double netLoanPlusFee = loanAmount + facilityFee;
    double monthlyInterest = netLoanPlusFee * (monthlyInterestRate / 100);
    double totalInterest = monthlyInterest * loanTerm;
    double grossLoan = netLoanPlusFee + totalInterest;
    double ltvRatio = ((grossLoan + mortgageBalance) / propertyValue) * 100;
    double totalExitFee = (exitFee / 100) * loanAmount;
    double redemptionAmount = grossLoan + totalExitFee;

    return {
      "Total Costs": {
        "Net Bridging Loan Amount": loanAmount,
        "Monthly Interest Rate": monthlyInterestRate,
        "Lender Facility Fee": facilityFee,
        "Net Loan Plus Facility Fee": netLoanPlusFee,
        "Monthly Interest": monthlyInterest,
        "Interest if Loan Runs Full Term": totalInterest,
        "Loan To Value (LTV)": ltvRatio,
        "Redemption Amount at Full Term": redemptionAmount,
      },
      "Other Costs": {
        "Valuation Fees": "FREE TO £2,040",
        "Lenders Administration Fee": 145,
        "Estimated Lender Legal Costs": 720,
        "Telegraphic Transfer Fee": 25,
        "Redemption Administration Fee": 40,
        "Exit Fee": totalExitFee,
        "Packager and Broker Fees": 0,
      },
    };
  }
}
