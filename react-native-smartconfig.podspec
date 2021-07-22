require 'json'
package_json = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|

  s.name           = "Smartconfig"
  s.version        = package_json["version"]
  s.summary        = package_json["description"]
  s.homepage       = "https://github.com/imkarthikb/react-native-smartconfig"
  s.license        = package_json["license"]
  s.author         = { package_json["author"] => package_json["author"] }
  s.platform       = :ios, "8.0"
  s.source         = { :git => "https://github.com/imkarthikb/react-native-smartconfig.git" }
  s.source_files   = 'ios/RCTSmartconfig/*.{h,m}'
  s.dependency 'React'

end
