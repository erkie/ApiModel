platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def realm_dep
  pod 'RealmSwift', '~> 2.4.3'
end

target :ApiModel do
  realm_dep

  pod 'Alamofire', '~> 4.4'
  pod 'SwiftyJSON', '~> 3.1'
end

target :Tests do
  realm_dep

  pod 'Alamofire', '~> 4.4'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'OHHTTPStubs/Swift', '~> 6.0.0'
end
