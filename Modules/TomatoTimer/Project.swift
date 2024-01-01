import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
    name: "TomatoTimer",
    platform: .iOS,
    options: .options(automaticSchemesOptions: .disabled),
    packages: [
        .remote(url: "https://github.com/AndrewSB/UITextView-Placeholder", requirement: .branch("master"))
    ]
)
