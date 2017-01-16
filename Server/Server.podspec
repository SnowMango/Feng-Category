Pod::Spec.new do |s|
s.name         = 'Server'
s.version      = '1.0.1'
s.summary      = 'A short description of Server.'
s.homepage     = 'https://github.com/SnowMango'
s.license      = 'MIT'
s.author       = {'zhengfeng' => '164804868@qq.com'}
s.ios.deployment_target = '7.0'
s.source       = { :path => '~/Desktop/feng/Module' }
s.requires_arc = true
s.exclude_files = '*.podspec'

s.source_files = 'BaseJSON.{h,m}'
s.public_header_files = 'BaseJSON.h'
s.frameworks = 'Foundation'

s.subspec 'Http' do |sub|

    pch_AF = <<-EOS
        #ifndef TARGET_OS_IOS
            #define TARGET_OS_IOS TARGET_OS_IPHONE
        #endif

        #ifndef TARGET_OS_WATCH
            #define TARGET_OS_WATCH 0
        #endif

        #ifndef TARGET_OS_TV
            #define TARGET_OS_TV 0
        #endif
    EOS
    sub.prefix_header_contents = pch_AF

    sub.ios.deployment_target = '7.0'
    sub.osx.deployment_target = '10.9'
    sub.watchos.deployment_target = '2.0'
    sub.tvos.deployment_target = '9.0'


    sub.source_files = 'AFNetworking/*.{h,m}'
    sub.public_header_files = 'AFNetworking/*.h'
    sub.watchos.frameworks = 'MobileCoreServices', 'CoreGraphics'
    sub.ios.frameworks = 'MobileCoreServices', 'CoreGraphics'
    sub.osx.frameworks = 'CoreServices'
    sub.frameworks = 'SystemConfiguration','Security'
end

s.subspec 'Socket' do |sub|
    sub.source_files = 'CocoaAsyncSocket/**/*.{h,m}'
    sub.public_header_files = 'CocoaAsyncSocket/**/*.{h}'
    sub.ios.frameworks = 'CFNetwork', 'UIKit'
    sub.frameworks = 'Security'
end

end
