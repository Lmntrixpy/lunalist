import 'dart:math';

class CardSongMapper {
  final List<String> playlist;       // Playlist from Spotify
  final Map<int, String> _cardToSong = {}; // scanned card numbers
  final Random _rng;

  CardSongMapper(this.playlist, [int? seed])
      : _rng = seed != null ? Random(seed) : Random();


  String scanCard(int cardNumber) {
    
    // check if card was scanned previously
    if (_cardToSong.containsKey(cardNumber)) {
      return _cardToSong[cardNumber]!;
    }

    // get available songs
    final available = playlist.where((s) => !_cardToSong.containsValue(s)).toList();

    if (available.isEmpty) {
      throw Exception("Alle Songs vergeben!");
    }

    // get random available song
    final song = available[_rng.nextInt(available.length)];
    _cardToSong[cardNumber] = song;
    return song;
  }

  List<String> get remainingSongs => List.unmodifiable(_availableSongs);

  // get count of remaining tracks
  int get remainingSongCount => _availableSongs.length;

  List<String> get _availableSongs =>
      playlist.where((s) => !_cardToSong.containsValue(s)).toList();



  Map<int, String> getAllMappings() => Map.from(_cardToSong); // all songs and their mappings
}