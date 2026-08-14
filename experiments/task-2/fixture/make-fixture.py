#!/usr/bin/env python3
"""Generate talk-source.md from the published post, with one seeded defect.

Provenance only — readers use the generated talk-source.md, which is committed.
Source: https://aaronroy.com/go-get-yourself-a-personal-agent/ (CC-BY, Aaron Roy)

One defect is injected on purpose: the summary block contradicts the body on
how often the agents sync memory. Everything else is the published text,
unmodified. See ANSWER-KEY.md.
"""
import pathlib, re, sys

src = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else
                   pathlib.Path.home()/"repos/vault/areas/blog/go-get-yourself-a-personal-agent.md")
text = src.read_text()

# Strip Astro frontmatter and the HTML figure/img blocks (images aren't shipped,
# and leaving dead <img> paths in would add variance unrelated to what's measured).
text = re.sub(r'^---\n.*?\n---\n', '', text, flags=re.S)
text = re.sub(r'<figure>.*?</figure>\n?', '', text, flags=re.S)
text = re.sub(r'<img [^>]*/>\n?', '', text)
text = re.sub(r'\n{3,}', '\n\n', text).strip()

# --- THE DEFECT: an "At a glance" summary that contradicts the body -----------
# Realistic working-draft failure: the summary was written first, the body was
# revised, the summary never caught up. Summary says the agents sync every
# 12 hours; the body says ~4 hours, in two separate sections.
header = """# Go get yourself a personal agent

*Working draft for the internal PM session. Not the published version.*

## At a glance

- Two always-on agents: "Pi Pi" on a Raspberry Pi 5, "Agent M1" on an old laptop
- They share one memory layer, synced through GitHub every 12 hours
- Reached entirely from Discord — phone, laptop, anywhere
- Runs inside a Claude Max plan, plus API costs for side projects

"""
text = header + text


out = pathlib.Path(__file__).parent/"talk-source.md"
out.write_text(text + "\n")
print(f"wrote {out} — {len(text.split())} words, {text.count(chr(10)+'## ')} H2 sections")
