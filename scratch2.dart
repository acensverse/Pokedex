
import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('C:\\Users\\acens\\Documents\\champions_learnsets.json');
  if (await file.exists()) {
    final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    print('Learnsets: ${raw.keys.length}');
  } else {
    print('No learnsets');
  }
}

