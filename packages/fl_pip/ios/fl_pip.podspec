#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fl_pip.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fl_pip'
  s.version          = '3.2.0'
  s.summary          = 'Picture-in-picture support for Flutter views.'
  s.description      = <<-DESC
Displays Flutter views in native picture-in-picture windows on Android and iOS.
                       DESC
  s.homepage         = 'https://github.com/Wayaer/fl_pip'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Wayaer' => 'https://github.com/Wayaer' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
