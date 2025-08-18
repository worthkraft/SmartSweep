import ProjectDescription

let project = Project(
    name: "SmartSweep",
    targets: [
        .target(
            name: "SmartSweep",
            destinations: .iOS,
            product: .app,
            bundleId: "com.smartsweep.SmartSweep",
            deploymentTargets: .iOS("18.2"),
            infoPlist: "SmartSweep/Info.plist",
            sources: ["SmartSweep/**"],
            resources: [
                "SmartSweep/Assets.xcassets",
                "SmartSweep/Preview Content/**"
            ],
            entitlements: "SmartSweep/SmartSweep.entitlements",
            dependencies: [],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        ),

        .target(
            name: "SmartSweepTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.smartsweep.SmartSweepTests",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweepTests/**"],
            dependencies: [
                .target(name: "SmartSweep")
            ],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        ),

        .target(
            name: "SmartSweepUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.smartsweep.SmartSweepUITests",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweepUITests/**"],
            dependencies: [
                .target(name: "SmartSweep")
            ],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        )
    ]
)
