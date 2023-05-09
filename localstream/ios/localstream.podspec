#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint localstream.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'localstream'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # 启用静态库
  s.static_framework = true

  # 资源导入
  s.vendored_frameworks = '**/*.framework'

  s.public_header_files = 'Classes/**/*.h'
    
  s.dependency 'FURenderKit'
  # SDK 依赖
  s.dependency 'TXLiteAVSDK_Live', '9.5.11346'
end
