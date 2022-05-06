#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'rongcloud_im_plugin'
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
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'

  # s.vendored_frameworks = 'Frameworks/*.xcframework'
  s.dependency 'RongCloudIM/IMLibCore', '5.2.2'
  s.dependency 'RongCloudIM/ChatRoom', '5.2.2'
  s.dependency 'RongCloudIM/PublicService', '5.2.2'

  s.ios.deployment_target = '8.0'
end

