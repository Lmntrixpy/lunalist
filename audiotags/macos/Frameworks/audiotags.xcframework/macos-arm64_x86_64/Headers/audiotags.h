#ifndef AUDIOTAGS_H
#define AUDIOTAGS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Picture Type
typedef enum {
    COVER_FRONT = 0,
    COVER_BACK = 1,
    // weitere Typen falls nötig
} PictureType;

// Mime Type
typedef enum {
    NONE = 0,
    JPEG = 1,
    PNG = 2,
} MimeType;

// Picture Struct
typedef struct {
    PictureType type;
    MimeType mime;
    const uint8_t* data; // Zeiger auf die Bilddaten
    int32_t data_len;     // Länge des Bilddatenarrays
} Picture;

// Tag Struct
typedef struct {
    const char* title;
    const char* album;
    const char* album_artist;
    const char* track_artist;
    const char* genre;
    const char* lyrics;
    int32_t year;
    int32_t track_number;
    int32_t track_total;
    int32_t disc_number;
    int32_t disc_total;
    float bpm;
    Picture* pictures;
    int32_t pictures_len;
    float duration; // Sekunden
} Tag;

// Funktionen
// Liest Metadaten aus einer Datei
Tag read(const char* path);

// Schreibt Metadaten in eine Datei
void write(const char* path, Tag tag);

#ifdef __cplusplus
}
#endif

#endif // AUDIOTAGS_H
