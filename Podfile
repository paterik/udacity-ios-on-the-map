source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!

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
end
