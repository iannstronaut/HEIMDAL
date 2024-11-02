import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl =
      "https://firms.modaps.eosdis.nasa.gov/api/country/csv/db4e07c51dce7b540e4f5ea6de04c92b/MODIS_NRT/IDN/7";

  Future<List<Map<String, dynamic>>> fetchCoordinates() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        final headers = lines.first.split(',');
        final latIndex = headers.indexOf('latitude');
        final lonIndex = headers.indexOf('longitude');

        if (latIndex == -1 || lonIndex == -1) {
          throw Exception("Kolom latitude atau longitude tidak ditemukan.");
        }

        List<Map<String, dynamic>> latLongData = [];
        for (var line in lines.skip(1)) {
          final values = line.split(',');
          if (values.length > lonIndex) {
            final latitude = double.tryParse(values[latIndex]);
            final longitude = double.tryParse(values[lonIndex]);

            if (latitude != null && longitude != null) {
              latLongData.add({
                'latitude': latitude,
                'longitude': longitude,
              });
            }
          }
        }

        return latLongData;
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
