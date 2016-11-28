

Pod::Spec.new do |s|
    s.name         = 'Mycategory'
    s.version      = '1.0.0'
    s.summary      = 'A short description of category.'
    s.homepage     = 'https://github.com/SnowMango'
    s.license      = 'MIT'
    s.author       = {'zhengfeng' => '164804868@qq.com'}

    s.source       = { :path => '~' }
    s.requires_arc = true
    s.exclude_files = '*.podspec'

    s.source_files = '**/**/*.{h,m}'

end
