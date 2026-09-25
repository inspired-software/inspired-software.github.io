import HTML
import SagaSwimRenderer

/// The launch call-to-action section, placed in content with `{{notify}}`.
enum NotifyCTA {
    static let html = render().toString()

    // {{contact}} is where the contact address used to be. The site publishes
    // none for now, so the build stops here until a way to get in touch is
    // chosen (see Shortcodes.swift).
    private static let mailto = "mailto:{{contact}}?subject=Deeplife%20%E2%80%94%20tell%20me%20when%20it%20ships"

    private static func render() -> Node {
        section(class: "band band-deep", id: "notify") {
            div(class: "wrap") {
                div(class: "card", style: "text-align:center;padding:clamp(2rem,5vw,3.5rem);background:var(--card-hi)") {
                    p(class: "eyebrow eyebrow-plain center", style: "justify-content:center") { "Not out yet" }
                    h2 { "Be there when Deeplife launches" }
                    p(class: "lede center mt-1", style: "max-width:52ch") {
                        Node.raw("""
                            Deeplife is in active development and has not been released. There is no waitlist \
                            to farm and no newsletter to unsubscribe from &mdash; send a note and you&rsquo;ll \
                            get one email when it ships.
                            """)
                    }
                    div(class: "btn-row mt-3", style: "justify-content:center") {
                        a(class: "btn", href: mailto) {
                            Node.raw(Icons.email + " Email us")
                        }
                        a(class: "btn btn-ghost", href: Site.mastodon, rel: "me noopener") { "Follow on Mastodon" }
                    }
                    // Raw, so no layout whitespace lands between the link and its full stop.
                    p(class: "xs faint mt-2") {
                        Node.raw(#"""
                            We use your address to send that one message. Nothing else. See our \#
                            <a href="/privacy/">privacy policy</a>.
                            """#)
                    }
                }
            }
        }
    }
}
