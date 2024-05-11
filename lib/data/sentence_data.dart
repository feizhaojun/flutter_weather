// TODO:
class Sentence {
  String? content;

  Sentence({this.content});

  Sentence.fromJson(Map<String, dynamic> json) {
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['content'] = this.content;
    return data;
  }
}