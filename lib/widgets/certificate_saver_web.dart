import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void saveImageWeb(List<int> bytes, String fileName) {
  final base64 = base64Encode(bytes);
  final url = 'data:application/octet-stream;base64,$base64';
  
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
}
