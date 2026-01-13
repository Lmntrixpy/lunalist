Pod::Spec.new do |s|
  s.name = "rust_lib_audiotags"
  s.version = "0.1.0"
  s.summary = "Rust Audiotags static lib for macOS"
  s.homepage = "https://example.com"
  s.license = { :type => "MIT" }
  s.author = { "You" => "you@example.com" }
  s.platform = :osx, "10.15"

  s.vendored_libraries = "libs/libaudiotags.a"
  s.source = { :path => "." }
end
