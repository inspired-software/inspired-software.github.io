import Foundation
import Saga

/// Expands shortcodes in a page's HTML before it's wrapped in the layout:
///
///     {{notify}}                         the launch call-to-action section
///     {{platform-strip}}                 the supported-platform cards
///     {{diagram deeplife/03-tone-curve}}  diagrams/deeplife/03-tone-curve.svg, inline
///     {{contact}}                        stops the build: see below
///
/// `{{contact}}` marks where the contact email address used to be, in drafts/
/// and in the sign-up section. The site publishes no contact address for now,
/// so a page containing it can't be built until that's decided.
///
/// An unknown shortcode or a missing diagram stops the build. Rendering
/// nothing in their place would drop content from the page without a trace.
@Sendable func expandShortcodes(item: Item<PageMetadata>) async {
    item.body = Shortcodes.expand(item.body, in: item.relativeSource.string)
}

enum Shortcodes {
    static func expand(_ html: String, in file: String) -> String {
        // Repeat until nothing changes: a shortcode's output can contain another
        // ({{notify}} contains {{contact}}).
        var result = html
        for _ in 0..<4 {
            let next = expandOnce(result, in: file)
            if next == result { break }
            result = next
        }
        return result
    }

    private static func expandOnce(_ html: String, in file: String) -> String {
        html.replacing(/\{\{\s*([a-z-]+)(?:\s+([^}]*?))?\s*\}\}/) { match in
            let name = String(match.output.1)
            let argument = match.output.2.map(String.init)

            switch (name, argument) {
            case ("notify", nil):
                return NotifyCTA.html
            case ("platform-strip", nil):
                return PlatformStrip.html
            case let ("diagram", path?):
                return diagram(path, in: file)
            case ("contact", nil):
                fatalError("""
                    content/\(file): {{contact}} marks where the contact email address used to be. \
                    The site publishes no contact address for now. Decide how people should get \
                    in touch before this goes back on the site.
                    """)
            default:
                fatalError("content/\(file): unknown shortcode \(match.output.0)")
            }
        }
    }

    private static func diagram(_ name: String, in file: String) -> String {
        let url = Site.root.appending(path: "diagrams/\(name).svg")
        guard let svg = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("content/\(file): {{diagram \(name)}} has no file at diagrams/\(name).svg")
        }
        return svg.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
