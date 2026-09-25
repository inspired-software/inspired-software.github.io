import HTML

/// The sticky header: brand, primary nav, theme toggle, narrow-screen menu.
enum SiteHeader {
    // Technology and Support are hidden for the skeletal launch (see drafts/).
    // To bring them back, restore their pages and add ("/technology/",
    // "Technology") and ("/support/", "Support") here.
    private static let links: [(href: String, label: String)] = [
        ("/deeplife/", "Deeplife"),
        ("/about/", "About"),
    ]

    /// - Parameter currentPath: the page being rendered, as "/deeplife/", so
    ///   its nav link is marked as the current page.
    static func render(currentPath: String) -> Node {
        header(class: "site-header") {
            div(class: "wrap") {
                nav(class: "nav", customAttributes: ["aria-label": "Primary"]) {
                    a(class: "brand", href: "/", customAttributes: ["aria-label": "Inspired Software, LLC — home"]) {
                        Node.raw(brand)
                    }
                    // The "Get notified" button (to /deeplife/#notify) is hidden for the
                    // skeletal launch, along with the section it points at.
                    div(class: "nav-links", id: "nav-links") {
                        links.map { link in
                            a(href: link.href, customAttributes: link.href == currentPath ? ["aria-current": "page"] : [:]) {
                                link.label
                            }
                        }
                    }
                    button(
                        class: "theme-toggle",
                        id: "theme-toggle",
                        type: "button",
                        customAttributes: ["aria-label": "Switch between light and dark theme"]
                    ) {
                        Node.raw(themeIcons)
                    }
                    button(
                        class: "menu-btn",
                        id: "menu-btn",
                        type: "button",
                        customAttributes: ["aria-label": "Menu", "aria-expanded": "false", "aria-controls": "nav-links"]
                    ) {
                        Node.raw(menuIcon)
                    }
                }
            }
        }
    }

    /// A shaft of surface light breaking the waterline, with depth contours
    /// beneath, then the name. Colours come from theme tokens, not literals: on
    /// a white header the pale gold and near-white waterline would disappear.
    private static let brand = #"""
        <svg viewBox="0 0 32 32" fill="none" aria-hidden="true"><defs>\#
        <linearGradient id="mark-shaft" x1="16" y1="1" x2="16" y2="17" gradientUnits="userSpaceOnUse">\#
        <stop style="stop-color:var(--sun)"/><stop offset="1" stop-opacity=".85" style="stop-color:var(--cyan)"/>\#
        </linearGradient>\#
        <linearGradient id="mark-deep" x1="16" y1="17" x2="16" y2="31" gradientUnits="userSpaceOnUse">\#
        <stop style="stop-color:var(--cyan)"/><stop offset="1" stop-opacity=".45" style="stop-color:var(--cyan-deep)"/>\#
        </linearGradient></defs>\#
        <path d="M14.4 1.5h3.2l4.1 14.2H10.3z" fill="url(#mark-shaft)"/>\#
        <path d="M2 16.4h28" stroke-opacity=".5" stroke-width="1.5" stroke-linecap="round" style="stroke:var(--ink)"/>\#
        <path d="M7.5 21.4h17M11 26.1h10M14 30.3h4" stroke="url(#mark-deep)" stroke-width="1.9" stroke-linecap="round"/>\#
        </svg><span class="brand-name"><b>Inspired Software</b></span>
        """#

    private static let themeIcons = #"""
        <svg class="moon-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" \#
        stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">\#
        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>\#
        <svg class="sun-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" \#
        stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="4"/>\#
        <path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>
        """#

    private static let menuIcon = #"""
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" \#
        aria-hidden="true"><path d="M3 6h18M3 12h18M3 18h18"/></svg>
        """#
}
