import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cleaner_together/Utilities.dart';

class PickRecyclingFacility extends StatefulWidget {
  @override
  PickRecyclingFacilityState createState() => PickRecyclingFacilityState();
}

class PickRecyclingFacilityState extends State<PickRecyclingFacility> {

  final zipController = TextEditingController();
  FocusNode zipNode = new FocusNode();
  var zip = '';

  var possibleCenters = [];
  var possibleCenterIds = [];
  var selectedCenter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Recycling Center'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.number,
            obscureText: false,
            controller: zipController,
            focusNode: zipNode,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme
                    .of(context)
                    .primaryColor, width: 3),
              ),
              labelText: 'Enter Zip Code',
              labelStyle: TextStyle(
                color: zipNode.hasFocus ? Theme
                    .of(context)
                    .primaryColor : Colors.grey,
              ),
            ),
            onTap: () {
              setState(() {
                FocusScope.of(context).requestFocus(zipNode);
              });
            },
            onChanged: (String val) async {
              zip = val;
              fetchRecyclingCenters();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: possibleCenters.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, i) {
                return Card(
                  child: TextButton(
                    child: Text(
                      possibleCenters[i],
                    ),
                    onPressed: () {
                      setState(() {
                        selectedCenter = possibleCenterIds[i];
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: selectedCenter != '',
            child: ButtonTheme(
              child: ElevatedButton(
                child: Text(
                  'Confirm',
                  style: TextStyle(fontSize: 30.0, backgroundColor: Colors.blue),
                ),
                onPressed: () {
                  Utilities.save('zip', zip);
                  Utilities.save('recyclingCenter', selectedCenter);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  fetchRecyclingCenters() async {
    if (zip.length == 5) {
      possibleCenters = [];
      possibleCenterIds = [];
      final locationIn = 'http://api.earth911.com/earth911.getPostalData?api_key=783aa93e81e2003e&country=US&postal_code=$zip';
      final lr = json.decode((await http.get(Uri.parse(locationIn))).body);
      final centerInput = 'http://api.earth911.com/earth911.searchPrograms?api_key=783aa93e81e2003e&latitude=${lr['result']['latitude']}&longitude=${lr['result']['longitude']}&max_distance=25';
      final centerResults = json.decode((await http.get(Uri.parse(centerInput))).body);
      print(centerResults);
      setState(() {
        for (int i = 0; i < centerResults['num_results']; i++) {
          print(centerResults['result'][i]['curbside']);
          if (centerResults['result'][i]['curbside']) {
            print(centerResults['result'][i]['description']);
            possibleCenters.add(centerResults['result'][i]['description']);
            possibleCenterIds.add(centerResults['result'][i]['program_id']);
          }
        }
      });
    }
  }
}