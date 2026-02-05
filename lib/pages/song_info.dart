import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lunalist/pages/end_screen.dart';
import 'package:lunalist/pages/scanner.dart';
import 'package:lunalist/services/card_mapper.dart';
import 'package:lunalist/services/local_music.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class SongInfo extends StatefulWidget {
  final ({String artist, String artwork, String id, String name, int year}) currentTrack;
  final CardSongMapper mapper;
  final String gameMode;

  const SongInfo({super.key, required this.currentTrack, required this.mapper, required this.gameMode});

  @override
  State<SongInfo> createState() => _SongInfoLocalState();
}

class _SongInfoLocalState extends State<SongInfo> {
  GetMetadata trackData = GetMetadata();
  String songName = "";
  String artist = "";
  Uint8List albumArt = Uint8List(0);
  int releaseYear = 0;

  @override
  void initState() {
  super.initState();
  if (widget.gameMode == "local") {
    _getTrackData();
  } else {
    _load();
    songName = widget.currentTrack.name;
    artist = widget.currentTrack.artist;
    releaseYear = widget.currentTrack.year;
  }

  }

  Future<void> _load() async {
    albumArt = await getSpotifyArtwork(widget.currentTrack.artwork);
    setState(() {});
  }

  Future<Uint8List> getSpotifyArtwork(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Image download failed: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  Future<void> _getTrackData() async {
    await GetMetadata.load(widget.currentTrack.id);

    if (!mounted) return;
    
    setState(() {
      songName = GetMetadata.trackName;
      artist = GetMetadata.trackArtistNames.first;
      albumArt = GetMetadata.albumArt;
      releaseYear = GetMetadata.releaseYear;  
    });
    
    debugPrint("--------- $songName");
  }

  @override
  Widget build(BuildContext context) {
    final loading = songName.isEmpty && albumArt.isEmpty && artist.isEmpty && releaseYear == 0;

    if (loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => widget.mapper.remainingSongCount == 0
                    ? EndScreen()
                    : ScannerPage(mapper: widget.mapper, gameMode: widget.gameMode,),
              ),
            );
          },
          label: widget.mapper.remainingSongCount == 0 ? Text("Spiel beenden") : Text("Nächste Karte"),
          icon: widget.mapper.remainingSongCount == 0 ? Icon(Icons.flag_rounded) : Icon(Icons.qr_code_rounded),
        ),

        body: SafeArea(
          child: Column(
            children: [
              Text(
                "Spielmodus: ${widget.gameMode}"
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final isTablet = width >= 500 && width < 1100;
                    final isDesktop = width >= 1100;
                
                    final maxContentWidth = isDesktop ? 1000.0 : (isTablet ? 850.0 : double.infinity);
                
                    final basePadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);
                    final yearSize = isDesktop ? 64.0 : (isTablet ? 52.0 : 30.0);
                    final titleSize = isDesktop ? 44.0 : (isTablet ? 36.0 : 30.0);
                
                    late final Widget content;
                
                    if (isTablet || isDesktop) {
                      // Mobile Tablet / Desktop Ui

                      content = Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _AlbumArtCard(albumArt: albumArt, borderRadius: 28,),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 6,
                            child: _SongTextBlock(
                              gameMode: widget.gameMode,
                              releaseYear: releaseYear,
                              songName: songName,
                              artist: artist,
                              yearFontSize: yearSize,
                              titleFontSize: titleSize,
                              align: TextAlign.left,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile Ui
                      content = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Jahr oben
                          Text(
                            releaseYear.toString(),
                            style: TextStyle(fontSize: yearSize, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Artwork kleiner + weniger Radius
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),
                            child: _AlbumArtCard(
                              albumArt: albumArt,
                              borderRadius: 14,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Titel + Interpret (ohne Jahr/Artwork)
                          Text(
                            songName,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(artist.isNotEmpty ? artist : "Unbekannter Interpret"),
                        ],
                      );
                    }
                
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Padding(
                          padding: EdgeInsets.all(basePadding),
                          child: content,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

      )
    );
  }
}

class _AlbumArtCard extends StatelessWidget {
  final Uint8List albumArt;
  final double borderRadius;

  const _AlbumArtCard({
    required this.albumArt,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final hasArt = albumArt.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasArt
            ? Image.memory(albumArt, fit: BoxFit.cover)
            : const Center(child: Text("Kein AlbumArt")),
      ),
    );
  }
}

class _SongTextBlock extends StatelessWidget {
  final String gameMode;
  final int releaseYear;
  final String songName;
  final String artist;

  final double yearFontSize;
  final double titleFontSize;
  final TextAlign align;

  final Uint8List? albumArt;

  const _SongTextBlock({
    required this.gameMode,
    required this.releaseYear,
    required this.songName,
    required this.artist,
    required this.yearFontSize,
    required this.titleFontSize,
    required this.align,
    // ignore: unused_element_parameter
    this.albumArt,
  });

  @override
  Widget build(BuildContext context) {
    final hasArt = albumArt != null && albumArt!.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: align == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [

        Text(
          releaseYear.toString(),
          style: TextStyle(fontSize: yearFontSize, fontWeight: FontWeight.w600),
          textAlign: align,
        ),
        const SizedBox(height: 24),

        if (albumArt != null) ...[
          // nur mobile: AlbumArt im Textblock anzeigen
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: hasArt ? Image.memory(albumArt!) : const Text("Kein AlbumArt"),
          ),
          const SizedBox(height: 12),
        ],

        Text(
          songName,
          textAlign: align,
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        Text(artist.isNotEmpty ? artist : "Unbekannter Interpret", textAlign: align),
      ],
    );
  }
}