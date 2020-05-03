#
# Be sure to run `pod lib lint BNCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BNCore'
  s.version          = '0.0.1'
  s.summary          = 'iOS常用核心组件'
  s.swift_version    = '4.0' # 这里不写验证的时候会提示错误

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "网络、缓存、线程管理器三大组件 轻量级"

  s.homepage         = 'https://github.com/chendengwen/BNCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '陈登文' => '596765672@qq.com' }
  s.source           = { :git => 'https://github.com/chendengwen/BNCore.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'BNCore/Classes/**/*'
  
   s.resource_bundles = {
     'BNCore' => ['BNCore/Assets/*.png']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
