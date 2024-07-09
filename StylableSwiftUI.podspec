Pod::Spec.new do |s|
  s.name             = 'StylableSwiftUI'
  s.version          = '4.0.0'
  s.summary          = 'StylableSwiftUI - Style SwiftUI apps and libraries'
  s.description      = <<-DESC
Easily tag a SwiftUI library so it can be styled by multiple apps.
                       DESC

  s.homepage         = 'https://github.com/design-ops/stylable-swiftUI'
  s.license          = { :type => 'MIT' }
  s.author           = 'deanWombourne'
  s.source           = { :git => 'https://github.com/design-ops/stylable-swiftUI.git', :tag => s.version.to_s }

  s.swift_version = '5.10'
  s.ios.deployment_target = '15.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |sub|
    sub.source_files = 'Sources/StylableSwiftUI/**/*{.swift}'
  end

  s.subspec 'Animated' do |sub|
    sub.dependency 'StylableSwiftUI/Core'
    sub.source_files = 'Sources/StylableSwiftUIAnimated/**/*{.swift}'
    sub.dependency 'lottie-ios'
  end

end
