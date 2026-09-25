import Foundation
import HTML
import Saga

/// The shell every page renders inside: head, header, main, footer.
@Sendable func renderPage(context: ItemRenderingContext<PageMetadata>) -> NodeConvertible {
    let page = context.item
    let path = page.url                                  // "/", "/about/", "/404.html"
    let isHome = path == "/"
    let isNotFound = page.relativeDestination.string == "404.html"
    // No canonical URL for the 404: it isn't a page anyone should index.
    let canonical = isNotFound ? nil : Site.url.absoluteString + path
    let image = Site.url.absoluteString + "/img/og.png"

    return Node.fragment([
        .documentType("html"),
        html(lang: "en") {
            head {
                meta(charset: "utf-8")
                meta(content: "width=device-width, initial-scale=1", name: "viewport")
                title { page.title }
                meta(content: page.metadata.description, name: "description")
                if let canonical {
                    link(href: canonical, rel: "canonical")
                }

                meta(content: isHome ? "website" : "article", customAttributes: ["property": "og:type"])
                meta(content: Site.name, customAttributes: ["property": "og:site_name"])
                meta(content: page.title, customAttributes: ["property": "og:title"])
                meta(content: page.metadata.description, customAttributes: ["property": "og:description"])
                if let canonical {
                    meta(content: canonical, customAttributes: ["property": "og:url"])
                }
                meta(content: image, customAttributes: ["property": "og:image"])
                meta(content: "summary_large_image", name: "twitter:card")
                meta(content: page.title, name: "twitter:title")
                meta(content: page.metadata.description, name: "twitter:description")
                meta(content: image, name: "twitter:image")

                link(href: "/img/favicon.svg", rel: "icon", type: "image/svg+xml")
                link(href: "/img/deeplife-icon-32.png", rel: "alternate icon", customAttributes: ["sizes": "32x32"])
                link(href: "/img/deeplife-icon-180.png", rel: "apple-touch-icon")
                meta(content: "#03080F", name: "theme-color", customAttributes: ["media": "(prefers-color-scheme: dark)"])
                meta(content: "#FFFFFF", name: "theme-color", customAttributes: ["media": "(prefers-color-scheme: light)"])

                // Hashed filename, so a deploy can never leave a visitor on a stale copy.
                link(href: Saga.hashed("/styles.css"), rel: "stylesheet")
                // Applied before first paint so a chosen theme never flashes the other one.
                script { Node.raw(themeBeforePaint) }
                script(type: "application/ld+json") { Node.raw(structuredData(for: page, canonical: canonical)) }
            }
            body {
                a(class: "skip", href: "#main") { "Skip to content" }
                SiteHeader.render(currentPath: path)
                main(id: "main") { Node.raw(page.body) }
                SiteFooter.render()
                script { Node.raw(interactions) }
            }
        },
    ])
}

private func structuredData(for page: Item<PageMetadata>, canonical: String?) -> String {
    let organization: [String: Any] = [
        "@type": "Organization",
        "name": Site.name,
        "url": Site.url.absoluteString,
        "sameAs": [Site.mastodon, Site.github],
    ]

    var graph: [String: Any] = ["@context": "https://schema.org"]
    if page.url == "/" {
        graph.merge(organization) { _, new in new }
    } else {
        graph["@type"] = "WebPage"
        graph["name"] = page.title
        graph["description"] = page.metadata.description
        if let canonical { graph["url"] = canonical }
        graph["publisher"] = organization
    }

    let data = try? JSONSerialization.data(withJSONObject: graph, options: [.sortedKeys, .withoutEscapingSlashes])
    return data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
}

private let themeBeforePaint = """
    try { var t = localStorage.getItem("theme"); \
    if (t) document.documentElement.setAttribute("data-theme", t); } catch (e) {}
    """

/// The theme toggle and the narrow-screen menu.
private let interactions = """
    (function () {
      var root = document.documentElement;
      document.getElementById("theme-toggle").addEventListener("click", function () {
        var explicit = root.getAttribute("data-theme");
        var current = explicit || (matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark");
        var next = current === "dark" ? "light" : "dark";
        root.setAttribute("data-theme", next);
        try { localStorage.setItem("theme", next); } catch (e) {}
      });

      var btn = document.getElementById("menu-btn");
      var links = document.getElementById("nav-links");
      btn.addEventListener("click", function () {
        var open = links.getAttribute("data-open") === "true";
        links.setAttribute("data-open", String(!open));
        btn.setAttribute("aria-expanded", String(!open));
      });
      links.addEventListener("click", function (e) {
        if (e.target.tagName === "A") {
          links.setAttribute("data-open", "false");
          btn.setAttribute("aria-expanded", "false");
        }
      });
    })();
    """
