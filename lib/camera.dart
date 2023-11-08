import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'home.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';

final user = FirebaseAuth.instance.currentUser;



// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}


class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key
  });

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> with TickerProviderStateMixin{
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late TabController tabController;
  TextEditingController email=new TextEditingController();
  TextEditingController pass=new TextEditingController();
  TextEditingController conpass=new TextEditingController();
  int currentTabIndex = 0;

  @override
  void initState(){
    tabController = TabController(length: 2, vsync: this);
    initializeCamera();
    tabController.addListener(() {
      onTabChange();
    });
    super.initState();

  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras[0];

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    tabController.addListener(() {
      onTabChange();
    });

    tabController.dispose();
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }


  void onTabChange() {
    setState(() {
      currentTabIndex = tabController.index;

    });
  }




    Map<String,dynamic> responsee={};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 7, 19, 95),
          title: Center(child: const Text('Put Attendance'))),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 150,
                  child: Padding(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 20),
                      child: Container(
                        child: TextFormField(

                          decoration: InputDecoration(
                            filled: true, //<-- SEE HERE
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: 'Date',
                            hintStyle: TextStyle(fontSize: 17)
                          ),

                          // textInputAction: TextInputAction.next,
                          // focusNode: _d1FocusNode,
                          controller: email,

                          // onFieldSubmitted: (_)async=>FocusScope.of(context).requestFocus(_d2FocusNode),
                          // onSaved: (value) {
                          //   _date1 = value!.trim();
                          // },
                          style: TextStyle(fontSize: 12,color: Colors.black),

                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter valid input";
                            }
                            return null;
                          },

                          readOnly: true,
                          onTap: () async {


                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime(2100));

                            if (pickedDate != null) {
                              print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                              String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                              print(formattedDate); //formatted date output using intl package =>2021-03-16
                              setState(() {
                                email.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            }
                            },
                        ),
                      )),
                ),
                Container(
                  width: 150,
                  child: Padding(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 20),
                      child: Container(
                        child: TextFormField(

                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter password";
                            }
                            return null;
                          },
                          controller: pass,

                          decoration: InputDecoration(
                            filled: true, //<-- SEE HERE
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: 'Period',
                          ),

                        ),
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20)
              ),
                child: (_controller!=null)?FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the Future is complete, display the preview.
                      return Container(

                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: CameraPreview(_controller)));
                    } else {
                      // Otherwise, display a loading indicator.
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ):CircularProgressIndicator(),
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("click it!"),

        // Provide an onPressed callback.
        onPressed: () async {
          //!email.text.isEmpty && !pass.text.isEmpty
          if(!email.text.isEmpty && !pass.text.isEmpty){


          try {
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            var request = http.MultipartRequest('POST', Uri.parse('http://192.168.119.64:8000/upload'))
              ..files.add(await http.MultipartFile.fromPath('image', image.path));
            print(request.contentLength);
            var response = await request.send();

            if (response.statusCode == 200) {
              // Handle success

              Map<String,dynamic>? dataMap = (await response.stream
                  .transform(utf8.decoder)
                  .transform(json.decoder)
                  .first) as Map<String, dynamic>?;

              setState(() {

              });


              showModalBottomSheet(

                  context: context,

                  builder: (context) {



                   return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                     stream: FirebaseFirestore.instance.collection('student').doc('21CSEB').snapshots(),

                     builder:(context, snapshott) {

                       if(snapshott.hasData){
                         Map<String, dynamic>? documentData = snapshott.data!.data();
                         Set<dynamic> uniqueNumbers = dataMap!["result"]?.toSet();
                         Set<dynamic> updatedSet = uniqueNumbers.map((element) => element.replaceAll('\n', '')).toSet();
                          List<dynamic> newo=updatedSet.toList();
                         Set<dynamic> mm={"21CSR101", "21CSR109", "21CSR070","21CSR072", "21CSL261", "21CSL260", "21CSR085", "21CSR087",
                         "21CSR097", "21CSR102", "21CSR105", "21CSR111", "21CSR120", "21CSR117", "21CSR118"};

                         Set<dynamic> diff=mm.difference(updatedSet);
                         print(diff);
                         List<dynamic> diffl=diff.toList();
                         return Container(
                           height: MediaQuery.of(context).size.height*0.6,
                           width: MediaQuery.of(context).size.width*0.8,

                           decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.only(
                                 topLeft: Radius.circular(30),
                                 topRight: Radius.circular(30),
                               )),
                           child: Column(
                             children: [
                               MyTabBar(tabController: tabController),
                               Expanded(
                                 child: Container(

                                   padding: EdgeInsets.symmetric(horizontal: 20),
                                   decoration: BoxDecoration(
                                       color: Colors.white,
                                       borderRadius: BorderRadius.only(
                                         topLeft: Radius.circular(30),
                                         topRight: Radius.circular(30),
                                       )),
                                   child: TabBarView(
                                     controller: tabController,
                                     children: [

                                       ListView.builder(

                                           shrinkWrap: true,
                                           physics: NeverScrollableScrollPhysics(),
                                           itemCount: dataMap["result"].length,
                                           itemBuilder: (BuildContext,index){

                                             String key = dataMap["result"][index].toString().replaceAll('\n', '').trim();


                                             if(dataMap["result"][index].toString()!=null){
                                               return Padding(
                                                 padding: const EdgeInsets.all(8.0),
                                                 child: Container(

                                                   decoration: BoxDecoration(
                                                     borderRadius: BorderRadius.circular(10),
                                                     color:Colors.indigo,
                                                     boxShadow: [

                                                     ],
                                                   ),
                                                   height: 80,
                                                   child:Center(
                                                     child: Row(
                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                       crossAxisAlignment: CrossAxisAlignment.center,
                                                       children: [
                                                         Padding(
                                                           padding: const EdgeInsets.all(8.0),
                                                           child: Text(key,style: GoogleFonts.aBeeZee(textStyle: TextStyle(fontWeight:
                                                           FontWeight.bold,fontSize: 18,color: Colors.white)),),
                                                         ),

                                                         Padding(
                                                             padding: const EdgeInsets.all(8.0),
                                                             child: Text(documentData![key].toString(),style: GoogleFonts.aBeeZee(textStyle: TextStyle(fontWeight:
                                                             FontWeight.bold,fontSize: 18,color:Colors.white)))
                                                         )
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                               );}
                                             else{
                                               return SizedBox();
                                             }
                                           }),
                                       ListView.builder(

                                           shrinkWrap: true,

                                           itemCount: diffl.length,
                                           itemBuilder: (BuildContext,index){

                                             String key = diffl[index].toString().replaceAll('\n', '').trim();


                                             if(diffl[index].toString()!=null){
                                               return Padding(
                                                 padding: const EdgeInsets.all(8.0),
                                                 child: Container(

                                                   decoration: BoxDecoration(
                                                     borderRadius: BorderRadius.circular(10),
                                                     color:Colors.indigo,
                                                     boxShadow: [

                                                     ],
                                                   ),
                                                   height: 80,
                                                   child:Center(
                                                     child: Row(
                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                       crossAxisAlignment: CrossAxisAlignment.center,
                                                       children: [
                                                         Padding(
                                                           padding: const EdgeInsets.all(8.0),
                                                           child: Text(key,style: GoogleFonts.aBeeZee(textStyle: TextStyle(fontWeight:
                                                           FontWeight.bold,fontSize: 18,color: Colors.white)),),
                                                         ),

                                                         Padding(
                                                             padding: const EdgeInsets.all(8.0),
                                                             child: Text(documentData![key].toString(),style: GoogleFonts.aBeeZee(textStyle: TextStyle(fontWeight:
                                                             FontWeight.bold,fontSize: 18,color:Colors.white)))
                                                         )
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                               );}
                                             else{
                                               return SizedBox();
                                             }
                                           }),

                                     ],
                                   ),
                                 ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.all(20.0),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: <Widget>[
                                     ElevatedButton(
                                       style: TextButton.styleFrom(
                                           backgroundColor: Colors.black),
                                       onPressed: () => Navigator.pop(context, 'Cancel'),
                                       child: const Text('Cancel',),
                                     ),
                                     ElevatedButton(
                                       style: TextButton.styleFrom(
                                           backgroundColor: Colors.black),
                                       onPressed:()async{

                                         try{
                                           await FirebaseFirestore.instance.collection("attendance").doc(email.text.toString()).get();

                                           await FirebaseFirestore.instance.collection("attendance").doc(email.text.toString()).update({
                                             pass.text.toString():newo
                                           });
                                         }
                                         catch(e){

                                           await FirebaseFirestore.instance.collection("attendance").doc(email.text.toString()).set({
                                             pass.text.toString():newo
                                           });}

                                         Navigator.pop(context, 'OK');
                                       },
                                       child: const Text('Save'),
                                     ),
                                   ],
                                 ),
                               )
                             ],
                           ),




                         );
                       }
                     else{
                       return CircularProgressIndicator();
                       }}
                   ); }
              );

            } else {
              // Handle error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.greenAccent,
                  content: Text('Failed to capture picture.'),
                ),
              );
            }
            // Ensure that the camera is initialized.


            if (!mounted) return;


          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
            print("error");
          }}
          else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.greenAccent,
                content: Container(

                    height: 50,
                    child: Center(child: Text('Enter all fields to get attendance!!'))),
              ),
            );
          }
        },
        icon: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}