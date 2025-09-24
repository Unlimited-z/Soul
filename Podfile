# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'SoulScapes' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SoulNetwork', :path => './SoulNetwork'

  
  
  # Pods for Soul
  pod 'SnapKit'
  
  # Firebase 相关
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'Firebase'
  pod 'GoogleSignIn'
  
  pod 'JXSegmentedView'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'ZLSwipeableViewSwift'
  
  pod 'LookinServer', :configurations => ['Debug']


    post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"

  end
  end
  end
end


