Pod::Spec.new do |s|
s.name         = 'Module'
s.version      = '1.0.0'
s.summary      = 'A short description of Module.'
s.homepage     = 'https://github.com/SnowMango'
s.license      = 'MIT'
s.author       = {'zhengfeng' => '164804868@qq.com'}
s.ios.deployment_target = '6.0'
s.source       = { :path => '~/Desktop/feng/Module' }
s.requires_arc = true
s.exclude_files = '*.podspec'

s.source_files = 'Module/Module*.{h,m}'
s.public_header_files = '**/Module*.h'
s.frameworks = 'UIKit', 'Foundation'

s.subspec 'First' do |f|
    f.source_files = 'First/**/*.{h,m}'
    f.public_header_files = '**/Module*.h'
    #f.resource_bundles = {'First' => ['First/Resources/**/*.png']}
    f.resources = ['First/Resources/**/*.{png,storyboard,xib}']
    f.frameworks = 'CoreGraphics'
end

s.subspec 'Second' do |se|
    se.source_files = 'Second/**/*.{h,m}'
    se.public_header_files = '**/Module*.h'
    #se.resource_bundles = {'Second' => ['Second/Resources/**/*.png']}
    se.resources = ['Second/Resources/**/*.*']
    #se.frameworks = 'CoreGraphics'
end

s.subspec 'Third' do |se|
    se.source_files = 'Third/**/*.{h,m}'
    se.public_header_files = '**/Module*.h'
    #se.resource_bundles = {'Third' => ['Third/Resources/**/*.png']}
    se.resources = ['Third/Resources/**/*.*']
    se.frameworks = 'CoreData'
end

s.subspec 'Fourth' do |se|
    se.source_files = 'Fourth/**/*.{h,m}'
    se.public_header_files = '**/Module*.h'
    #se.resource_bundles = {'Fourth' => ['Fourth/Resources/**/*.png']}
    se.resources = ['Fourth/Resources/**/*.*']
    #se.frameworks = 'CoreGraphics'
end

end
