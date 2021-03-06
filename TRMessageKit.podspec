
Pod::Spec.new do |s|

  s.name         = "TRMessageKit"
  s.version      = "0.0.6"
  s.summary      = "fork fro TRMessageKit"

  s.description  = <<-DESC
                   A longer description of TRSECoreTextView in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://lijinchao.sinaapp.com"
  s.license      = "MIT"
  s.author             = { "ljc" => "lijinchao2007@163.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/PodRepo/TRMessageKit.git", :tag => s.version }

  s.source_files  = "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  #s.private_header_files = "Classes/TRVoice2Word/IATConfig.h"
  s.public_header_files = "Classes/**/*.h"
  s.resources = "Resources/*"

  s.frameworks        = "CoreTelephony", "SystemConfiguration"
  s.library = 'stdc++.6.0.9', 'z'
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"
  s.dependency "TRWebImage", "~> 0.4"
  s.dependency "TRSECoreTextView", "~> 0.0.1"
  s.dependency 'TRCache', "~> 0.2"
end
