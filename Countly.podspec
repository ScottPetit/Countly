Pod::Spec.new do |spec|
  spec.name = 'Countly'
  spec.version = '0.1.5'
  spec.authors = {'Scott Petit' => 'petit.scott@gmail.com'}
  spec.homepage = 'https://github.com/ScottPetit/Countly'
  spec.summary = 'An iOS SDK for Count.ly'
  spec.source = {:git => 'https://github.com/ScottPetit/Countly.git', :tag => "v#{spec.version}"}
  spec.license = { :type => 'MIT', :file => 'LICENSE' }

  spec.platform = :ios
  spec.requires_arc = true
  spec.frameworks = 'UIKit', 'Foundation', 'CoreTelephony'
  spec.source_files = 'Countly/'
end
