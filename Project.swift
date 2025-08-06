import ProjectDescription

let project = Project(
    name: "SmartSweep",
    targets: [
        // Main App Target
        .target(
            name: "SmartSweep",
            destinations: .iOS,
            product: .app,
            bundleId: "com.smartsweep.SmartSweep",
            deploymentTargets: .iOS("18.2"),
            infoPlist: .extendingDefault(
                with: [
                    "NSPhotoLibraryUsageDescription": """
                        SmartSweep memerlukan akses ke galeri foto untuk dapat menganalisis dan \
                        membersihkan gambar duplikat serta gambar sementara dari perangkat Anda.
                        """,
                    "NSPhotoLibraryAddUsageDescription": """
                        SmartSweep memerlukan akses untuk menghapus gambar duplikat dan \
                        sementara dari galeri foto Anda.
                        """,
                    "CFBundleDisplayName": "SmartSweep",
                    "CFBundleShortVersionString": "1.0",
                    "CFBundleVersion": "1",
                    "UILaunchScreen": [:],
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ],
                    "UISupportedInterfaceOrientations~ipad": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationPortraitUpsideDown",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ]
                ]
            ),
            sources: ["SmartSweep/**"],
            resources: [
                "SmartSweep/Assets.xcassets",
                "SmartSweep/Preview Content/**"
            ],
            entitlements: "SmartSweep/SmartSweep.entitlements",
            dependencies: [
                .target(name: "SmartSweepCore"),
                .target(name: "SmartSweepDomain"),
                .target(name: "SmartSweepData"),
                .target(name: "SmartSweepPresentation")
            ],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        ),
        
        // Core Framework
        .target(
            name: "SmartSweepCore",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.smartsweep.SmartSweepCore",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweep/Core/**"],
            dependencies: [],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        ),
        
        // Domain Framework
        .target(
            name: "SmartSweepDomain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.smartsweep.SmartSweepDomain",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweep/Domain/**"],
            dependencies: [
                .target(name: "SmartSweepCore")
            ],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        ),
        
        // Data Framework
        .target(
            name: "SmartSweepData",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.smartsweep.SmartSweepData",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweep/Data/**"],
            dependencies: [
                .target(name: "SmartSweepCore"),
                .target(name: "SmartSweepDomain")
            ],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        ),
        
        // Presentation Framework
        .target(
            name: "SmartSweepPresentation",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.smartsweep.SmartSweepPresentation",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweep/Presentation/**"],
            dependencies: [
                .target(name: "SmartSweepCore"),
                .target(name: "SmartSweepDomain"),
                .target(name: "SmartSweepData")
            ],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        ),
        
        // Unit Tests
        .target(
            name: "SmartSweepTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.worthkraft.SmartSweepTests",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweepTests/**"],
            dependencies: [
                .target(name: "SmartSweep"),
                .target(name: "SmartSweepCore"),
                .target(name: "SmartSweepDomain"),
                .target(name: "SmartSweepData"),
                .target(name: "SmartSweepPresentation")
            ],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        ),
        
        // UI Tests
        .target(
            name: "SmartSweepUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.worthkraft.SmartSweepUITests",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweepUITests/**"],
            dependencies: [
                .target(name: "SmartSweep")
            ],
            settings: .settings(base: ["DEVELOPMENT_TEAM": "2H46N4N76A"])
        )
    ]
)
