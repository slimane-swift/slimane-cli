import PackageDescription

let package = Package(
    name: "<%= appName %>",
    dependencies: [
        .Package(url: "<%= repository %>", majorVersion: <%= majorVersion %>, minor: <%= minorVersion %>)
    ]
)
