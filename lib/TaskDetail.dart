class TaskDetail {
  final String taskNumber;
  final String taskDetails;
  final String taskNote;
  final double lat;
  final double lon;

  TaskDetail(
      this.taskNumber, this.taskDetails, this.taskNote, this.lat, this.lon);

  TaskDetail.fromJson(Map<String, dynamic> data)
      : taskNumber = data['taskNumber'],
        taskDetails = data['taskDetails'],
        taskNote = data['taskNote'],
        lat = double.parse(data['lat']),
        lon = double.parse(data['lon']);
}
