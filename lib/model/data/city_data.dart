class City {
  String? province;
  String? district;

  City({this.province, this.district});

  City.fromJson(Map<String, dynamic> json) {
    province = json['province'];
    district = json['district'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['province'] = this.province;
    data['district'] = this.district;
    return data;
  }
}

class District {
  String? name;
  String? id;
  String key = '';

  District({this.name, this.id, required this.key});

  District.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    key = json['key'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['key'] = this.key;
    return data;
  }
}
