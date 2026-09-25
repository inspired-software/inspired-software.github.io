import Foundation
import Saga
import SagaSwimRenderer

// The whole build. Pages are the HTML files in content/, each read by the
// `.htmlPage` reader, given its shortcodes, and wrapped in `renderPage`.
// Everything else in content/ (styles, images, CNAME) is copied as-is.

try await Saga(input: "content", output: "Output")
    // The 404 is written as 404.html rather than 404/index.html, because that
    // is the file GitHub Pages serves for any URL it can't find.
    .register(
        metadata: PageMetadata.self,
        readers: [.htmlPage],
        itemProcessor: expandShortcodes,
        filter: { $0.relativeSource.string == "404.html" },
        claimExcludedItems: false,
        itemWriteMode: .keepAsFile,
        writers: [.itemWriter(swim(renderPage))]
    )
    // Every other page: content/about.html becomes /about/.
    .register(
        metadata: PageMetadata.self,
        readers: [.htmlPage],
        itemProcessor: expandShortcodes,
        writers: [.itemWriter(swim(renderPage))]
    )
    .createPage(
        "sitemap.xml",
        using: Saga.sitemap(baseURL: Site.url, filter: { path, _ in path.string != "404.html" })
    )
    .run()
