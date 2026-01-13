# Download the binary from GitHub.
version = "1.4.5"
lib_url = "https://github.com/erikas-taroza/audiotags/releases/download/v#{version}/macos.zip"

`
mkdir Frameworks
cd Frameworks
if [ ! -f macos.zip ]
then
  curl -L "#{lib_url}" -o macos.zip
  unzip macos.zip -d 'audiotags.xcframework'
fi
cd ..
`

Pod::Spec.new do |s|
  s.name         = 'audiotags'
  s.version      = '1.0.0'
  s.summary      = 'Rust audio tag library'
  s.description  = 'Prebuilt Rust library for audio tags'
  s.homepage     = 'https://example.com'
  s.license      = { :type => 'MIT' }
  s.authors      = { 'Jeremy Fröb' => 'you@example.com' }

  s.platform     = :osx, '14.5'
  s.vendored_frameworks = 'Frameworks/audiotags.xcframework'
  s.source       = { :path => '.' }  # lokal, kein git nötig
  s.source_files = 'Classes/**/*.{h,swift}'
  s.dependency   'FlutterMacOS'
end