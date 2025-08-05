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
            ]
        ),
        
        // Core Framework
        .target(
            name: "SmartSweepCore",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.smartsweep.SmartSweepCore",
            deploymentTargets: .iOS("18.2"),
            sources: ["SmartSweep/Core/**"],
            dependencies: []
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
            ]
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
            ]
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
            ]
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
            ]
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
            ]
        )
    ]
)
