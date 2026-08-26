// One-off bulk converter: PNG -> lossless WebP with downscale.
//  home/ + home_shiny/ -> max 256px wide (displayed at <=110 logical px)
//  thumbnails/         -> max 192px wide (displayed at <=52 logical px)
// Deletes the source PNGs after a successful conversion.
// Run: dart run tool/convert_assets.dart
// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final jobs = [
    ('assets/home', 256),
    ('assets/home_shiny', 256),
    ('assets/thumbnails', 192),
  ];

  var before = 0, after = 0, count = 0;

  for (final (dir, maxW) in jobs) {
    final files =
        Directory(dir).listSync().whereType<File>().where((f) => f.path.endsWith('.png')).toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    print('${dir}: ${files.length} png files -> webp (max ${maxW}px)');
    for (var i = 0; i < files.length; i++) {
      final f = files[i];
      final srcBytes = f.readAsBytesSync();
      final decoded = img.decodePng(srcBytes);
      if (decoded == null) {
        print('  SKIP (undecodable): ${f.path}');
        continue;
      }
      final small =
          decoded.width > maxW ? img.copyResize(decoded, width: maxW) : decoded;
      final webp = img.encodeWebP(small);
      final outPath = '${f.path.substring(0, f.path.length - 4)}.webp';
      File(outPath).writeAsBytesSync(webp);
      f.deleteSync();
      before += srcBytes.length;
      after += webp.length;
      count++;
      if (count % 100 == 0) {
        print('  $count converted (running: ${(before / 1048576).toStringAsFixed(0)}MB -> ${(after / 1048576).toStringAsFixed(0)}MB)');
      }
    }
  }

  print('DONE: $count images');
  print('Total: ${(before / 1048576).toStringAsFixed(0)} MB -> ${(after / 1048576).toStringAsFixed(0)} MB');
}
