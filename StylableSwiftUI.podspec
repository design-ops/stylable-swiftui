Pod::Spec.new do |s|
  s.name             = 'StylableSwiftUI'
  s.version          = '3.0.0'
  s.summary          = 'StylableSwiftUI - Style SwifTUI apps and libraries'
  s.description      = <<-DESC
Easily tag a SwiftUI library so it can be styled by multiple apps.
                       DESC

  s.homepage         = 'https://github.com/design-ops/stylable-swiftUI'
  s.license          = { :type => 'MIT' }
  s.author           = 'deanWombourne'
  s.source           = { :git => 'https://github.com/design-ops/stylable-swiftUI.git', :tag => "v#{s.version}" }

  s.swift_version = '5.2'
  s.ios.deployment_target = '13.0'

  s.source_files = 'StylableSwiftUI/Classes/**/*{.swift}'

end
