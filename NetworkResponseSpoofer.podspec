Pod::Spec.new do |s|
  s.name            = 'NetworkResponseSpoofer'
  s.version         = '8.0.0'
  s.swift_version   = '4.2.0'
  s.summary         = 'Network response record and replay library for iOS, watchOS, tvOS and macOS.'
  s.homepage        = 'https://github.com/HotwireDotCom/NetworkResponseSpoofer.git'
  s.license         = 'MIT'
  s.authors         = { 'Hotwire' => 'hotwiredevices@gmail.com' }
  s.description     = <<-EOS
  NetworkResponseSpoofer is a network response record and replay library for iOS, watchOS, tvOS and macOS.
  It’s built on top of the Foundation URL Loading System to make recording and replaying network requests really simple.
  EOS

  s.source          = { :git => 'https://github.com/HotwireDotCom/NetworkResponseSpoofer.git', :tag => s.version.to_s }
  s.requires_arc    = true
  s.default_subspec = 'Core'
  s.dependency 'RealmSwift'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/Core/**/*.swift'
    ss.framework  = 'Foundation'
    ss.ios.deployment_target = '10.0'
    ss.osx.deployment_target = '10.11'
    ss.watchos.deployment_target = '4.0'
    ss.tvos.deployment_target = '10.0'
  end

  s.subspec 'iOS-UI' do |ss|
    ss.source_files = 'Source/iOS_UI/**/*.swift'
    ss.resources = ['Source/iOS_UI/View/**/*.storyboard', 'Source/iOS_UI/View/**/*.xcassets']
    ss.framework = 'UIKit'
    ss.ios.deployment_target = '10.0'
  end

end
