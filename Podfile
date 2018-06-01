# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'pippip-native-ios' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for pippip-native-ios
  pod 'PMAlertController'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'RKDropdownAlert'
  pod 'FrostedSidebar'
  pod 'Realm'
  pod 'Realm/Headers'
  pod 'DataCompression'
  pod 'Chatto', '= 3.3.1'
  pod 'ChattoAdditions', '= 3.3.1'
  pod 'Sheriff'

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
