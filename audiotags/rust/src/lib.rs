use std::ffi::{CString, CStr};
use std::os::raw::{c_char, c_int, c_float};
use std::ptr;

#[repr(C)]
pub enum PictureType {
    COVER_FRONT = 0,
    COVER_BACK = 1,
}

#[repr(C)]
pub enum MimeType {
    NONE = 0,
    JPEG = 1,
    PNG = 2,
}

#[repr(C)]
pub struct CPicture {
    pub picture_type: PictureType,
    pub mime: MimeType,
    pub data: *const u8,
    pub data_len: i32,
}

#[repr(C)]
pub struct CTag {
    pub title: *const c_char,
    pub album: *const c_char,
    pub album_artist: *const c_char,
    pub track_artist: *const c_char,
    pub genre: *const c_char,
    pub lyrics: *const c_char,
    pub year: i32,
    pub track_number: i32,
    pub track_total: i32,
    pub disc_number: i32,
    pub disc_total: i32,
    pub bpm: c_float,
    pub pictures: *const CPicture,
    pub pictures_len: i32,
    pub duration: c_float,
}

// Hilfsfunktion um Rust String → C String
fn str_to_c(s: Option<String>) -> *const c_char {
    match s {
        Some(string) => CString::new(string).unwrap().into_raw(),
        None => ptr::null(),
    }
}

// Beispiel: konvertiere deinen Rust Tag in CTag
impl From<crate::api::tag::Tag> for CTag {
    fn from(tag: crate::api::tag::Tag) -> Self {
        let pictures: Vec<CPicture> = tag.pictures.into_iter().map(|p| CPicture {
            picture_type: match p.picture_type {
                crate::api::picture::PictureType::CoverFront => PictureType::COVER_FRONT,
                crate::api::picture::PictureType::CoverBack => PictureType::COVER_BACK,
            },
            mime: match p.mime {
                Some(crate::api::picture::MimeType::Jpeg) => MimeType::JPEG,
                Some(crate::api::picture::MimeType::Png) => MimeType::PNG,
                _ => MimeType::NONE,
            },
            data: p.data.as_ptr(),
            data_len: p.data.len() as i32,
        }).collect();

        let pictures_ptr = if pictures.is_empty() { ptr::null() } else { pictures.as_ptr() };

        CTag {
            title: str_to_c(tag.title),
            album: str_to_c(tag.album),
            album_artist: str_to_c(tag.album_artist),
            track_artist: str_to_c(tag.track_artist),
            genre: str_to_c(tag.genre),
            lyrics: str_to_c(tag.lyrics),
            year: tag.year.unwrap_or(0),
            track_number: tag.track_number.unwrap_or(0),
            track_total: tag.track_total.unwrap_or(0),
            disc_number: tag.disc_number.unwrap_or(0),
            disc_total: tag.disc_total.unwrap_or(0),
            bpm: tag.bpm.unwrap_or(0.0) as c_float,
            pictures: pictures_ptr,
            pictures_len: pictures.len() as i32,
            duration: tag.duration.unwrap_or(0.0) as c_float,
        }
    }
}

// Export für C
#[no_mangle]
pub extern "C" fn read(path: *const c_char) -> CTag {
    let c_str = unsafe { CStr::from_ptr(path) };
    let path_str = c_str.to_str().unwrap().to_string();
    let tag = crate::api::api::read(path_str).unwrap(); // Fehlerbehandlung nach Bedarf
    CTag::from(tag)
}

#[no_mangle]
pub extern "C" fn write(path: *const c_char, tag: CTag) {
    let c_str = unsafe { CStr::from_ptr(path) };
    let path_str = c_str.to_str().unwrap().to_string();

    // hier konvertiere zurück von CTag → Rust Tag
    let rust_tag = crate::api::tag::Tag {
        title: unsafe { if tag.title.is_null() { None } else { Some(CStr::from_ptr(tag.title).to_string_lossy().into_owned()) } },
        album: unsafe { if tag.album.is_null() { None } else { Some(CStr::from_ptr(tag.album).to_string_lossy().into_owned()) } },
        album_artist: unsafe { if tag.album_artist.is_null() { None } else { Some(CStr::from_ptr(tag.album_artist).to_string_lossy().into_owned()) } },
        track_artist: unsafe { if tag.track_artist.is_null() { None } else { Some(CStr::from_ptr(tag.track_artist).to_string_lossy().into_owned()) } },
        genre: unsafe { if tag.genre.is_null() { None } else { Some(CStr::from_ptr(tag.genre).to_string_lossy().into_owned()) } },
        lyrics: unsafe { if tag.lyrics.is_null() { None } else { Some(CStr::from_ptr(tag.lyrics).to_string_lossy().into_owned()) } },
        year: Some(tag.year),
        track_number: Some(tag.track_number),
        track_total: Some(tag.track_total),
        disc_number: Some(tag.disc_number),
        disc_total: Some(tag.disc_total),
        bpm: Some(tag.bpm as f32),
        pictures: vec![], // optional: C → Rust Konvertierung hier noch implementieren
        duration: Some(tag.duration as f32),
    };

    crate::api::api::write(path_str, rust_tag).unwrap();
}