platform :ios, '8.0'
use_frameworks!

abstract_target 'App' do
  pod 'ReactiveKit', '~> 2.1'
  pod 'Alamofire', '~> 3.3'
  pod 'JSONCodable', '~> 2.1'
  pod 'AlamofireReactive', '>= 1.0'
  pod 'ReactiveUIKit', '~> 2.0'
  pod 'AlamofireImage', '~> 2.0'

  target 'API' do
  end

  target 'ReactiveGitter' do
  end

  target 'Common' do
  end

  target 'Login' do
  end

  target 'Home' do
  end

  target 'Room' do
  end
end

# Prevents embedding swift libraries in every embedded framework / module
post_install do |installer|
    system "sed -i '' -E 's/EMBEDDED_CONTENT_CONTAINS_SWIFT[[:space:]]=[[:space:]]YES/EMBEDDED_CONTENT_CONTAINS_SWIFT = NO/g' Pods/Target\\ Support\\ Files/*/*.xcconfig"
end
