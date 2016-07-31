#
# Be sure to run `pod lib lint MBJSONMapper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MBJSONMapper'
  s.version          = '0.1.0'
  s.summary          = 'Light-weight JSON to and from Object mapper'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'There are plenty of JSON mapping libraries but most of them are not light enough. I tried to do it as simple as it can be'

  s.homepage         = 'https://github.com/buranmert'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mert Buran' => 'buranmert@gmail.com' }
  s.source           = { :git => 'https://github.com/buranmert/MBJSONMapper.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/lazymanandbeard'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MBJSONMapper/Classes/**/*'
  
  s.frameworks = 'Foundation'
  s.dependency 'AutoCoding', '~> 2.2.2'
end
