# BiblePulse Content Sources

Only content with verified redistribution terms may be enabled in BiblePulse.
Every shipped payload must appear in `assets/content_manifest.json` with an
approved commercial-redistribution flag, attribution, expiry (when applicable),
and exact SHA-256. CI runs `tools/content/validate_manifest.py` and rejects
unlisted files or checksum changes.

## World English Bible

- App translation ID: `WEB`
- Edition: World English Bible, 66-book Protestant edition
- Upstream ID: `engwebp`
- Language: English
- Source page: <https://ebible.org/engwebp/>
- Source archive: <https://ebible.org/scriptures/engwebp_usfm.zip>
- Retrieved: July 17, 2026
- Archive SHA-256:
  `4253589697DC6B5E92695655F2F28792D50E7BE7B9C8E212AF4F4BD18E866C3B`
- License: Public Domain
- Trademark condition: modified text must not be represented as the World
  English Bible.

The bundled JSON contains normalized Scripture text, not invented fallback
verses. USFM study metadata and footnotes are removed without changing the
displayed verse wording. Intentionally empty source verse markers are omitted
rather than populated with fabricated text.

Rebuild:

```powershell
powershell -ExecutionPolicy Bypass -File tools/scripture/fetch_web.ps1
```

The conversion output is `assets/bible/web.json`. Converter metadata is read
from `tools/scripture/manifests/web.json`; it refuses manifests that do not
approve app-store redistribution. The downloaded source
archive and expanded upstream files are reproducible working files and are not
committed.

## Amharic Bible

Status: disabled pending confirmed redistribution scope.

The eBible `amh` source identifies the text as the Amharic New Testament,
copyright 1962/2003 United Bible Societies, used with permission of the Bible
Society of Ethiopia. Its published notice permits non-commercial use only when
the complete copyright statement is included and requires written permission
for commercial use.

BiblePulse does not currently bundle or advertise this source as an available
translation. Before enabling it, record:

- written permission or a release-compatible license;
- whether distribution through app stores is commercial use;
- the exact books included (the currently identified source is New Testament,
  not a complete Bible);
- required attribution text and placement;
- source checksum and conversion validation.

Reference: <https://ebible.org/amh/copyright.htm>

## Audio, devotionals, plans, and hymns

No remote audio or author-content catalog is enabled. These features remain
capability-gated until API access/content rights, attribution, caching, and
redistribution terms are recorded here.
