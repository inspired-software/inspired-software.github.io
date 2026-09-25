import Foundation
import Saga
import SagaPathKit

/// Facts about the site used across the templates.
enum Site {
    static let url = URL(string: "https://inspired.software")!
    static let name = "Inspired Software, LLC"
    static let mastodon = "https://hachyderm.io/@inspiredsoftware"
    static let github = "https://github.com/inspired-software"

    /// The repository root: this file lives in Sources/InspiredSoftware/.
    static let root = URL(filePath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

/// A page's front matter, beyond the title Saga keeps on the item itself.
struct PageMetadata: Metadata {
    let description: String
}

extension Reader {
    /// Reads a page from content/: a front-matter block, then its HTML as written.
    ///
    ///     ---
    ///     title: Support — Inspired Software, LLC
    ///     description: How to get help with Deeplife…
    ///     ---
    ///     <section class="page-head">…
    static let htmlPage = Reader(supportedExtensions: ["html"]) { path in
        let source: String = try path.read()
        let page = try FrontMatter(source, file: path.lastComponent)
        return (title: page.fields["title"], body: page.body, frontmatter: page.fields)
    }
}

/// `key: value` lines between two `---` lines at the top of a file. Values
/// may contain colons; only the first one on each line separates the key.
struct FrontMatter {
    let fields: [String: String]
    let body: String

    init(_ source: String, file: String) throws {
        guard source.hasPrefix("---\n"),
              let close = source.range(of: "\n---\n", range: source.index(source.startIndex, offsetBy: 3)..<source.endIndex)
        else {
            throw ContentError(file: file, problem: "must start with a front-matter block between --- lines")
        }

        var fields: [String: String] = [:]
        let block = source[source.index(source.startIndex, offsetBy: 4)..<close.lowerBound]
        for line in block.split(separator: "\n") where !line.trimmingCharacters(in: .whitespaces).isEmpty {
            guard let colon = line.firstIndex(of: ":") else {
                throw ContentError(file: file, problem: "front-matter line has no colon: \(line)")
            }
            fields[line[..<colon].trimmingCharacters(in: .whitespaces)] =
                line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        }

        for required in ["title", "description"] where fields[required, default: ""].isEmpty {
            throw ContentError(file: file, problem: "front matter needs a \(required)")
        }

        self.fields = fields
        self.body = String(source[close.upperBound...])
    }
}

struct ContentError: Error, CustomStringConvertible {
    let file: String
    let problem: String
    var description: String { "content/\(file): \(problem)" }
}
