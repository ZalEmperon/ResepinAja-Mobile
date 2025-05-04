import 'package:flutter/material.dart';
import 'package:resepinajamobile/models/UserData.dart';
import 'package:resepinajamobile/screens/mainpage/postedresep_page.dart';
import 'package:resepinajamobile/services/UserService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.id_user});
  final id_user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Userdata? data;

  @override
  void initState() {
    super.initState();
    setValue();
  }

  void setValue() async {
    final user = await Userservice.showProfile(widget.id_user);
    if (user != null) {
      setState(() {
        data = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Pengguna", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body:
          data == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage('assets/profile_placeholder.webp'),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text(
                              data!.username,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Center(child: Text(data!.deskripsi_user,style: TextStyle(fontSize: 18),)),
                        ],
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(backgroundColor: Colors.amber),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ResepSendiri(id_user: data!.id_user)),
                            );
                          },
                          child: Text(
                            "Lihat Postingan Resep",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
