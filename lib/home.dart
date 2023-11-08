import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyTabBar extends StatelessWidget {
  const MyTabBar({
    Key? key, required this.tabController,
  }) : super(key: key);

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    Color kPrimaryColor = Color(0xff7C7B9B);
    Color kPrimaryColorVariant = Color(0xff686795);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      height: 80,
      color: Colors.white,
      child: TabBar(

        controller: tabController,
        indicator: BoxDecoration(

            border: Border(bottom: BorderSide(color: Colors.black,width: 2))
        ),
        tabs: [


          Tab(
            icon: Text(
              'Present',
              style: GoogleFonts.comfortaa(color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,),
            ),
          ),
          Tab(
            icon: Text(
              'Absent',
              style: GoogleFonts.comfortaa(color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,),



            ),
          ),

        ],
      ),
    );

  }

}













class Status extends StatefulWidget {
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> with TickerProviderStateMixin {
  static Color kPrimaryColor = Color(0xff7C7B9B);
  static Color kPrimaryColorVariant = Color(0xff686795);
  late TabController tabController;
  TextEditingController email=new TextEditingController(text:"21-05-2023");
  TextEditingController pass=new TextEditingController(text: "1");

  int currentTabIndex = 0;


  void onTabChange() {
    setState(() {
      currentTabIndex = tabController.index;

    });
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);

    tabController.addListener(() {
      onTabChange();
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.addListener(() {
      onTabChange();
    });

    tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 7, 19, 95),

        title: Center(
          child: Text(
            'Status',style: GoogleFonts.aBeeZee(fontSize: 18,
            fontWeight: FontWeight.w600,),

          ),
        ),

        elevation: 0,
      ),
      backgroundColor: Color.fromARGB(255, 7, 19, 95),
      body: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 150,
                child: Padding(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true, //<-- SEE HERE
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: 'Period',
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
                        onEditingComplete: (){
                          setState(() {

                          });
                        },
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

          SizedBox(height: 20,),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                color: Colors.white,
              ),

                child: Column(
              children: [
                SizedBox(height: 20,),
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

                        (email.text.toString() != "" && pass.text.toString() != "")
                      ? StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('attendance')
                        .doc(email.text.toString())
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Enter the data correctly");
                      } else if (snapshot.hasData && snapshot.data?.data() != null) {
                        Map<String, dynamic>? documentData = snapshot.data?.data();
                        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('student')
                              .doc('21CSEB')
                              .snapshots(),
                          builder: (context, snapshott) {
                            if (snapshott.hasError) {
                              return Text("Enter the data correctly");
                            }
                            if (snapshott.hasData && snapshott.data?.data() != null) {
                              Map<String, dynamic>? documentDataa = snapshott.data?.data();
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: documentData?[pass.text.toString()]?.length ?? 0,
                                itemBuilder: (BuildContext, index) {
                                  String key = documentData![pass.text.toString()][index]
                                      .toString()
                                      .replaceAll('\n', '')
                                      .trim();

                                  if (documentData[pass.text.toString()][index].toString() != null &&
                                      email.text.toString() != null &&
                                      pass.text.toString() != null) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.indigo,
                                          boxShadow: [],
                                        ),
                                        height: 80,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  key,
                                                  style: GoogleFonts.aBeeZee(
                                                    textStyle: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  documentDataa![key].toString(),
                                                  style: GoogleFonts.aBeeZee(
                                                    textStyle: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              );
                            } else if (snapshott.data?.data() == null) {
                              return Text("Enter the valid date and period");
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        );
                      } else if (snapshot.data?.data() == null) {
                        return Text("Enter the valid date and period");
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  )
                      : Text("Enter the details correctly"),

                  (email.text.toString() != "" && pass.text.toString() != "")
                      ? StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('attendance')
                        .doc(email.text.toString())
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Enter the data correctly");
                      } else if (snapshot.hasData && snapshot.data?.data() != null) {
                        Map<String, dynamic>? documentData = snapshot.data?.data();
                        print(documentData);
                        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('student')
                              .doc('21CSEB')
                              .snapshots(),
                          builder: (context, snapshott) {
                            if (snapshott.hasError) {
                              return Text("Enter the data correctly");
                            }
                            if (snapshott.hasData && snapshott.data?.data() != null) {
                              Map<String, dynamic>? documentDataa = snapshott.data?.data();
                              Set<dynamic> uniqueNumbers = documentData![pass.text.toString()]?.toSet();
                              Set<dynamic> mm={"21CSR101", "21CSR109", "21CSR070","21CSR072", "21CSL261", "21CSL260", "21CSR085", "21CSR087",
                                "21CSR097", "21CSR102", "21CSR105", "21CSR111", "21CSR120", "21CSR117", "21CSR118"};

                              Set<dynamic> diff=mm.difference(uniqueNumbers);
                              print(diff);
                              List<dynamic> diffl=diff.toList();
                              print(diffl);
                              return ListView.builder(
                                shrinkWrap: true,

                                itemCount: diffl.length ?? 0,
                                // documentData?[pass.text.toString()]?.length ?? 0,
                                itemBuilder: (BuildContext, index) {
                                  String key = diffl[index]
                                      .toString()
                                      .replaceAll('\n', '')
                                      .trim();

                                  if (diffl[index].toString() != null &&
                                      email.text.toString() != null &&
                                      pass.text.toString() != null) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.indigo,
                                          boxShadow: [],
                                        ),
                                        height: 80,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  key,
                                                  style: GoogleFonts.aBeeZee(
                                                    textStyle: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  documentDataa![key].toString(),
                                                  style: GoogleFonts.aBeeZee(
                                                    textStyle: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              );
                            } else if (snapshott.data?.data() == null) {
                              return CircularProgressIndicator();
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        );
                      } else if (snapshot.data?.data() == null) {
                        return Text("Enter the valid date and period");
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  )
                      : Text("Enter the details correctly")



                  ],
                    ),
                  ),
                )
              ],
            )),
          ),

        ],
      ),

    );
  }
}

class sasasa extends StatefulWidget {
  const sasasa({super.key});

  @override
  State<sasasa> createState() => _sasasaState();
}

class _sasasaState extends State<sasasa> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

