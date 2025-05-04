import 'package:flutter/material.dart';
import 'package:resepinajamobile/models/Item.dart';
import 'package:resepinajamobile/screens/component/cards.dart';
import 'package:resepinajamobile/screens/mainpage/searched_page.dart';
import 'package:resepinajamobile/services/RecipeService.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item>? resepbaru;
  List<Item>? reseppopuler;
  @override
  void initState() {
    super.initState();
    setValue();
  }

  Future<void> setValue() async {
    final baru = await Recipeservice.showResepBaru();
    final populer = await Recipeservice.showResepPopuler();
    if (baru != null && populer != null) {
      setState(() {
        resepbaru = baru;
        reseppopuler = populer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: setValue,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.redAccent,
          toolbarHeight: 90,
          title: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: SearchBar(
                    leading: Icon(Icons.search),
                    hintText: "Mulai Cari Resep",
                    onSubmitted: (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResultPage(kunci: value)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body:
            resepbaru == null || reseppopuler == null
                ? Center(child: CircularProgressIndicator()) // <- kalau masih loading
                : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text("Terpopuler", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
                      ),
                      SizedBox(
                        height: 235,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: reseppopuler!.length,
                          itemBuilder: (context, index) {
                            return CardItem_Cube(data: reseppopuler![index]);
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text("Terbaru", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: resepbaru!.length,
                          itemBuilder: (context, index) {
                            return CardItem_Hori(data: resepbaru![index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
