current_version = ENV['CURRENT_VERSION'] ? ENV['CURRENT_VERSION'] : '4.1.0+2'
im_sdk_version = ENV['IM_SDK_VERSION'] ? ENV['IM_SDK_VERSION'] : '5.0.0'

Pod::Spec.new do |s|
  s.name             = 'rongcloud_im_plugin'
  s.version          = current_version
  s.summary          = 'RongCloud IM Flutter Plugin.'
  s.homepage         = 'https://www.rongcloud.cn/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'GP-Moon' => 'pmgd19881226@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'
  
#  local = ENV['USE_LOCAL_SDK']
#  if local and local == 'true'
#    im_framework = '../../ios-imsdk/imlib/bin/RongIMLib.framework'
#    s.vendored_frameworks = im_framework
#  else
    s.dependency 'RongCloudIM/IMLib', im_sdk_version
#  end

  s.ios.deployment_target = '8.0'
end

