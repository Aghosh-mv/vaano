import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class GuestStorage {
  static const _key = 'vaano_guest';

  static String getOrCreateGuestId() {
    final stored = html.window.localStorage['$_key:id'];
    if (stored != null && stored.isNotEmpty) return stored;
    final newId = _generateId();
    html.window.localStorage['$_key:id'] = newId;
    return newId;
  }

  static String getGuestId() => html.window.localStorage['$_key:id'] ?? '';

  static bool hasGuestData() => getGuestId().isNotEmpty;

  static void saveProjects(String json) {
    html.window.localStorage['$_key:projects'] = json;
  }

  static String? loadProjects() {
    return html.window.localStorage['$_key:projects'];
  }

  static void saveImage(String name, String dataUrl) {
    html.window.localStorage['$_key:img:$name'] = dataUrl;
  }

  static String? loadImage(String name) {
    return html.window.localStorage['$_key:img:$name'];
  }

  static void clear() {
    final keys = html.window.localStorage.keys.where((k) => k.startsWith(_key));
    for (final k in keys.toList()) {
      html.window.localStorage.remove(k);
    }
  }

  static String _generateId() {
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = DateTime.now().microsecondsSinceEpoch;
    final sb = StringBuffer('guest_');
    for (int i = 0; i < 8; i++) {
      sb.write(chars[(rand >> (i * 3)) % chars.length]);
    }
    return sb.toString();
  }
}
