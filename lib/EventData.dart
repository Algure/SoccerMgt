class EventData{

  String l;// item id
  String e;// item emails


  EventData.withDetails(this.l, this.e){

  }

  Map<String, String> toMap(){
    return {
      'l':l,
      'e':e
    };
  }

  EventData.fromMap(Map<String, String > map) {
    this.l=map['l'];
    this.e=map['e'];
  }
}