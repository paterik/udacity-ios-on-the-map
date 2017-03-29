source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!

def baseCore
    pod 'BGTableViewRowActionWithImage'
end

def amazonSDKCore
    pod 'AWSS3'
end

def facebookSDKCore
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'FBSDKShareKit'
end

target 'OnTheMap' do
    facebookSDKCore
    amazonSDKCore
    baseCore
end
