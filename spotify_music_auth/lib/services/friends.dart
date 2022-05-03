class Friends {
  bool? success;
  Map<String, dynamic>? data;

  Friends({this.success, this.data});

  Friends.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> d = <String, dynamic>{};
    d['success'] = success;
    d['data'] = data;
    return d;
  }
}
