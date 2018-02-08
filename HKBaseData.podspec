Pod::Spec.new do |s|
    s.name         = "HKBaseData"
    s.version      = '1.0.0'
    s.ios.deployment_target = '7.0'
    s.summary      = "A delightful setting interface framework."
    s.homepage     = "https://github.com/yellowopen/HKBaseData/tree/master"
    s.license              = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "DKM" => "1203540478@qq.com" }
    s.social_media_url   = "http://weibo.com/u/5348162268"
    s.source       = { :git => "https://github.com/yellowopen/HKBaseData.git", :tag => s.version }
    s.dependency 'FMDB'
    s.source_files  = 'NetworkCache/**'
    s.requires_arc = true
end