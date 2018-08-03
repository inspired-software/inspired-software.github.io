//
//  main.swift
//
//  Copyright © 2022 Inspired Software, LLC
//

import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct InspiredSoftware: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://inspired.software")!
    var name = "Inspired Software, LLC"
    var description = "Write an awesome description for your new site here."
    var language: Language { .english }
    var imagePath: Path? { nil }
}

// This will generate your website using the built-in Foundation theme:
do {
    try InspiredSoftware().publish(withTheme: .foundation)
} catch {
    fatalError(error.localizedDescription)
}
