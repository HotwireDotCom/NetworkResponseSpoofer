Pod::Spec.new do |s|
  s.name = 'APIResponseSpoofer'
  s.version = '2.0.1'
  s.summary = 'Network request-response recording and replaying library for iOS.'
  s.description = <<-EOS
  APIResponseSpoofer is a Network request-response spoofer
  EOS
  s.homepage = 'https://stash/projects/HOTWIRE/repos/apiresponsespoofer'
  s.license = 'MIT'
  s.authors = { 'Hotwire' => 'hotwiredevices@gmail.com' }
  s.platforms = { :ios => "8.0"}
  s.ios.deployment_target = '8.0'
  s.source = { :git => 'https://stash/scm/hotwire/apiresponsespoofer.git', :tag => s.version.to_s }
  s.source_files = 'Source/**/*.swift'
  s.resources = 'Source/View/*.storyboard'
  s.requires_arc = true
  s.frameworks = 'UIKit', 'Foundation'
  s.default_subspec = "Lite"

  s.subspec "Lite" do |ss|
    # Leaving this empty of 3rd party dependencies so that Spoofer can work indipendently
    ss.source_files  = "Source/*.swift"
  end

  s.subspec "Realm" do |ss|
    ss.source_files  = "Source/Realm/*swift"
    ss.dependency "RealmSwift"
  end

end
