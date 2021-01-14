import 'package:flutter/material.dart';
import 'package:soccermgt/TeamDataObject.dart';
import 'package:soccermgt/utilities.dart';

import '../constants.dart';

class TeamWidget extends StatelessWidget {

  TeamData teamData;
  Function onDeletePressed;

  String teamName;

  String teamSpeed;

  String teamPower;

  String teamShot;

  String teamLogo;

  TeamWidget({this.teamData, this.onDeletePressed}){
    setupTeamData(teamData.e);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: Image.network(kImageUrlStart+teamLogo, height: 70, width: 70,),
        title: Text(teamName, style: kTitleStyle,),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('speed:$teamSpeed%', style: kSubtitleStyle,),
            Text('shot:$teamShot%', style: kSubtitleStyle,),
            Text('power:$teamPower%', style: kSubtitleStyle,),
          ],
        ),
        trailing: GestureDetector(
          onTap: onDeletePressed??(){},
          child: Text('Delete', style: TextStyle(color: Colors.red),),
        ),
      ),
    );
  }

  void setupTeamData(String teamData) {
    List<String> dataList= teamData.split('<');
     teamName=dataList[0];
     teamSpeed=dataList[1];
     teamPower=dataList[2];
     teamShot=dataList[3];
     teamLogo=dataList[4];
  }
}
