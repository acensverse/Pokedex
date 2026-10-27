
import 'dart:convert';
import 'dart:io';

void main() async {
  final movesFile = File('C:\\Users\\acens\\Documents\\Pokedex-Flutter\\assets\\moves_seed.json');
  final movesList = jsonDecode(await movesFile.readAsString()) as List;
  
  for (final m in movesList) {
    if (m['name'] == 'tackle') {
      print('Tackle learn size: ${(m['learn'] as List).length}');
    }
  }
}

