# GTM setup skill

An agent skill for building and auditing Google Tag Manager web containers. It gives Claude (or any agent that reads skills) a complete, tested method for GA4 and Google Ads through GTM: build order, naming, consent mode, form and booking tracking, an attribution script for hidden form fields, and a way to prove that hits actually leave the browser.

## What it does

- **New containers**: builds a container from nothing in a fixed order (settings, built-in variables, consent, Google destinations, form sources, event tags, GA4 admin).
- **Audits**: runs an 18-point alignment checklist on an existing container and fixes what fails, one container at a time, with a dated version note.
- **Migrations**: moves legacy "Google tag" setups to the new GA4 and Google Ads destination tags, with or without the Optimize wizard, and checks the result live.
- **Form and booking tracking**: ready-made listeners and setup steps for Gravity Forms, Elementor forms (v3 and v4), HubSpot forms (v3 and v4), HubSpot Meetings, Calendly and TidyCal.
- **Attribution**: a site script that stores UTMs, click IDs, landing page and referrer in first-party cookies and fills hidden fields in Gravity Forms, Elementor and HubSpot forms.
- **Proof**: a three-layer test (Preview, network, destination) and a real-submit logger that survives redirects.

## Who it's for

Agencies, freelancers and in-house marketers who manage more than a handful of GTM containers and want each one built, named and tested the same way. It assumes you know GTM basics. The naming convention is a recommendation: change it to match your team, then apply it everywhere.

## Install

### Claude.ai

