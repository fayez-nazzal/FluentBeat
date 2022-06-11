import 'package:country_picker/country_picker.dart';
import 'package:fluent_beat/pages/common/signup/signup.dart';
import 'package:flutter/material.dart';

import '../../../ui/button.dart';

class ExtraInfo extends StatefulWidget {
  const ExtraInfo({Key? key}) : super(key: key);

  @override
  State<ExtraInfo> createState() => _ExtraInfoState();
}

class _ExtraInfoState extends State<ExtraInfo> {
  @override
  Widget build(BuildContext context) {
    DateTime birthday = SignupPage.of(context)!.birthday;
    String country = SignupPage.of(context)!.country;
    String gender = SignupPage.of(context)!.gender;

    Widget addRadioButton(String text) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Radio(
            value: gender,
            groupValue: text,
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  setState(() {
                    SignupPage.of(context)!.gender = text;
                  });
                }
              });
            },
          ),
          Text(text)
        ],
      );
    }

    return Column(children: [
      const SizedBox(height: 16),
      const Padding(
        padding: EdgeInsets.only(bottom: 6.0),
        child: Text("Country", style: TextStyle(fontSize: 16)),
      ),
      Button(
          bg: 0xffffffff,
          text: country == "" ? "Select Country" : country,
          onPress: () {
            showCountryPicker(
                context: context,
                showPhoneCode:
                    false, // optional. Shows phone code before the country name.
                onSelect: (Country pickerCountry) {
                  setState(() {
                    country =
                        "${pickerCountry.flagEmoji} ${pickerCountry.name}";

                    SignupPage.of(context)?.country = country;
                  });
                });
          }),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0),
        child: Text("Birthday", style: TextStyle(fontSize: 16)),
      ),
      Button(
          bg: 0xffffffff,
          text: "${birthday.day} / ${birthday.month} / ${birthday.year}",
          onPress: () async {
            DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: birthday,
                firstDate: DateTime(1920, 1, 1),
                lastDate: DateTime.now());

            if (newDate != null) {
              setState(() {
                SignupPage.of(context)!.birthday = newDate;
              });
            }
          }),
      const Padding(
        padding: EdgeInsets.only(top: 6.0),
        child: Text("Gender", style: TextStyle(fontSize: 16)),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [addRadioButton("Male"), addRadioButton("Female")],
      ),
    ]);
  }
}
