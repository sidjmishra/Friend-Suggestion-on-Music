// ignore_for_file: avoid_print
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class LocationService {
  late loc.LocationData currentPosition;
  late String address;
  late String dateTime;

  getLocation() async {
    bool serviceEnabled = false;
    loc.PermissionStatus permissionStatus;

    serviceEnabled = await loc.Location().serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await loc.Location().requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionStatus = await loc.Location().hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await loc.Location().requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        return;
      }
    }

    currentPosition = await loc.Location().getLocation();
    print("Latitude: ${currentPosition.latitude}");
    print("Longitude: ${currentPosition.longitude}");

    getAddress(currentPosition.latitude, currentPosition.longitude);
  }

  getAddress(double? lat, double? long) async {
    final coordinates = placemarkFromCoordinates(lat!, long!);
    coordinates.then((value) {
      print(value[0].country);
      print(value[0].postalCode);
      print(value[0].administrativeArea);
      print(value[0].subAdministrativeArea);
    });
    print(coordinates);
    // await Geocoder.local.findAddressesFromCoordinates(coordinates);
  }
}
