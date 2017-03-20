source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!

def amazonSDKCore
    pod 'AWSS3'
end

def facebookSDKCore
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'FBSDKShareKit'
end

def onTheMapProdPods
    pod 'BGTableViewRowActionWithImage'
end

target 'OnTheMap' do
    onTheMapProdPods
    facebookSDKCore
    amazonSDKCore
end
