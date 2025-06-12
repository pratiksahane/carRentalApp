import 'package:carrentalapp/signuppage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(44, 43, 52, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset("image1.png", fit: BoxFit.cover,),
              const SizedBox(width: 150,) ,
              Text("Premium Cars.\nEnjoy the luxury.", style: GoogleFonts.dancingScript(  
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
              ),),
            ],
          ),
          Text("Premium and prestige car daily rental\n Experience the thrill at a lower price",style: GoogleFonts.actor(  
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              ),),
          const SizedBox(height: 20,),
          SizedBox(height: 40,width: 200,child: ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Signuppage()));
          }, child: Text("Let's Go",style: TextStyle(color: Colors.white),),))
        ],
      ),
    );
  }
}