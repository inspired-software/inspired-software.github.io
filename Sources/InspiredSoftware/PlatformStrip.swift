import HTML
import SagaSwimRenderer

/// One card per platform: icon, name, role. Placed in content with
/// `{{platform-strip}}`. Show the platforms with this; don't restate them in prose.
enum PlatformStrip {
    static let html = render().toString()

    private struct Platform {
        let name: String
        let role: String
        /// The icon's SVG shapes, drawn on a 24 × 24 grid.
        let shapes: String
        var planned = false
    }

    private static let platforms = [
        Platform(name: "iPhone", role: "Full editor",
                 shapes: #"<rect x="7" y="2" width="10" height="20" rx="2.6"/><path d="M10.8 5h2.4"/>"#),
        Platform(name: "iPad", role: "Full editor",
                 shapes: #"<rect x="4.5" y="2.5" width="15" height="19" rx="2.2"/><path d="M10.8 19.4h2.4"/>"#),
        Platform(name: "Mac", role: "Full editor",
                 shapes: #"<rect x="2.5" y="3.5" width="19" height="13" rx="1.8"/><path d="M12 16.5v3.6M8.5 20.1h7"/>"#),
        Platform(name: "Vision Pro", role: "Full editor",
                 shapes: #"<path d="M3 12.2c0-2.9 2.2-4.7 5-4.7h8c2.8 0 5 1.8 5 4.7 0 2.9-1.7 4.9-4.1 4.9-1.7 0-2.5-1.3-4.9-1.3s-3.2 1.3-4.9 1.3C4.7 17.1 3 15.1 3 12.2Z"/>"#),
        Platform(name: "Apple TV", role: "Viewing",
                 shapes: #"<rect x="2.5" y="5" width="19" height="14" rx="2.4"/><path d="M10.3 9.6l4.4 2.4-4.4 2.4z"/>"#),
        Platform(name: "Apple&nbsp;Watch", role: "Planned",
                 shapes: #"<rect x="7.2" y="6.2" width="9.6" height="11.6" rx="3" stroke-dasharray="3 2.4"/><path d="M9.6 6.2V3.4h4.8v2.8M9.6 17.8v2.8h4.8v-2.8"/>"#,
                 planned: true),
        Platform(name: "Android", role: "Planned",
                 shapes: #"<rect x="7" y="2" width="10" height="20" rx="2.6" stroke-dasharray="3 2.6"/>"#,
                 planned: true),
    ]

    private static func render() -> Node {
        ul(class: "platforms mt-3", customAttributes: ["aria-label": "Supported platforms"]) {
            platforms.map { platform in
                li(class: platform.planned ? "platform platform-soon" : "platform") {
                    Node.raw(#"""
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" \#
                        stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">\#(platform.shapes)</svg>\#
                        <b>\#(platform.name)</b><span>\#(platform.role)</span>
                        """#)
                }
            }
        }
    }
}
