# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'pippip-native-ios' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for pippip-native-ios
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'RKDropdownAlert'
  pod 'FrostedSidebar'
  pod 'RealmSwift'
  pod 'DataCompression'
  pod 'Chatto'
  pod 'ChattoAdditions'
  pod 'Sheriff'
  pod 'AlamofireObjectMapper', '~> 5.0'
  pod 'DeviceKit', '~> 1.3'
  pod 'ImageSlideshow', '~> 1.6'
  pod 'CocoaLumberjack/Swift'
  pod 'Toast-Swift', '~> 4.0.0'
  pod 'PromisesSwift', '~> 1.2.7'
  pod 'Tabman', '~> 2.3'

  target 'pippip-native-iosTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end
