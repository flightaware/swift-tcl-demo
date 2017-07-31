// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftTclDemo",
	dependencies: [
		.Package(url: "https://github.com/flightaware/swift-tcl.git", Version(1,0,0))
	]
)

