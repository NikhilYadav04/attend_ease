class LeaveRequestModel {
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String reason;

  const LeaveRequestModel({
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
  });

  Map<String, dynamic> toMap() => {
        'leaveType': leaveType,
        'fromDate': fromDate,
        'toDate': toDate,
        'reason': reason,
      };
}
