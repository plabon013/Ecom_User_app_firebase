
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../models/address_model.dart';
import '../providers/user_provider.dart';

class UserAddressPage extends StatefulWidget {
  static const String routeName = '/user_address';

  const UserAddressPage({Key? key}) : super(key: key);

  @override
  State<UserAddressPage> createState() => _UserAddressPageState();
}

class _UserAddressPageState extends State<UserAddressPage> {
  final addressController = TextEditingController();
  final zipCodeController = TextEditingController();
  late UserProvider userProvider;
  final formKey = GlobalKey<FormState>();
  String? city, area;
  bool isFirst = true;

  @override
  void didChangeDependencies() {
    if(isFirst) {
      userProvider = Provider.of<UserProvider>(context);
      userProvider.getAllCities();
      isFirst = false;
    }
    super.didChangeDependencies();
  }
  @override
  void dispose() {
    addressController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Address'),),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Street Address'
              ),
              validator: (value) {

              },
            ),
            TextFormField(
              controller: zipCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  filled: true,
                  labelText: 'Zip Code'
              ),
              validator: (value) {

              },
            ),

            const SizedBox(height: 20,),
            DropdownButtonFormField<String>(
              value: city,
                hint: const Text('Select City'),
                items: userProvider.cityList.map((c) =>
                DropdownMenuItem<String>(
                  value: c.name,
                    child: Text(c.name),
                )).toList(),
                onChanged: (value) {
                setState(() {
                  city = value!;
                });
              },
              validator: (value) {

              },
            ),
            DropdownButtonFormField<String>(
              value: area,
              hint: const Text('Select Area'),
              items: userProvider.getAreaByCity(city).map((area) =>
                  DropdownMenuItem<String>(
                    value: area,
                    child: Text(area),
                  )).toList(),
              onChanged: (value) {
                setState(() {
                  area = value!;
                });
              },
              validator: (value) {

              },
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: saveAddress,
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  void saveAddress() {
    if(formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Please Wait');
      final addressM = AddressModel(
          streetAddress: addressController.text,
          area: area!,
          city: city!,
          zipCode: int.parse(zipCodeController.text));
      userProvider.updateProfile(
          AuthService.user!.uid,
          {'address' : addressM.toMap()}
      ).then((value) {
        EasyLoading.dismiss();
        Navigator.pop(context);
      }).catchError((error) {
        EasyLoading.dismiss();
        throw error;
      });
    }

  }
}
