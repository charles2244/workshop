class WorkloadModel {
  final int id;
  final String? mechanicName;
  final int? jobsCompleted;
  final int? totalJobs;
  final String status;
  final int? vehicleId;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? customerName;
  final String? date;
  final String? time;
  final String? description;
  final int? mechanicId;
  final String? vehicleVIN;

  WorkloadModel({
    required this.id,
    this.mechanicName,
    this.jobsCompleted,
    this.totalJobs,
    this.status = "Available",
    this.vehicleId,
    this.vehicleMake,
    this.vehicleModel,
    this.customerName,
    this.date,
    this.time,
    this.description, // Initialize description
    this.mechanicId, // Initialize mechanicId
    this.vehicleVIN, // Initialize vehicleVIN
  });
}
