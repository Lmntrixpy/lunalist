import 'dart:math';

typedef LunalistTrack = ({
  String id,
  String name,
  String artist,
  String artwork,
  int year,
});

class CardSongMapper {
  final List<LunalistTrack> _playlist;
  final Map<int, LunalistTrack> _cardToSong = {}; // scanned cards
  final Random _rng;

  CardSongMapper(List<LunalistTrack> playlist, [int? seed])
      : _playlist = List.from(playlist),
        _rng = seed != null ? Random(seed) : Random();

  // convert List<String> to List<LunalistTrack>
  factory CardSongMapper.fromStringList(List<String> songs, [int? seed]) {
    final tracks = songs
        .map((s) => (id: s, name: "", artist: "", artwork: "", year: 0))
        .toList();
    return CardSongMapper(tracks, seed);
  }

  // scanCard
  LunalistTrack scanCard(int cardNumber) {
    if (_cardToSong.containsKey(cardNumber)) {
      return _cardToSong[cardNumber]!;
    }

    // check if already scanned
    final available = _playlist.where((t) => !_cardToSong.containsValue(t)).toList();

    if (available.isEmpty) {
      throw Exception("Alle Songs vergeben!");
    }

    final song = available[_rng.nextInt(available.length)];
    _cardToSong[cardNumber] = song;
    return song;
  }

  // get remainingSongs
  List<LunalistTrack> get remainingSongs =>
      List.unmodifiable(_playlist.where((t) => !_cardToSong.containsValue(t)));

  int get remainingSongCount => remainingSongs.length;

  Map<int, LunalistTrack> getAllMappings() => Map.from(_cardToSong);
}