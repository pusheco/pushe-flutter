#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pushe_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pushe_flutter'
  s.version          = '2.2.1'
  s.summary          = 'Flutter plugin for Pushe sdk'
  s.description      = <<-DESC
  Pushe is a framework written in swift, helping to receive push-notifications in iOS devices.
                       DESC
  s.homepage         = 'https://pushe.co'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jafar Khoshtabiat' => 'jafar.khoshtabiat@pushe.co' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Pushe', '1.0.16'
  # s.platform = :ios, '8.0'
  s.ios.deployment_target = '10.0'

  # Flutter.framework does not contain a i386 slice.
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  # s.swift_version = '5.0'
  s.static_framework = true
end
