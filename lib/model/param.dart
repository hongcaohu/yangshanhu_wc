class Param {
  String name;
  int askInterval;
  int smileNum;
  int normalNum;
  int sadNum;

  Param(
      {this.name,
      this.askInterval,
      this.smileNum,
      this.normalNum,
      this.sadNum});

  Param.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    askInterval = json['askInterval'];
    smileNum = json['smileNum'];
    normalNum = json['normalNum'];
    sadNum = json['sadNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['askInterval'] = this.askInterval;
    data['smileNum'] = this.smileNum;
    data['normalNum'] = this.normalNum;
    data['sadNum'] = this.sadNum;
    return data;
  }
}
