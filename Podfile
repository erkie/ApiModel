platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def realm_dep
  pod 'RealmSwift', '~> 3.14'
end

target :ApiModel do
  realm_dep

  pod 'Alamofire', '~> 4.9'
  pod 'SwiftyJSON', '~> 5.0'
end

target :Tests do
  realm_dep

  pod 'Alamofire', '~> 4.9'
  pod 'SwiftyJSON', '~> 5.0'
  pod 'OHHTTPStubs/Swift', '~> 6.0.0'
end
