#
# Be sure to run `pod lib lint Rhyme.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Rhyme'
  s.version          = '1.0.0'
  s.summary          = 'A website wrapper library for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Queue-inc/Rhyme'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'subdiox' => 'subdiox@gmail.com' }
  s.source           = { :git => 'https://github.com/Queue-inc/Rhyme.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/queue_tokyo'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Rhyme/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Rhyme' => ['Rhyme/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'WebKit'
  s.static_framework = true
  s.dependency 'ReachabilitySwift'
  s.dependency 'SwiftyStoreKit'
end
