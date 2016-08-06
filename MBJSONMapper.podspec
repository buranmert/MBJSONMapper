Pod::Spec.new do |s|
  s.name             = 'MBJSONMapper'
  s.version          = '0.2.1'
  s.summary          = 'Light-weight JSON to and from Object mapper'

  s.description      = 'There are plenty of JSON mapping libraries but most of them are not light enough. I tried to do it as simple as it can be'

  s.homepage         = 'https://github.com/buranmert/MBJSONMapper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mert Buran' => 'buranmert@gmail.com' }
  s.source           = { :git => 'https://github.com/buranmert/MBJSONMapper.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/lazymanandbeard'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MBJSONMapper/Classes/{MBJSONMapper,NSObject+MBJSONMapperExtension}.{m,h}', 'MBJSONMapper/Classes/MBJSONSerializable.h'
  s.public_header_files = 'MBJSONMapper/Classes/{MBJSONMapper,MBJSONSerializable}.h'

  s.frameworks = 'Foundation'
end
