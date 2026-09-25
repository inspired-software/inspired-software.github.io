import Foundation
import HTML

/// The site footer: who we are, the social links, and three columns of links.
enum SiteFooter {
    private typealias Column = (heading: String, links: [(href: String, label: String)])

    // Links into the pages and sections hidden for the skeletal launch (the
    // Deeplife features, platforms, specs and notify anchors; Technology;
    // Support and its diving-safety section; Privacy) are left out until they
    // return. There is no contact address on the site for now.
    private static let columns: [Column] = [
        ("Company", [
            ("/about/", "About"),
            ("/deeplife/", "Deeplife"),
        ]),
    ]

    private static let year = Calendar.current.component(.year, from: .now)

    static func render() -> Node {
        footer(class: "site-footer") {
            div(class: "wrap") {
                div(class: "footer-grid") {
                    div {
                        p(style: "font-weight:650;letter-spacing:-.02em;color:var(--ink)") { Site.name }
                        p(class: "dim mt-1", style: "max-width:34ch") {
                            "Native software built carefully."
                        }
                        div(class: "social mt-2") {
                            a(href: Site.mastodon, rel: "me noopener", customAttributes: ["aria-label": "Inspired Software on Mastodon"]) {
                                Node.raw(Icons.mastodon)
                            }
                            a(href: Site.github, rel: "noopener", customAttributes: ["aria-label": "Inspired Software on GitHub"]) {
                                Node.raw(Icons.github)
                            }
                        }
                    }
                    columns.map { column in
                        div {
                            h2 { column.heading }
                            ul {
                                column.links.map { link in
                                    li { a(href: link.href) { link.label } }
                                }
                            }
                        }
                    }
                }
                div(class: "footer-bottom") {
                    p { "© \(year) Inspired Software, LLC. All rights reserved." }
                }
            }
        }
    }
}

/// Small line icons shared by the footer and the launch call-to-action.
enum Icons {
    static let email = #"""
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" \#
        stroke-linejoin="round" aria-hidden="true"><rect x="2" y="4" width="20" height="16" rx="2"/>\#
        <path d="m2 7 10 6 10-6"/></svg>
        """#

    static let mastodon = #"""
        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M21.3 8.2c0-3.6-2.4-4.7-2.4-4.7\#
        -1.2-.6-3.3-.8-5.5-.9h-.05c-2.2 0-4.3.3-5.5.9 0 0-2.4 1.1-2.4 4.7v3.4c0 4 .3 7.3 4.2 8.3 1.8.5 3.3.6 4.6.5 \#
        2.3-.1 3.6-.8 3.6-.8l-.08-1.7s-1.6.5-3.5.44c-1.9-.06-3.8-.2-4.1-2.5a4.6 4.6 0 0 1-.04-.64s1.8.44 4.1.55c1.4.06 \#
        2.7-.08 4-.24 2.6-.3 4.9-1.9 5.2-3.4.45-2.3.4-5.6.4-5.6Zm-3.1 5.1h-1.9V8.6c0-1-.4-1.5-1.25-1.5-.93 0-1.4.6-1.4 \#
        1.8v2.6h-1.9V8.9c0-1.2-.47-1.8-1.4-1.8-.85 0-1.25.5-1.25 1.5v4.7H7.2V8.5c0-1 .25-1.8.76-2.4a2.6 2.6 0 0 1 \#
        2-.87c.92 0 1.6.35 2.07 1.05l.47.8.48-.8c.46-.7 1.15-1.05 2.06-1.05.85 0 1.52.3 2 .87.5.6.76 1.4.76 2.4v4.8Z"/></svg>
        """#

    static let github = #"""
        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 .5C5.7.5.6 5.6.6 12c0 5 3.3 \#
        9.3 7.8 10.8.6.1.8-.2.8-.6v-2c-3.2.7-3.9-1.5-3.9-1.5-.5-1.3-1.3-1.7-1.3-1.7-1-.7.1-.7.1-.7 1.1.1 1.7 1.2 1.7 \#
        1.2 1 1.8 2.7 1.3 3.4 1 .1-.7.4-1.3.7-1.6-2.6-.3-5.3-1.3-5.3-5.8 0-1.3.5-2.3 1.2-3.1-.1-.3-.5-1.5.1-3.1 0 0 \#
        1-.3 3.2 1.2a11 11 0 0 1 5.8 0c2.2-1.5 3.2-1.2 3.2-1.2.6 1.6.2 2.8.1 3.1.8.8 1.2 1.8 1.2 3.1 0 4.5-2.7 \#
        5.5-5.3 5.8.4.4.8 1.1.8 2.2v3.3c0 .4.2.7.8.6a11.4 11.4 0 0 0 7.8-10.8C23.4 5.6 18.3.5 12 .5Z"/></svg>
        """#
}