1. Download the skill file: [gtm-setup.zip](https://github.com/In-Motion-Marketing/GTM-Setup/releases/latest/download/gtm-setup.zip). Do not unzip it.
2. Turn on code execution, which custom skills need. On Free, Pro, Max and Ultra plans: Settings > Capabilities > "Code execution and file creation" (called "Create and edit files" in the newer layout). On Team it is on by default. On Team and Enterprise, if you cannot create skills, ask an Owner to check Organization settings > Plugins & skills > Policy and turn on code execution and "Skills".
3. Go to Customize > Skills, click "+", click "+ Create skill", choose "Upload a skill" and pick `gtm-setup.zip`.
4. Find "gtm-setup" in your skills list and toggle it on.

Use the link above, not GitHub's green "Code > Download ZIP" button. That button downloads the whole repository, which Claude.ai does not recognize as a skill.

To update, download the file again from the same link and upload it again. Claude.ai uploads do not update on their own.

### Claude Code

Inside a Claude Code session:

```
/plugin marketplace add In-Motion-Marketing/GTM-Setup
/plugin install gtm-setup@gtm-setup
```

The second command opens the plugin's details. Pick a scope (just you in every project, everyone on this repository, or just you in this repository) and Claude Code installs it. On Claude Code v2.1.275 or later you can do both in one step: `/plugin install gtm-setup --marketplace In-Motion-Marketing/GTM-Setup`.

From your shell instead of a session:

```sh
claude plugin marketplace add In-Motion-Marketing/GTM-Setup
claude plugin install gtm-setup@gtm-setup
```

Claude Code clones over SSH when your SSH key works with GitHub and over HTTPS when it does not. If the clone hangs or fails over SSH (for example a key with a passphrase), set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and try again.

**Getting updates**: auto-update is off by default for marketplaces outside Anthropic's own. To turn it on, run `/plugin`, open the Marketplaces tab, select gtm-setup and turn auto-update on. New versions then install when a session starts.

To update by hand, run `/plugin`, open the Installed tab, select gtm-setup and choose "Update now". From your shell:

```sh
claude plugin update gtm-setup@gtm-setup
```

Then run `/reload-plugins`, or start a new session. Note that `/plugin marketplace update gtm-setup` only refreshes the listing and does not update the installed plugin.

**Manual copy (no plugin)**: copy the skill folder into `~/.claude/skills/` (all projects) or a project's `.claude/skills/` (that project only). This copy does not update itself.

```sh
git clone https://github.com/In-Motion-Marketing/GTM-Setup.git
mkdir -p ~/.claude/skills
cp -R GTM-Setup/skills/gtm-setup ~/.claude/skills/
```

To update a manual copy, run `git -C GTM-Setup pull` and copy the folder again.

### Using it

Ask for GTM work as usual ("audit this GTM container", "set up GA4 and Google Ads conversion tracking for the contact form") and the skill loads. In Claude Code you can also call it directly: `/gtm-setup:gtm-setup` when installed as a plugin, or `/gtm-setup` for a manual copy.

## Headline finding: optimized containers can silently drop hits

When you move a container to the new GA4 or Google Ads destination tags, GTM's event tags for that ID can stop sending anything at all. Tag Assistant still shows the tags as fired. In one agency audit, about a third of the optimized containers showed this pattern, and live tests confirmed lost Google Ads conversions and GA4 events.

**Cause**: the GA4 or Ads ID belongs to a *combined* Google tag (Google merged GA4 and Ads into one tag). GTM copies that tag's `__zone` into the container, and on the live site the combined tag loads as a child that takes over the destination. GTM's event tags for that ID go nowhere, and you get a second page_view per load.

**Detect it in 10 seconds**: before optimizing, open this URL for each Google ID and search the response for `"function":"__zone"`:

```
https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX
```

A zone means do not optimize on its own. On a container that is already optimized, run this in the console on the live site:

```js
const c = google_tag_data.tidr.container;
Object.keys(c).filter(k => /^(G|AW)-/.test(k) && c[k].parent)
```

Any ID it returns is loading as its own Google tag next to GTM.

**Fix**: build the modern setup in GTM, publish it, then immediately open the combined Google tag and publish it with every destination tag paused. Its gtag/js then serves an empty container, so GTM's own destination tags send every hit exactly once. The skill covers the full steps, the publish order, the rollback, the guard against Google prompts that unpause the tags, what "expected and harmless" looks like afterwards, and the workarounds that were tried and failed (deleting the combined tag, removing linked IDs, a new GA4 stream, the move API). If you cannot edit the combined tag, the skill falls back to legacy Google Tags with a Conversion Linker.

## Verify with real submits, not Tag Assistant

"Tag fired" is not proof. A Google Ads conversion counts only when `pagead/conversion/<id>` with the right `label` leaves the browser; a GA4 event counts only when `g/collect` carries the right `en`. Preview can pass while the live site fails, and browser network panels often miss the requests sent between a form submit and its redirect. The skill includes a small `sessionStorage` logger you arm before submitting and read on the landing page, plus a 1-second redirect-delay mu-plugin for Gravity Forms, whose add-on can redirect before GTM's tags finish sending.

## Credits

The underlying GTM and GA4 methods follow Julius Fedorovicius and [Analytics Mania](https://www.analyticsmania.com/): build order, listener patterns, form tracking recipes and the legacy Google tag rollback. The naming convention, audit checklist, dropped-hit diagnosis and fixes come from hands-on agency work.

Written by In Motion Marketing ([inmotionmktg.com](https://inmotionmktg.com)).

## License

MIT. See [LICENSE](LICENSE).

## Maintainer notes

### Release a new version

1. Bump `version` in `.claude-plugin/plugin.json` (for example `1.0.1`). Claude Code users only get an update when this string changes. Do not add `version` to `marketplace.json`.
2. Commit, then tag and push the branch and the tag: `git tag v1.0.1 && git push origin HEAD v1.0.1`.
3. The `Release` workflow runs `scripts/build-zip.sh` and attaches `dist/gtm-setup.zip` to the GitHub Release for that tag, marked as latest, so the Claude.ai download link always points to it. To rebuild an existing tag, run the workflow by hand from the Actions tab.

Check before tagging: `claude plugin validate .` and `sh scripts/build-zip.sh && unzip -l dist/gtm-setup.zip` (every entry must start with `gtm-setup/`).
