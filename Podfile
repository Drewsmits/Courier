source 'https://github.com/CocoaPods/Specs.git'

workspace 'Courier'
xcodeproj 'Courier'

def common_pods
	pod 'Reachability', '3.1.1'
end

target :Courier do
	link_with 'Courier'
	common_pods
end

target :CourierTests do
	link_with 'CourierTests'
	common_pods
	pod 'OHHTTPStubs', '3.1.5'
end