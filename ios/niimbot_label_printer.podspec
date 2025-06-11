Pod::Spec.new do |s|
  s.name             = 'niimbot_label_printer'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Niimbot printers'
  s.description      = <<-DESC
Supports BLE printing, label configuration, battery and paper detection for Niimbot label printers.
  DESC
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :path => '.' }

  # Actual plugin Swift/ObjC files
  s.source_files     = 'Classes/**/*.{h,m,swift}'
  s.public_header_files = 'SDK/Headers/*.h'

  # Vendor SDK static libraries
  s.vendored_libraries = 'SDK/lib/*.a'

  s.dependency 'Flutter'

  s.platform = :ios, '12.0'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-ObjC',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

  # Bridge header (required for ObjC <-> Swift if used)
  s.preserve_paths = 'Classes/NiimbotLabelPrinterPlugin-Bridging-Header.h'
end
