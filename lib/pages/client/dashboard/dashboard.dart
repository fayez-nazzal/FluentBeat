import 'package:flutter/material.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 116.0,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                color: Colors.transparent,
                child: Expanded(
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Color(0xFFff6b6b),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset("images/heart.jpg")),
                            const Spacer(),
                            const Text("Fayez Nazzal",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                            const Spacer()
                          ],
                        ),
                      ))),
                ),
              ),
            ]),
      ),
    );
  }
}
