# Drafts: hidden for the skeletal launch

Nothing in this folder is built or published; the build only reads `content/`. These are
the full versions of pages that are hidden, or cut down, on the live site, kept whole so
they can come back.

| File | What it is | To bring it back |
|---|---|---|
| `technology.html` | The Technology page | Move to `content/`. Add Technology to the nav in `SiteHeader.swift` and the footer in `SiteFooter.swift`. |
| `support.html` | The Support page | Move to `content/`. Add Support, and "Diving safety" (`/support/#safety`), to the nav and footer. |
| `deeplife.html` | The full Deeplife page: features, platforms, tech specs, sign-up section | Replace `content/deeplife.html`. Restore the nav's "Get notified" button (`/deeplife/#notify`) and the footer's Deeplife links. |
| `about.html` | About, with its Deeplife and diving sections | Replace `content/about.html`. |
| `index.html` | The home page with its Deeplife, "How we work" and "Underneath" sections | Replace `content/index.html`. |
| `about-where-we-stand.html` | About's "Where we stand" section: lifetime licence, open source if we stop, and the fine print, in the company-only wording | Paste back into `content/about.html` as its last section. |
| `privacy.html` | The Privacy page, which describes Deeplife's data handling | Move to `content/`. Add Privacy back to the footer in `SiteFooter.swift`. It has a `{{contact}}` placeholder, so see the note below. Apple requires a privacy policy URL before an app can go on the App Store. |

**The contact address.** The site publishes no email address, and `tools/check.mjs` fails if
one appears in the output. Where the drafts used to show it, they now have a `{{contact}}`
placeholder, and so does the sign-up section. The build stops on it with an explanation, so
nothing that showed the address can come back until you've decided how people should get
in touch.

These drafts link to each other and to the sign-up section, so bring them back together,
or run `node tools/check.mjs` afterwards to find links to pages that are still hidden.
Their diagrams are still in `diagrams/`.

The full site as it stood before the launch cut is also the commit just before
"Cut the site back to a skeletal launch" in git history.
