Pod::Spec.new do |s|
  s.name = "APIModel"
  s.version = "0.4.0"
  s.summary = "Easy API integrations using Realm and Swift"

  s.description  = <<-DESC
                   Easy get up and running with any API, with maximum flexibility,
                   intuitive boilerplate and a very declarative aproach to API integrations.
                   DESC

  s.homepage = "https://github.com/erkie/APIModel"

  s.license = "MIT"
  s.author = { "Erik Rothoff Andersson" => "erik.rothoff@gmail.com" }
  s.platform = :ios, "8.0"
  s.source = { :git => "https://github.com/erkie/APIModel.git", tag: s.version }
  s.source_files  = "Source/**/*"

  s.requires_arc = true
  s.dependency "Alamofire", "~> 1.2"
  s.dependency "RealmSwift", "~> 0.92.0"
end
