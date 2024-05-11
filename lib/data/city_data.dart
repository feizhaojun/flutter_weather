class City {
  String? affiliation;
  String? key;
  String? name;
  String? longitude;
  String? latitude;

  City({this.affiliation, this.key, this.name, this.longitude, this.latitude});

  City.fromJson(Map<String, dynamic> json) {
    affiliation = json['affiliation'];
    key = json['key'];
    name = json['name'];
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['affiliation'] = this.affiliation;
    data['key'] = this.key;
    data['name'] = this.name;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    return data;
  }
}

// TODO: 数据兼容
class District {
  String? name;
  String? id;
  String? key;
  String? longitude;
  String? latitude;

  District({this.id, this.key, this.name, this.longitude, this.latitude});

  District.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    key = json['key'] ?? '';
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['key'] = this.key;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    return data;
  }
}
