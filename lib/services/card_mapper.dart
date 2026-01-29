import 'dart:ffi';
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

  Map<int, String> getAllMappings() => Map.from(_cardToSong); // all songs and their mapping
}

void main() {
  final playlist = ['Song A', 'Song B', 'Song C', 'Song D']; // playlist
  final mapper = CardSongMapper(playlist, 123); // optional seed for real rng

  print(mapper.scanCard(132)); 
  print(mapper.scanCard(9783));

  print(mapper.getAllMappings());
}