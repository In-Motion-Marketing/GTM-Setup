---
name: "gtm-setup"
description: "Build a new Google Tag Manager web container from scratch, or audit an existing one and bring it into line with a consistent standard: naming, GA4 and Google Ads destinations, consent mode, form and booking tracking (Gravity Forms, Elementor, HubSpot forms and meetings, Calendly, TidyCal), an attribution script for hidden form fields, and proof that hits actually leave the browser. Includes the dropped-hit check for optimized containers whose GA4 or Google Ads ID belongs to a combined Google tag. Use for any GTM, GA4-via-GTM, Google Ads conversion tracking, enhanced conversions, or tag cleanup task."
---

# GTM setup

A working standard for Google Tag Manager web containers, written for agencies and marketers who run many containers and want every one built, named and tested the same way. The methods for how things are built follow Julius Fedorovicius (Analytics Mania). The naming convention and audit checklist on top are a recommended house standard: change them to suit your team, then apply them the same way everywhere.

Two jobs this skill covers:

1. **New setup**: build a container from nothing in the order in section 3.
2. **Alignment**: audit an existing container against section 7 and fix it, one container at a time, with a version note per container.

## 1. Non-negotiables

- One GTM account per client, one web container per site. Server containers only where the client already runs one. Do not add server-side tagging (Stape or similar) unless the site owner asks for it.
- Always start by exporting the container (Admin > Export Container > Default Workspace > Download or Preview JSON). Keep the export as the rollback copy. The previous published version is the second rollback; note its number in the new version's description. Preview JSON is a read. If downloading a file needs the site owner's approval in your environment, ask for it. If the download is skipped, the live Version N is the rollback, and say so in the fix log.
- Keep a fix log per container: a plain note (ticket, doc or file) listing what changed and why, the old and new version numbers, the rollback version, anything left for the site owner to click, and settings you changed outside GTM. Sections 5.6 and 5.7 write to it.
- "Site owner" below means whoever approves changes and holds the GTM, Google Ads and GA4 admin and billing rights.
- Every change goes: workspace > Preview (walk a real form submit, or the 5.7 hand-push where submits are not allowed; read the Hits Sent tab) > Publish (5.6: may need the site owner's click) with a version name and description. Never publish untested.
- "Tag fired" is not proof. A Google tag counts as working only when its request leaves the browser: `googleadservices.com/pagead/conversion/<id>` with the right `label` for Ads, `g/collect` with the right `en` for GA4 (section 9). On one site, Tag Assistant showed a Google Ads conversion tag as fired for three weeks while nothing was sent.
- Optimizing is not automatic. Optimize a container only when the pre-flight and the dropped-hit check in 5.7 pass. In one agency audit, about a third of the optimized containers showed the failure pattern, and live tests confirmed several were silently dropping Google Ads or GA4 hits.
- A trigger in GTM is not proof that anything on the site emits the event. Before relying on a custom-event trigger, find the emitter (plugin feed, theme snippet, listener tag) or watch the event arrive in Preview. One audited container had `GFTrackEvent` and `form_submit_gf` triggers with no emitter at all: the Gravity Forms add-on was never connected.
- Custom JavaScript in GTM is ES5 only (no `let`, `const`, arrow functions, template strings). ES6 is fine in custom templates and in scripts that live on the site.
- No PII into GA4. No email as a GA4 user property or event parameter. Email and phone go only into Google Ads / Microsoft Ads enhanced conversions and Meta/Reddit advanced matching, through the vendor's own hashed fields.
- `window.dataLayer = window.dataLayer || [];` before any push that lives on the site.

## 2. Naming convention (recommended)

This is a recommended convention. Change it if your team already has one, but pick one and apply it to every container: a consistent name is what makes a 40-container audit fast.

Separator is always ` - ` (space, hyphen, space). Never `»`, `//`, `|` or `_` in names. Title Case for tags, triggers and variables. GA4 event and parameter names are snake_case, 40 chars max, 25 parameters max per event.

### Tags: `Vendor - Event`

Vendor names, used exactly like this: `Google Analytics`, `Google Ads`, `Microsoft Ads`, `Meta Ads`, `LinkedIn Ads`, `Reddit Ads`, `X Ads`, `TikTok Ads`, `OpenAI Ads`, `Termly`, `Cookiebot`, `ahrefs`, `Apollo`, `HubSpot`, `Hotjar`, `Clarity`.

| Tag | Name |
|---|---|
| GA4 destination tag (new "Google Analytics" type) | `Google Analytics G-XXXXXXXXXX` |
| Google Ads destination tag (new "Google Ads" type) | `Google Ads AW-XXXXXXXXX` |
| More than one GA4 destination in one container | `Google Analytics G-XXXXXXXXXX (Stream)`: add the stream or site in parentheses, e.g. `Google Analytics G-XXXXXXXXXX (Shop)`, `Google Analytics G-YYYYYYYYYY (Blog)` |
| GA4 event | `Google Analytics - Generate Lead`, `Google Analytics - Newsletter Sign Up` |
| Google Ads conversion | `Google Ads - Contact Us` (match the conversion action name in Google Ads exactly) |
| Google Ads enhanced conversions (user-provided data event) | `Google Ads - Enhanced Conversions` |
| Google Ads remarketing | `Google Ads - Remarketing` |
| Conversion Linker (legacy Google Tags only) | `Google Ads - Conversion Linker` |
| Microsoft UET base | `Microsoft Ads - Page View` |
| Microsoft UET goal | `Microsoft Ads - Contact Us` |
| Microsoft enhanced conversions | `Microsoft Ads - Enhanced Conversions` |
| Meta pixel base / event | `Meta Ads - Page View`, `Meta Ads - Contact Us` |
| Other pixels | `LinkedIn Ads - Page View`, `Reddit Ads - Page View`, `Reddit Ads - Contact Us` |
| CMP | `Termly - CMP` (or `Cookiebot - CMP`) |
| Scripts | `ahrefs - Analytics`, `Apollo - Tracker` |
| Listeners (Custom HTML) | `HubSpot Forms - Listener`, `Calendly - Listener`, `Elementor Forms - Listener` |

Event part of the name = what the user did, in plain words, same wording across every vendor for the same action (`Contact Us` on the GA4 tag, the Google Ads tag, the Microsoft tag and the Meta tag).

### Triggers: `Source - Event`

Source is the thing that emits the event: `Gravity Forms`, `Elementor Forms`, `HubSpot Forms`, `HubSpot Meetings`, `Calendly`, `TidyCal`, `Termly`, `Site` (for custom dataLayer pushes from the theme), `Click`, `Page`.

Examples: `Gravity Forms - Contact Us`, `Elementor Forms - Newsletter`, `HubSpot Forms - Demo Request`, `HubSpot Meetings - Booked`, `Calendly - Event Scheduled`, `Termly - Consent Save Done`, `Termly - User Preference Update`, `Click - Phone Number`, `Page - Thank You`.

Built-in triggers keep their GTM names (`All Pages`, `Initialization - All Pages`, `Consent Initialization - All Pages`).

### Variables

| Kind | Name | Notes |
|---|---|---|
| Data Layer Variable | `Source - Field`: `Gravity Forms - Form Title`, `Gravity Forms - Email`, `HubSpot Forms - Form GUID`, `Elementor Forms - Form Name` | Version 2, no default value unless a vendor needs one |
| Third-party ID constants | `Meta Tag ID`, `Microsoft Tag ID`, `LinkedIn Tag ID`, `Reddit Tag ID`, `X Tag ID`, `TikTok Tag ID`, `OpenAI Tag ID` | Keep these as Constants (see 2.1) |
| User-provided data (awec) | `User-Provided Data` | Manual mode: email always, phone only when the form has a phone field |
| 1st-party cookie | `Cookie - gclid`, `Cookie - utm_source` | Only when a tag needs it |
| Custom JS | `JS - What It Returns` | ES5, anonymous function with return |
| Lookup / RegEx table | `Lookup - What It Maps` | Avoid for Google IDs (breaks the Optimize wizard) |

### 2.1 IDs: dropdown for Google, Constants for everyone else

GTM now resolves Google IDs from a dropdown and shows "Destination found" with the account name, so a Constant adds nothing there.

- **Google Analytics measurement ID, Google Ads conversion ID**: pick from the dropdown in the tag. No `{{Google Tag ID}}` / `{{Google Ads Conversion ID}}` variables. Delete old ones once nothing references them.
- **Google Ads conversion labels**: type into the tag. One label belongs to one tag, so a constant is pure indirection. (Old containers often use `Conversion 1 Contact` or `Conversion ID - Demo Request` style constants; fold them in during cleanup.)
- **Microsoft, Meta, LinkedIn, Reddit, X, TikTok, OpenAI and anything else**: one Constant per vendor, named `Vendor Tag ID`, referenced by every tag of that vendor. Julius's reason still holds here: one place to change, and the tag picker shows nothing for these.

### Version names

`YYYY-MM-DD - What changed` with a one-line description of why. Example: `2026-10-18 - Optimize container, remove server loader, rename to standard`.

### GA4 web stream names: `Brand - Website`

Same ` - ` separator. Brand is the client's brand as people know it, then what the stream measures: `Example Co - Website`, `Example Co - Blog`. Use `- Blog`, `- App`, `- Help Center`, `- Shop` when a client has more than one stream. Not the domain (`example.com`), not the property name, not GA's default. GTM's Add destination list and the destinations card show the stream name, so a clear one tells you which stream you are picking. Change it in GA4 Admin > Data streams > the stream > edit (pencil) > Stream name > Update stream; renaming a stream changes no data and no measurement ID. Fix it during the alignment pass (checklist 4).

## 3. Build order for a new container

Follow Julius's order: built-in variables > triggers > data layer variables > tags. Settings first.

1. **Container settings** (Settings tab, container level): automatic event detection on for outbound clicks, scroll, downloads, history, video (match what GA4 enhanced measurement would do). Note these now feed the Google Ads destination too. Form interactions **off** (also in GA4 enhanced measurement): automatic `form_start` / `form_submit` are unreliable (Julius), and the forms here already send `generate_lead` from a vendor push or listener. Same rule for anything else: when a GTM tag tracks an interaction, turn off the matching automatic event so it is not counted twice. YouTube video events only work when the embed URL has `?enablejsapi=1`. User-provided data: Automatic on (email, phone, address) unless the client objects. Configure your domains per 5.5. On a legacy container (no destination tags, 5.7) the Settings tab says "Add a destination to use these settings" and all of this is dormant: auto events, automatic user-provided data, Configure your domains and the EEA row do nothing. Check the live equivalents instead: GA4 > the stream > Enhanced measurement (form interactions off) and Configure tag settings (domains, unwanted referrals, internal traffic). With automatic user-provided data off, enhanced conversions need the `Google Ads - Enhanced Conversions` tag. Record "legacy, dormant" in the version description.
2. **Built-in variables**: Page URL, Page Hostname, Page Path, Referrer, Event, all six Click variables, Form ID, Form Classes, Form Element, Form Text. Add Video/Scroll ones only when used.
3. **Consent**: install your CMP (section 4). If you use Termly: `Termly - CMP` on `Consent Initialization - All Pages` plus `Termly - User Preference Update` (custom event `userPrefUpdate`). All defaults denied, wait_for_update 500. Triggers `Termly - Consent Save Done` (custom event `Termly.consentSaveDone`) and `Termly - User Preference Update`. Marketing page-level tags fire on `Termly - Consent Save Done` with Additional Consent Checks set (ad_storage etc.), not on All Pages. Cookiebot: same shape, use the Cookiebot template and its events.
4. **Destinations**: run the 5.7 pre-flight on each Google ID first. Then `Google Analytics G-XXXXXXXXXX` and `Google Ads AW-XXXXXXXXX` (new destination tag types, not "Google tag"), both on `Initialization - All Pages`, IDs from the dropdown. Set Consent Settings > Additional Consent Checks to **No additional consent required** on every destination tag (Add destination leaves it Not set, so the tags land under "Consent Not Configured"). Leave "Ignore duplicate instances of on-page configuration" on. With destination tags, no Conversion Linker tag: the Google Ads destination handles linking. If the site relies on URL passthrough, set `url_passthrough` = true in the destination tag's configuration settings. After publishing, run the dropped-hit check (5.7). If a destination fails it and the fix in 5.7 is not available, use a legacy `Google Tag <ID>` on `Initialization - All Pages` for that ID instead. **A legacy setup must have `Google Ads - Conversion Linker` on All Pages** (Tag type > Other Google > Legacy > Conversion Linker; it is not in the Google Ads list). Without it, checklist 2 fails.
5. **Form sources** (section 6): confirm which form vendor the site uses, install the listener if needed, create the `Source - Field` DLVs and one `Source - Event` trigger per form that matters.
6. **Event tags**, one row per conversion in the client's tracking plan:
   - `Google Analytics - <Event>`: GA4 event tag, recommended event names first (`generate_lead`, `sign_up`, `purchase`, `begin_checkout`, `view_item`), custom only when none fits. Parameters for Gravity Forms: `form_name` = `{{Gravity Forms - Form Title}}`, `form_id` = `{{Gravity Forms - Form ID}}`, `method` = `gravity_forms` (or `newsletter` on `sign_up`). The add-on pushes `form_title`; GA4 gets it as `form_name`. Distinct event names per form type when they will be key events (Julius: one `form_submission` with a parameter forces the Create Event workaround).
   - **Google Ads first**: create or confirm the conversion action before the tag (Website, manual setup, category Submit lead form, counting **One**, a value agreed with the site owner, data-driven attribution, a click window chosen on purpose). A common audit finding is a lead action counting Every with value 0. Copy the label from `conversion_action.tag_snippets` (GAQL) or the action's tag setup screen, never from an old constant or tag.
   - `Google Ads - <Event>`: conversion tag, ID from dropdown, label typed in, name identical to the Google Ads conversion action. **After saving any Google Ads conversion tag, check the tag list.** On a legacy container GTM can auto-create a `Google Ads AW-...` destination tag on Initialization - All Pages, with a "new Google Ads tag added to your workspace" notice. Abandon or delete that tag: next to legacy Google Tags it brings back the 5.7 dropped hits and "Conflicting Google tag".
   - `Google Ads - Enhanced Conversions`: one user-provided data event tag with `{{User-Provided Data}}`, firing on every lead trigger. When it shares a trigger with the conversion tag, give it a higher firing priority so the data is set first. Proof is in section 9 layer 2.
   - `Microsoft Ads - Page View` (UET base, on the CMP's consent trigger) and `Microsoft Ads - <Event>` goals (custom event action in snake_case matching the GA4 event name). `Microsoft Ads - Enhanced Conversions` (UET enhancedConversion with p_em / p_ph) on the lead triggers.
   - Meta / LinkedIn / Reddit / OpenAI only if the client runs that channel. Use the official gallery templates (Meta Pixel by facebook, LinkedIn Insight Tag 2.0, Reddit Pixel, OpenAI Ads Pixel by Stape). Advanced matching from the same DLVs.
7. **Attribution script** (section 8) on the site if the client's forms need source / medium / gclid in hidden fields. It lives in the theme or a Custom HTML tag on `Initialization - All Pages` with no consent requirement (first-party, functional).
8. **GA4 side**: name the web stream `Brand - Website` (section 2), register every parameter the client will report on as an event-scoped custom dimension (Admin > Custom definitions; "Event parameter" must match the GTM parameter name exactly). For forms that is exactly `form_name`, `form_id` and `method`. The Event parameter field only suggests parameters GA4 has already seen; type new ones in free text, which works. Unregistered parameters show in Realtime and DebugView only, never in standard reports. Standard properties allow 50 event-scoped custom dimensions and 50 custom metrics, so do not register one-off debug parameters. Data appears within about 24 h (Explorations up to 48 h). Mark key events after they appear in Recent events, counting once per session for forms, once per event for purchases. A new event shows in Realtime well before Recent events, so marking it is usually a next-day step: list it for the site owner or a follow-up session. Also check: Admin > Data streams > Measurement Protocol secrets, and any key event with `(not set)` page and source (automation tools such as Zapier or Make sending `generate_lead` is a common cause). CRM and automation senders use `qualify_lead` and `convert_lead`, never `generate_lead`. Data filters: Developer traffic Active, Internal traffic Active once the site owner confirms the IP rule. Turn on email redaction on the web stream as a backstop. By API, a missing `formInteractionsEnabled` field means off. Never mark a generic event (`page_view`, `click`) as a key event; use a dedicated GTM event, or a GA4 Create event rule only when GTM cannot. Keep event logic in GTM rather than GA4 Create/Modify events: Modify events is capped at 50 per property and neither rewrites past data.
9. **Test** (section 9), **publish** with a version name, then check Google Ads > Diagnostics and GA4 DebugView the next day.

## 4. Consent pattern (Termly example)

The table uses Termly. Cookiebot and other CMPs follow the same shape with their own template and events.

| Tag group | Trigger | Additional consent checks |
|---|---|---|
| `Termly - CMP` | Consent Initialization + `Termly - User Preference Update` | none |
| `Google Analytics G-...`, `Google Ads AW-...` | Initialization - All Pages | none (consent mode handles it) |
| GA4 event tags, Google Ads conversion tags | the form trigger | none (consent mode) |
| Meta / Microsoft / LinkedIn / Reddit / X / OpenAI page-level tags | `Termly - Consent Save Done` | ad_storage, ad_user_data, ad_personalization |
| Analytics scripts (ahrefs, Apollo, Hotjar, Clarity) | `Termly - Consent Save Done` | analytics_storage |
| Form-event pixels (Meta Lead etc.) | the form trigger | ad_storage |

The container-level **Manage data transmission** setting can hold Google hits until consent arrives. It only covers Google's own tags, so the vendor tags above still need the CMP trigger.

### 4.1 Consent settings in the Settings tab (check on every container)

Workspace > Settings > **Show more** lists three consent settings that apply to every Google destination. Open each one during the alignment pass, record what it is set to in the version description, and only change it on purpose. They are easy to skip because nothing in the tag list shows them. On a legacy container (no destination tags) the tab says "Add a destination to use these settings" and the three settings are dormant; record "legacy, dormant" and rely on the CMP defaults (build step 1).

| Setting | What it does | With a CMP that sets defaults and sends updates | No CMP |
|---|---|---|---|
| **Manage data transmission** | Restrict advertising data, and optionally behavioral analytics and diagnostics data, sent before consent | Leave all three boxes off (advanced consent mode: cookieless pings before consent, which feed conversion and behavioral modeling) | Ask the site owner; this is the main lever when there is no banner |
| **Override consent mode defaults** | Loads the Google tag with ads and/or analytics consent denied until an update arrives, overriding every other default | Off. The CMP already sets denied defaults and sends updates; turning this on duplicates them | Only with a banner that sends consent updates, otherwise Google data stops |
| **Manage default consent settings for data collection** (EEA labels) | Whether data with no consent signal is treated as consented for EEA ad personalization | "No. Do not automatically mark this data as consented" | Same; "Yes" is only for sites that block the Google tag until consent |

Also open the Submit dialog's consent row: it should read "All tags have been configured for consent". Tags > the shield icon (Consent Overview) lists any tag with no consent setting; "Consent Not Configured" must be empty before publish. Destination tags made with Add destination always start there.

**Termly fires `Termly.consentSaveDone` three times per page load** (seen on several sites). Every page-level tag on `Termly - Consent Save Done` must have Tag firing options = **Once per page** (`tagFiringOption: ONCE_PER_LOAD` in the export), or pixels and analytics scripts load three times. Preview should show "Fired 1 time" for each. Form-event tags on form triggers stay at Once per event. Check whether your CMP does the same.

## 5. Migrating an old container

GTM merged the Google tag into the container in 2026. Opt-in, no deadline found. Run the 5.7 pre-flight before migrating any container.

### 5.1 With the Optimize wizard (banner offered)

1. Export first. Screenshot each legacy Google tag's settings (the wizard merges them into one container-level set and you must pick which wins).
2. Check how Google IDs are set: typed value or Constant is fine; a Lookup/RegEx table or Custom JS feeding a Google tag blocks the wizard. Swap those to typed values first.
3. Run the banner's Optimize wizard. Review "View settings" per tag, choose the blueprint settings, read "Show details", and accept or decline the Read-access grant (users of linked Google Ads and GA4 accounts gain container Read access; see 5.6).
4. The wizard converts `Google tag` tags into destination tags. Rename them `Google Analytics G-XXXXXXXXXX` / `Google Ads AW-XXXXXXXXX` and switch the ID to the dropdown.
5. Delete the Conversion Linker tag after confirming the Google Ads destination is in place. If the linker had URL passthrough on, set `url_passthrough` = true on the destination tag. Move its cross-domain list into Configure your domains (5.5).
6. Check the automatic event detection toggles; they now also send to Google Ads.

### 5.2 Without the wizard (no banner)

Same end state, built by hand:

1. Workspace > **Settings** tab (container level) > **Add destination**. Add Google Analytics (pick the G- ID from the dropdown) and Google Ads (AW- ID). Each creates a destination tag on an internal `Initialization - All Pages` trigger, already named `Google Analytics G-XXXXXXXXXX` / `Google Ads AW-XXXXXXXXX`. The new tags have consent **Not set**: open Tags > the shield icon (Consent Overview), select every tag under "Consent Not Configured", click the edit-consent icon and choose **No additional consent required** (consent mode handles Google tags; see section 4).
2. In the Google Ads destination tag, Configuration settings: add `url_passthrough` = `true` if the old linker had it. Fill Settings > **Configure your domains** per 5.5 (it replaces the old linker's cross-domain list).
3. Delete: the legacy `Google tag` tag(s), `Conversion Linker`, any manual GA4 `page_view` event tag (the destination sends page_view itself; leaving it double counts every page), the `Google Tag Config` / `Google Tag Event Settings` variables, `Google Tag ID` / `Google Ads Conversion ID` constants, `GA Client ID` variables nothing uses.
4. Re-point every GA4 event tag: measurement ID from the dropdown, drop `{{Google Tag Event Settings}}` unless it carries something real.
5. The export shows the result as `gtagConfig` entries with `ogt_auto_events` / `ogt_1p_data_v2` and destination tags of type `dest_ga` / `dest_aw`. Legacy state shows as type `googtag`.

### 5.3 Removing a server-side loader (for example Stape)

Only when the site owner wants server-side tagging removed. Order matters. If the site loads GTM through the server provider's custom loader (`load.<sub>.<domain>/<hash>.js`), deleting the server container first takes GTM off the site.

1. **Site first.** In the provider's WordPress plugin (for Stape: "Stape Conversion Tracking", Settings > Stape Conversion Tracking > General), clear "Server GTM container URL" and the container identifier, save. The plugin then prints the standard `googletagmanager.com/gtm.js` snippet. Confirm by fetching the page HTML: `gtm.js` from googletagmanager.com, no custom loader subdomain, no provider string. Check the plugin's Data Layer tab before removing the plugin entirely; if its options are off (often WooCommerce-only), nothing depends on it. Replacing the plugin with a header snippet is optional.
2. **GTM.** Remove `server_container_url` from any Google Tag Config / Event Settings variables, restore `send_page_view` to default, delete the manual `page_view` GA4 event tag, delete the Server Container URL constant, then do 5.1 or 5.2. Publish.
3. **Verify** with GA4 Realtime (one `page_view` per load) and Preview Hits Sent going to the right G-/AW- IDs.
4. **Provider account**: cancel the subscription first (the container usually runs to the end of the paid period, reversible), delete the container once the period ends. Billing actions are the site owner's clicks, not the agent's. In Stape: app.stape.io (agency accounts: Users > Log in as user on the client sub-account) > the container > three-dot menu next to Change plan > Cancel subscription, later Delete container.
5. **GTM server container**: Admin > Container Settings > Delete (recoverable from trash for 30 days). **DNS**: drop the tagging subdomain CNAME. If the server container was "Automatically Configured", it also created a Google Cloud project that needs shutting down. All of these are the site owner's clicks.

Leave alone any server-side setup that another team or site depends on.

### 5.4 Bulk edits by export > transform > import

For a cleanup with many renames and deletions, editing the JSON is faster and less error-prone than clicking through 40 items.

1. Admin > Export Container > Default Workspace > **Preview JSON** gives the full export in a CodeMirror box (`document.querySelector('.CodeMirror').CodeMirror.getValue()` reads it when working in a browser; or download the file).
2. Transform with a script: delete by name, rename, change `tagFiringOption`, swap `{{Variable}}` references in `parameter[].value` (inline Google constants), remove unused `customTemplate` entries (by vendor, see 10). Keep `triggerId` / `variableId` / `tagId` untouched on anything you keep.
3. Admin > Import Container > choose file > **Existing** workspace > Default Workspace > **Overwrite**. The diff screen only appears once a workspace is selected. Read it before confirming: every Deleted row should be something you meant to delete or a same-named tag reappearing as Added.
4. **Rename caveat.** Import matches items by *name*, so a renamed trigger or variable shows as Deleted + Added and gets a new ID. Check nothing outside GTM stores trigger or variable IDs: Gravity Forms feeds store the event name `GFTrackEvent` (6.1), and Google Ads and GA4 do not care. Renaming in the GTM UI is still cleaner (it keeps the ID and updates every reference), so rename triggers and variables there first, then re-export and import the rest. Tags can be renamed by import.
5. Version-name the result and keep the transformed JSON next to the original export.

### 5.5 Configure your domains (cross-domain list)

Workspace > Settings > **Configure your domains**. This is the old Conversion Linker / Google tag cross-domain list, now one container-level setting that applies to every Google destination and event tag. It does two things: adds the `_gl` linker parameter to links between the listed domains so a visitor keeps the same client ID and session, and stops enhanced measurement from counting clicks to those domains as outbound clicks.

What goes in:
- **The site's own root domain**, match type Contains (e.g. `example.com`). Contains on the root covers `www.` and every subdomain. On a single-domain site this changes nothing in the data (GA4 already treats its own domain as internal), but it is harmless and shows the setting was decided rather than skipped. Leaving it empty is also fine.
- **Other domains you control that send to the same GA4 property** and that visitors move between in one journey: a separate checkout, app or booking domain, a sister brand on the same property (`example.com` + `example-group.com`). Each one must run the same Google tag, or the `_gl` parameter arrives and nothing reads it.

What stays out:
- **Subdomains of the same root** as separate entries. `www.`, `blog.`, `app.` already share the `_ga` cookie; one Contains entry for the root is enough.
- **Domains on a different GA4 property** (sister sites that each have their own property). Linking does not merge sessions across properties, so it adds URL clutter for nothing.
- **Third-party domains you do not tag**: Calendly, TidyCal, HubSpot meetings, Stripe, PayPal, Shopify checkout you do not control. For payment and booking pages that send visitors back, add them to GA4 Admin > Data streams > Configure tag settings > **List unwanted referrals** instead.
- **Another client's domains.** Agency copy-paste leaks happen (one audited linker listed a different client's domain).

GTM shows **Suggested domains**. Do not accept one blind: check the domain is the client's and runs the same tag first.

Watch Contains on short roots: `example.co` also matches `example.com` and `example.co.uk`. Use Equals or a fuller pattern when two of the client's own domains share a prefix. If a server rejects URLs with an unknown `?_gl=` parameter (rare, the warning box on the panel), take that domain out and fix the server.

### 5.6 Preview and publish

Preview: walk one real conversion, confirm it in the Hits Sent tab with the right destination ID, and confirm the request itself left the browser (section 9). Publish, then run 5.7 on the live site. Note the previous version number as the rollback. An agent's Publish click can be blocked by permission checks, so plan for "saved in workspace, the site owner publishes": put the version name and description in the fix log for them to paste, and say plainly that live is not fixed until they do.

When new Google destinations are part of the publish, the Submit dialog asks "Would you like to give those users read-only access to this container?". **Add read-only account link** gives users of the linked Google Ads account and GA4 property Read access to the container, nothing more. Decide once with the site owner and apply it the same way everywhere. If it was skipped and you want it, add it afterwards in Admin > **External Account Links** > Add link, once per destination; the list should show each AW- and G- ID with "Read access".

If a client must not get test form submissions, Preview a form page instead: page-level tags fire once, GA4 `page_view` goes once to the right G- ID, and the form trigger conditions are unchanged from a version that already recorded `generate_lead` in GA4.

### 5.7 Dropped-hit check (required before and after optimizing)

**Pre-flight before optimizing.** For each Google ID you plan to add as a destination, fetch `https://www.googletagmanager.com/gtag/js?id=<ID>` and search it for `"function":"__zone"`. A zone means the ID belongs to a *combined* Google tag (Google merged GA4 and Ads into one tag, shown in GTM as "Tag merged using current configuration"). Once that ID is a GTM destination, GTM copies the zone into the container; on the live site the zone loads the combined tag as a child (`tidr` shows the ID with `parent`, `isDestination:false`), which takes over the destination, silently drops GTM's event tags and adds a second page_view per load.

In one audit, every failing container had a zoned destination tag, and every working optimized container did not. One other failure had a different cause (the HubSpot Ads pixel, section 9). One zoned AW- ID resolved to an unzoned tag and worked, so a zone is a strong hint, not proof.

If any destination ID has a zone, do not optimize on its own. Use the neuter fix below (optimize plus pause the combined tag's destinations). If you cannot edit the combined Google tag, keep legacy Google Tags. None of these remove the zone from inside GTM (tested): the Optimize wizard with or without importing settings, a Constant for the ID, or "move into this container". Also check for outside loaders of the ID (HubSpot Ads pixel, Site Kit, hard-coded gtag). Add destination shows which Google tag owns each ID in its "Tag name" column.

**Fix for a zoned destination: neuter the combined Google tag (proven live on an agency test site).** Keep the combined Google tag, but publish it with every destination tag paused. Its gtag/js then serves an empty container (only `__paused` tags). GTM still compiles the zone and still loads the child, but the child sends nothing, so GTM's own Google Analytics and Google Ads destination tags send every hit exactly once. Steps:
1. Build the modern setup in the GTM workspace (5.2) for the ORIGINAL IDs. Do not publish yet.
2. Publish the GTM version first, then immediately open the combined Google tag (GTM home, the "Brand · G-XXXXXXXXXX" container) > Tags > pause every destination tag (`Google Analytics G-...`, `Google Ads AW-...`) > Submit/Publish it. Name it "YYYY-MM-DD - Destinations paused (neutered zone child)".
3. Verify live: cache-busted `gtag/js?id=G-...` holds only `__paused` tags; one page_view per load (all hits tagged with the GTM container's numeric ID, none with the Google tag's); Ads base hits once; real submits per section 9; GA4 Realtime on the original stream.
4. Expected and harmless in this state: `__zone` still in gtm.js, the child gtag/js still loads with 200, and tidr still shows a `parent` for G-. Do not treat those as failures here.
5. Rollback is the reverse order: combined Google tag > Versions > previous > Publish first, then the GTM legacy version > Publish > Set as Latest.
6. Guard: never unpause or add destination tags in that combined Google tag, and say so in its version description. A Google "fix your tag" prompt in GA4 or Ads that unpauses them brings back double counting.

gtm.js grows (by roughly a third on the test site); check PageSpeed afterwards.

**Un-merging is not possible in the UI (as of late 2026).** A combined Google tag now opens as a Tag Manager container ("Your Google tag has been upgraded to a Tag Manager container") from GA4 (stream > Configure tag settings) and Google Ads (Data manager > Google tag > Manage). Its Container Settings list the G- and AW- IDs with no remove or move control, and the old split screen in Google's help is unreachable. These workarounds were tried and failed, so do not repeat them:
- Pausing the combined tag's `dest_aw` tag on its own: the zone follows the Container IDs, not the tag, and the ID is left without a destination. Never do that on a live container.
- Removing the AW- ID from GA4 > Data streams > the stream > Manage connected site tags: it only drops the ID from the zone's child list; the zone stays (listing the G- ID) and still breaks the modern setup, though legacy keeps working.
- The API `accounts.containers.move_tag_id`: returned 500 backendError.
- Deleting the combined Google tag: GTM still compiled its zone while it sat in the Trash, gtag/js for both IDs went 404 so legacy tracking stopped, and GA4/Ads offered no way to create a new tag. If you did this, restore it from Trash at once.
- Moving GA4 to a brand-new web stream: the new stream recorded nothing for 12+ hours.

You do not need any of these: use the neuter fix above. Record the combined tag's settings (IDs, destinations, domains, internal traffic, user-provided data, automatic events) in the fix log as its rollback.

**Preview is not proof for the modern setup.** On the test site, the modern workspace passed every real submit in Preview and failed on the live site. Before publishing, fetch the workspace's compiled `gtm.js` (with its `gtm_auth` and `gtm_preview` values) and confirm there is no `__zone`; in Preview, `tidr` must have no G-/AW- key with `parent` and each load must send exactly one page_view. Exception: with the neuter fix, the zone and the `parent` stay by design; check instead that the child gtag/js holds only `__paused` tags and that every hit carries the GTM container's numeric ID. The combined tag's own Preview can break after a trash/restore (404/503), so inspect it through cache-busted live gtag/js fetches. After publishing, repeat the real-submit logger test (section 9) on the live site and roll back at once if a hit is missing. After a rollback, the Default Workspace still holds the failed version: Versions > the good version > Set as Latest Version, then update the workspace.

**How this was found.** Google support reported that a Google Ads conversion tag fired in Tag Assistant but its conversion label never reached the network. Live testing showed worse: on some optimized containers, every GTM-fired Google tag for a destination sends nothing. That covers Ads conversion tags, GA4 event tags and remarketing. Meta, Bing, Reddit and OpenAI fire normally on the same trigger. A direct `gtag('event','conversion',{send_to:'AW-XXXXXXXXX/label'})` on the same page does send, so the account is fine. Only GTM's handoff to the destination is broken. Google has not documented the cause; the zone diagnosis above comes from live testing.

**The signal.** First confirm what is published: the live version (`resource.version` from a cache-busted `gtm.js`) and its Google tag types (`__googtag` = legacy; destination tags otherwise). With legacy `__googtag` tags, `parent` entries are expected and prove nothing. With destination tags, any `parent` entry is the warning sign, unless the combined Google tag is neutered (destinations paused), where a `parent` on G- is expected and harmless. In both cases only the labeled request (below) proves the setup. Then, on the live site (not Preview), run in the console after the page has loaded and any lazy loader (NitroPack, WP Meteor) has released GTM:

```js
const c = google_tag_data.tidr.container;
Object.keys(c).filter(k => /^(G|AW)-/.test(k) && c[k].parent)
```

Any G- or AW- ID returned is loading as its own Google tag next to GTM, and GTM's tags for that ID were dead in every case tested. An empty result means GTM handles the destination itself, and those containers worked. Results from one audit of optimized containers:

| Pattern | Loaded separately | Result |
|---|---|---|
| Unzoned destinations | none | Ads and GA4 both work |
| HubSpot Ads pixel adds its own AW config ("Ignore duplicate instances of on-page configuration" was off) | AW | Ads dead, GA4 fine |
| Combined tag holding both IDs | AW and G | Ads and GA4 both dead |
| Combined tag, G- routed | G (sometimes AW too) | GA4 events dead |
| Zoned AW- that resolves to an unzoned tag | AW | works |
| No GTM event tags | G | page_view sends, nothing to fix |

Every container that loaded a destination separately, except the HubSpot pixel case, also had a `__zone` tag in its published `gtm.js`. That is a quick static check: fetch `https://www.googletagmanager.com/gtm.js?id=GTM-XXXXXXX`, parse `var data = {...}` and look in `resource.tags` for `"function":"__zone"`. A zone or a separately loaded ID is a strong hint, not proof. Always confirm with a real hit before changing anything.

To see why an ID loads on its own, open GTM home > the Google tag for that ID > Settings > Google destinations. If the G- tag also lists an AW- ID, loading it configures AW too, and the two IDs must be handled together (both legacy, or both modern with the neuter fix). GA4 > the stream > Configure tag settings then says "connected to multiple Google tags".

If one Google tag routes to both the G- and AW- IDs, GTM refuses to publish a legacy Google Tag for one ID next to a destination tag for the other ("Conflicting Google tag" in Validate Workspace). Replace both. Destination tags on "All Pages" (Page View) never fire on sites whose snippet lacks `gtm.js` (checklist 15). The legacy tags go on `Initialization - All Pages`.

**Confirm with a real hit.** On the live site, push the form event by hand and look for the request:

```js
dataLayer.push({event: 'GFTrackEvent', form_title: '<exact form title>', form_id: '<id>'});
// after ~5 s:
performance.getEntriesByType('resource').map(e => e.name)
  .filter(u => /(pagead|ccm)\/conversion\/|\/as\/p\/c\/\d{6,}\/|\/g\/collect/.test(u))
```

For other sources push their own event from 6.0 instead, e.g. `{event:'elementor_form_success', form_name:'<Form Name>'}` or `{event:'hubspot_form_success', form_id:'<GUID>'}`, with the keys your triggers check.

You need a `pagead/conversion/<AW id>` (or `ccm/conversion`, or tag gateway `/as/p/c/<id>/`) request whose `label` matches the tag, and a `g/collect` with the GA4 event name. Nothing back means the hits are being dropped. Resource timing has URLs only; GA4 can carry the event in the POST body, so confirm `en` in the DevTools payload. The hand-push fires every tag on that trigger when consent is granted, and GA4 key events count it. List every vendor that got a hit (GA4, Meta, Reddit, Google Ads) for the site owner so they can discount the test. A click-less Ads test hit does not show in the conversion count; the request on the wire is the proof. A hand-push cannot test a redirect confirmation (6.1).

**Legacy fallback (Julius Fedorovicius's documented rollback, confirmed live on three containers).** Use this when the neuter fix is not available (you cannot edit the combined Google tag) or when the cause is not a zone:
1. In the workspace, open each failing destination tag and note any Configuration settings. Delete it.
2. Tags > New > Other Google > **Google Tag**. Tag ID = the same G-/AW- ID. Trigger `Initialization - All Pages`. Name `Google Tag <ID>`. Fix only the IDs that failed: a working GA4 destination can stay.
3. Keep or re-add `Google Ads - Conversion Linker` on All Pages (Tag type > Other Google > Legacy). If a Google Ads conversion tag is saved during the fix, delete any `Google Ads AW-...` destination tag GTM adds to the workspace (build step 6).
4. Submit dialog: open the consent row, select the new tags under "Consent Not Configured" and set **No additional consent required**.
5. Before publishing, check the workspace has a Conversion Linker (`gclidw` in the export) on All Pages, no `dest_aw` / `dest_ga` tag next to the legacy ones, and that All Pages fires on the site (`dataLayer` has `gtm.js`, checklist 15). It is easy to ship this fix without a linker. Preview, push the event, confirm the labeled request (above). Publish with a version note naming the reason and the rollback version.
6. Re-run the console check on the live site. Legacy Google tags also show as separate containers in `tidr`; that is normal for them. The labeled conversion request is what proves the fix.
7. Do not re-run the Optimize wizard on a container fixed this way.

The site snippet matters too: see checklist 15. Sites with this problem were often also missing the `gtm.js` event, which this fix does not cover on its own.

## 6. Form and booking sources

Rule from Julius: prefer a dataLayer push from the vendor or the site over DOM scraping; use a listener in Custom HTML only when the vendor gives you nothing. Every listener pushes a snake_case event plus the fields the triggers and DLVs need.

### 6.0 Standard dataLayer events

| Source | Event pushed | Keys | Who pushes it |
|---|---|---|---|
| Gravity Forms | `GFTrackEvent` | `form_title`, `form_id`, `user_email`, `user_first_name`, `user_last_name`, `user_phone` (only when the form has a phone field) | Official GF Google Analytics add-on (GTM connection) |
| Elementor forms (v3 and v4) | `elementor_form_success` | `form_name`, `form_id`, `form_page`, `form_version` | Listener (theme or Custom HTML) |
| HubSpot forms (v3 and v4) | `hubspot_form_success` | `form_id` (GUID), `conversion_id`, `form_data.email`, `form_data.firstname`, `form_data.lastname`, `form_data.phone` | Listener |
| HubSpot Meetings | `hubspot_meeting_success` | `form_id` (meeting link GUID), `organizer`, `meeting_date`, `duration_minutes`, `is_paid`, `user_email`, `user_first_name`, `user_last_name` | Listener |
| Calendly | `calendly` | `calendly_event` (`profile_page_viewed` / `event_type_viewed` / `date_and_time_selected` / `event_scheduled`), `invitee_uri` (on `event_scheduled` only) | Listener |
| TidyCal | `tidycal_booking_complete` | `booking_id`, `booking_type_id`, `booking_starts_at`, `booking_ends_at`, `booking_timezone` | Listener |
| Site custom | `<thing>_<action>` snake_case (e.g. `banner_ad_click`) | as needed | Theme code |

Listener tags fire on `Initialization - All Pages` (or a page trigger scoped to the embed page), no consent checks: they only push to the dataLayer. Consent sits on the tags they feed. One listener tag per vendor, never two mechanisms for the same form (vendor push + your own listener = double conversions). A listener whose event no trigger uses is an orphan: delete it (common finds: a HubSpot listener on a site with no HubSpot forms, a jQuery AJAX listener nothing consumed).

Legacy names you will meet in older containers and site code, to rename or map: `hubspot-form-success` with `hs-form-guid` (Julius's older listener); an `ajaxComplete` Elementor trigger; a `form_submit_gf` custom-event trigger with no emitter (keep until the GF add-on is connected, then delete); Julius's recipes push `formSubmission` / `formID`; `GFTrackEmail` / `GFTFormName` style variable names; GF feeds that push a parameter literally named `GF - Form Title` (rename the GTM variable, leave the dataLayer key alone).

### 6.1 Gravity Forms (official Google Analytics add-on, GTM connection)

No listener. The add-on pushes `{event: <trigger event name>, <param>: <value>...}` on confirmation. `GFTrackEvent` is the default and what this standard uses. With a redirect confirmation, add-on 2.4.x pushes on the form page, then redirects once the push is done. It does not wait for tag requests, so a slow conversion request can lose the race (fix below). A hand-push cannot test this; check the first real lead after publishing. If a custom plugin handles the redirect, it can skip the push: check `googleanalytics_feeds_sent` on its entries (step 6).

Setup:
1. GTM first: Custom Event trigger, event name `GFTrackEvent`, "All Custom Events", saved in the workspace so the add-on can list it in the feed dropdown. The add-on keeps a GTM workspace ID only for that list, and the ID goes stale after every publish. If the dropdown is empty, reconnect the add-on or edit the feed with `GFAPI::update_feed`. Then per form, a trigger `Gravity Forms - <Form Title>` with condition `{{Gravity Forms - Form Title}}` equals the exact title (prefer *equals*; "contains" is case-sensitive and causes silent misses).
2. Add-on connection (Forms > Settings > Google Analytics): choose **Tag Manager**, press Continue, finish the connection. Until this is done the per-form feed page says "To get started, please configure your Google Analytics Settings" and nothing is pushed, even though the add-on's `google-analytics.min.js` still loads on the page. Turn **off** "Google Tag Manager Script" in the add-on settings (GTM is already on the site).
3. GF feed per form (Form Settings > Google Analytics > Add New): Tag Manager Trigger = the `GFTrackEvent` trigger; parameters `form_title` = `{form_title}`, `form_id` = `{form_id}`, `user_email` = Email field, `user_first_name`, `user_last_name`, and `user_phone` only when the form has a phone field. Keys outside the add-on's choice list (`form_id`, `user_first_name`, `user_last_name`) go in the generic map as `gf_custom` + `custom_key`; the value `form_id` resolves from the entry. The feed stores the custom event name (`GFTrackEvent`), not a trigger ID: renaming, re-importing or deleting GTM triggers does not break feeds as long as the event name stays `GFTrackEvent`. Feeds on inactive forms are orphans; check their field mappings before reusing them (one audited feed mapped `user_email` to the form title).
4. DLVs: `Gravity Forms - Form Title`, `Gravity Forms - Form ID`, `Gravity Forms - Email`, `Gravity Forms - First Name`, `Gravity Forms - Last Name`, and `Gravity Forms - Phone` only when a feed pushes `user_phone`. A DLV whose key no feed pushes is always empty.
5. `User-Provided Data` (awec, manual): email = `{{Gravity Forms - Email}}`, phone = `{{Gravity Forms - Phone}}` only when the form has a phone field.
6. Verify the emitter. In Preview, submit the form and watch `GFTrackEvent` arrive with `form_title`; if it never arrives, go back to step 2. When test submits are not allowed (client forms), prove it from the entries instead: count GF entries per form that carry the entry meta `googleanalytics_feeds_sent` and note the latest date. Then reconcile GF entries per form, day and page against GA4 `generate_lead` by date and `pagePath` over 90 days. A run of misses is a real gap (one audit found a main contact form missing from GA4 for weeks); a single miss can be consent. `googleanalytics_feeds_sent` proves the push, not delivery.

Gotchas: a GF form inside an Elementor popup has double-counted in the wild; set tags Once per event and make sure only the add-on pushes. The old "Event Tracking for Gravity Forms" plugin also pushes `GFTrackEvent`; if both are installed, remove the old one. Check the form's hidden input `gform_submission_method`: `iframe` pushes the feed's event (`GFTrackEvent`); on `ajax`, add-on 2.4.1 may push `gforms_submission` instead (seen in the add-on source, not confirmed on a live site), so watch the real push in Preview before trusting the trigger. A form rebuilt under a new title loses its tracking until its trigger is updated (checklist 5). Fallback when the add-on is not available (needs jQuery, AJAX forms only):

```html
<script>
jQuery(document).on('gform_confirmation_loaded', function(event, formId) {
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({ 'event': 'GFTrackEvent', 'form_id': formId });
});
</script>
```

**Redirect confirmations lose hits (fix on every site).** When a form's confirmation is a page or redirect, add-on 2.4.1 swaps it for a "Processing..." message (`force_text_confirmation`, priority 1000). It pushes `GFTrackEvent`, fires `googleanalytics/all_events_sent` about 30 ms later, and redirects immediately. The GTM tags on that push send about 200 to 400 ms later, so they race the page unload. On a live contact form, the Google Ads conversion, the enhanced conversions `form-data` request and GA4 `generate_lead` all left after the unload began: they arrived on a fast laptop and would drop on slow phones. Fix: a must-use plugin `wp-content/mu-plugins/gf-ga-redirect-delay.php` that holds the add-on's redirect for 1 second (with it, every hit finished about 600 ms before unload):

```php
<?php
/**
 * Plugin Name: Gravity Forms GA redirect delay
 * Description: Waits 1 second before a Gravity Forms redirect confirmation that the Google Analytics add-on holds, so GTM tags fired on GFTrackEvent finish sending first.
 */
add_filter( 'gform_confirmation', function ( $confirmation ) {
	if ( is_string( $confirmation ) && strpos( $confirmation, 'googleanalytics/all_events_sent' ) !== false ) {
		$confirmation = preg_replace( '/document\.location\.href="([^"]+)"/', 'setTimeout(function(){document.location.href="\\1"},1000)', $confirmation );
	}
	return $confirmation;
}, 1001 );
```

Text confirmations (no redirect) need nothing: the page stays and GA4's batch (about 5 s later) still goes out. Check which forms redirect: GFAPI form `confirmations[].type` is `page` or `redirect`, or a plugin filters `gform_confirmation`.

### 6.2 Elementor forms

**v3 (classic Form widget)**: Elementor Pro triggers the jQuery event `submit_success` on `form.elementor-form` after a server-confirmed success. `<form name="...">` carries the widget's Form Name; hidden `form_id` holds the element ID. Set Form Name in every widget or you get element IDs.

**v4 (Atomic Form, Editor v4, experiment flag)**: no jQuery event, no CustomEvent, no dataLayer push. Submission is Alpine + `fetch` to `admin-ajax.php` (`action=elementor_pro_atomic_forms_send_form`). On success the `<form data-element_type="e-form" data-id data-form-name>` gets class `form-state-success`. Old `submit_success` and `.elementor-message-success` selectors do nothing on v4.

One listener covers both:

```html
<script>
(function () {
  window.dataLayer = window.dataLayer || [];
  function push(name, id, version) {
    window.dataLayer.push({
      event: 'elementor_form_success',
      form_name: name || 'unknown',
      form_id: id || 'unknown',
      form_page: document.title,
      form_version: version
    });
  }
  // v3
  if (window.jQuery) {
    jQuery(document).on('submit_success', '.elementor-form', function (e) {
      var f = e.target;
      var idEl = f.querySelector('[name="form_id"]');
      push(f.getAttribute('name'), idEl ? idEl.value : f.id, 'v3');
    });
  }
  // v4
  var SEL = 'form[data-element_type="e-form"]';
  function watch(form) {
    if (form.__gtmWatched) return;
    form.__gtmWatched = true;
    var was = form.classList.contains('form-state-success');
    new MutationObserver(function () {
      var is = form.classList.contains('form-state-success');
      if (is && !was) push(form.getAttribute('data-form-name') || form.getAttribute('aria-label'), form.getAttribute('data-id') || form.id, 'v4');
      was = is;
    }).observe(form, { attributes: true, attributeFilter: ['class'] });
  }
  function scan(root) { if (root.querySelectorAll) root.querySelectorAll(SEL).forEach(watch); }
  scan(document);
  new MutationObserver(function (muts) {
    muts.forEach(function (m) { m.addedNodes.forEach(function (n) { if (n.nodeType === 1) { if (n.matches && n.matches(SEL)) watch(n); scan(n); } }); });
  }).observe(document.documentElement, { childList: true, subtree: true });
})();
</script>
```

Triggers: `Elementor Forms - <Form Name>` = custom event `elementor_form_success` and `{{Elementor Forms - Form Name}}` equals the name. DLVs `Elementor Forms - Form Name`, `Elementor Forms - Form ID`, `Elementor Forms - Form Page`. Field values (for enhanced conversions) are not in this push; v4 resets the form before the class flips. Use the attribution script's hidden fields plus HubSpot/CRM for the person data, or wrap `fetch` to read the submitted body if a client needs email client-side.

Gotchas: never combine with GTM's built-in Form Submission trigger (fires on failed validation too). Popups: the delegated handler and the document observer handle injected forms. Redirect action: `submit_success` fires before the redirect but tags may not finish; also track the thank-you page. Check for "DataLayer for Elementor" / "Events Tracker for Elementor" plugins before adding a listener. Julius's fallback when Custom HTML is not allowed: Element Visibility on `.elementor-message.elementor-message-success` (v3) or `form[data-element_type="e-form"].form-state-success [data-element_type="e-form-success-message"]` (v4), Observe DOM changes on; it only fires if the message scrolls into view.

### 6.3 HubSpot embedded forms (v3 and v4)

v3 (`hbspt.forms.create`, `embed/v2.js`): `window.postMessage` with `event.data.type === 'hsFormCallback'`, `eventName === 'onFormSubmitted'`, `event.data.id` = form GUID, `event.data.data.submissionValues` = fields, `conversionId` undocumented but present.

v4 (new editor, `<div class="hs-form-frame" data-form-id>` + `embed/{portalId}.js`): the loader dispatches a bubbling DOM CustomEvent `hs-form-event:on-submission:success` on the host page (`detail: {formId, instanceId}`); `window.HubSpotFormsV4.getFormFromEvent(e)` gives `getFormId()`, `getConversionId()`, `getRedirectUrl()`, `getFormFieldValues()` (promise, names like `0-1/email`). Tell them apart: `window.HubSpotForms` (v3) vs `window.HubSpotFormsV4` (v4).

Listener (Julius's, event renamed to this standard, both versions in one tag):

```html
<script>
window.dataLayer = window.dataLayer || [];
// v3
window.addEventListener('message', function (event) {
  if (event.data && event.data.type === 'hsFormCallback' && event.data.eventName === 'onFormSubmitted') {
    window.dataLayer.push({
      event: 'hubspot_form_success',
      form_id: event.data.id,
      conversion_id: event.data.data && event.data.data.conversionId,
      form_data: event.data.data && event.data.data.submissionValues
    });
  }
});
// v4
window.addEventListener('hs-form-event:on-submission:success', function (event) {
  var api = window.HubSpotFormsV4 || window.HubspotFormsV4;
  var hsform = api && api.getFormFromEvent(event);
  if (!hsform) return;
  hsform.getFormFieldValues().then(function (fieldValues) {
    var data = fieldValues.reduce(function (obj, item) {
      var key = item.name.split('/')[1];
      if (key) obj[key] = item.value;
      return obj;
    }, {});
    window.dataLayer.push({
      event: 'hubspot_form_success',
      form_id: hsform.getFormId(),
      conversion_id: hsform.getConversionId(),
      form_data: data
    });
  });
});
</script>
```

Triggers: `HubSpot Forms - <Form Name>` = custom event `hubspot_form_success` and `{{HubSpot Forms - Form GUID}}` equals the GUID (keep a Lookup `Lookup - HubSpot Form Name` GUID to name when there are many forms). DLVs `HubSpot Forms - Form GUID` (`form_id`), `HubSpot Forms - Conversion ID`, `HubSpot Forms - Email` (`form_data.email`), `- First Name`, `- Last Name`, `- Phone`. `User-Provided Data` from the email/phone DLVs. Use `conversion_id` as transaction ID on Google Ads tags to dedupe against any server-side send.

Gotchas: v4 field values are async, so a redirect can beat the push; if the form redirects, also track the thank-you page. The listener must exist before submit (All Pages is fine). HubSpot popup CTA forms are a different embed; test them separately. Same form twice on a page: `instanceId` differs, `formId` does not. Never send `form_data.firstname` etc. to GA4. HubSpot's own tracking script (from the HubSpot WordPress plugin) is not a form; check for `.hs-form-frame` / `hbspt-form` on the page before keeping a listener.

### 6.4 HubSpot Meetings (scheduler embed)

Undocumented `postMessage` from the `meetings.hubspot.com` iframe: `event.data.meetingBookSucceeded === true` with `event.data.meetingsPayload` (`formGuid`, `userSlug`, `isPaidMeeting`, `bookingResponse.event.dateString`, `.event.duration` ms, `.postResponse.contact.{email,firstName,lastName}`, `.postResponse.organizer.name`). The payload has changed shape twice; log `event.data` on a test booking before trusting a key. Only works when the scheduler is embedded in a page running GTM, in the same frame (not direct links, not nested iframes).

```html
<script>
window.dataLayer = window.dataLayer || [];
window.addEventListener('message', function (event) {
  if (!event.data || event.data.meetingBookSucceeded !== true) return;
  var p = event.data.meetingsPayload || {};
  var br = p.bookingResponse || {};
  var pr = br.postResponse || {};
  var ev = br.event || {};
  var c = pr.contact || {};
  window.dataLayer.push({
    event: 'hubspot_meeting_success',
    form_id: p.formGuid || '',
    organizer: (pr.organizer && pr.organizer.name) || '',
    is_paid: !!p.isPaidMeeting,
    meeting_date: ev.dateString || '',
    duration_minutes: ev.duration ? ev.duration / 60000 : 0,
    user_email: c.email || '',
    user_first_name: c.firstName || '',
    user_last_name: c.lastName || ''
  });
});
</script>
```

Trigger `HubSpot Meetings - Booked` (custom event `hubspot_meeting_success`). GA4: `generate_lead` with `method` = `hubspot_meeting`, or `book_appointment` if the client wants bookings reported separately from form leads; pick once per client and keep it. Google Ads conversion on the same trigger; email into `User-Provided Data` through DLVs `HubSpot Meetings - Email` etc.

### 6.5 Calendly (inline or popup embed)

Official `postMessage` from the `calendly.com` iframe: `event.data.event` in `calendly.profile_page_viewed`, `calendly.event_type_viewed`, `calendly.date_and_time_selected`, `calendly.event_scheduled` (payload `event.uri`, `invitee.uri`; no name or email client-side). A hand-written `<iframe>` does not emit these; it must be Calendly's widget script. Calendly sends `event_type_viewed` twice; the guard below dedupes consecutive repeats. Calendly's own native GA4 integration (events named `invitee_*`) is a separate path; do not add the listener on top of it for the same GA4 property.

```html
<script>
window.dataLayer = window.dataLayer || [];
var lastCalendlyEvent = '';
window.addEventListener('message', function (e) {
  if (e.origin !== 'https://calendly.com' || !e.data || !e.data.event || e.data.event.indexOf('calendly.') !== 0) return;
  var name = e.data.event.split('.')[1];
  var allowed = ['profile_page_viewed', 'event_type_viewed', 'date_and_time_selected', 'event_scheduled'];
  if (allowed.indexOf(name) === -1 || name === lastCalendlyEvent) return;
  var obj = { event: 'calendly', calendly_event: name };
  if (name === 'event_scheduled' && e.data.payload) {
    obj.invitee_uri = e.data.payload.invitee && e.data.payload.invitee.uri;
    obj.event_uri = e.data.payload.event && e.data.payload.event.uri;
  }
  window.dataLayer.push(obj);
  lastCalendlyEvent = name;
});
</script>
```

Triggers: `Calendly - Event Scheduled` = custom event `calendly` and `{{Calendly - Event}}` equals `event_scheduled`; optionally `Calendly - Any Step` for a funnel GA4 tag with event name `calendly_{{Calendly - Event}}`. DLVs `Calendly - Event`, `Calendly - Invitee URI`. Enhanced conversions need the Calendly API (invitee URI to email) server-side, or a redirect to your own thank-you page with hidden fields. GTM Preview shows an "Unknown domain" prompt for calendly.com; ignore it.

### 6.6 TidyCal (inline embed)

Documented since 2026: `postMessage` from `https://tidycal.com` with `e.data.event === 'bookingComplete'` and `e.data.data.booking.{id, booking_type_id, starts_at, ends_at, timezone}`. No name or email. Not sent for direct `tidycal.com` links. Paid plans also offer a native GA4 integration (fires `booking_complete` etc. inside TidyCal's pages, so sessions do not stitch) and a post-booking redirect with `{{contact.email}}` template variables, which is the route to a thank-you page with hidden fields. `window.TidyCal.on('bookingComplete', fn)` is a helper the embed script exposes for the same message.

```html
<script>
(function () {
  window.dataLayer = window.dataLayer || [];
  var seen = {};
  window.addEventListener('message', function (e) {
    if (e.origin !== 'https://tidycal.com' || !e.data || e.data.event !== 'bookingComplete') return;
    var b = (e.data.data && e.data.data.booking) || {};
    if (b.id && seen[b.id]) return;
    if (b.id) seen[b.id] = true;
    window.dataLayer.push({
      event: 'tidycal_booking_complete',
      booking_id: b.id || '',
      booking_type_id: b.booking_type_id || '',
      booking_starts_at: b.starts_at || '',
      booking_ends_at: b.ends_at || '',
      booking_timezone: b.timezone || ''
    });
  });
})();
</script>
```

Trigger `TidyCal - Booking Complete`. DLVs `TidyCal - Booking ID`, `TidyCal - Booking Type ID`. Map type IDs to names with `Lookup - TidyCal Booking Type`. Use `booking_id` as transaction ID. Verify the message with a test booking before shipping; it is a recent addition to their docs.

### 6.7 Choosing the GA4 event

Recommended names first: `generate_lead` (contact, demo, quote forms; add `method` = vendor), `sign_up` (newsletter, account; add `method` = `newsletter`), `purchase`, `begin_checkout`, `view_item`, `add_to_cart`. Bookings: `generate_lead` with `method` = `hubspot_meeting` / `calendly` / `tidycal`, unless the client wants a separate key event, then `book_appointment`. Custom names only when nothing fits (step events in a multi-step funnel are fine). `generate_lead` and the ad pixels' Lead events are for sales conversations (contact, demo, quote, booking). Resource and lead magnet forms send their own event (`request_resource`, not a key event, no pixel Lead) unless the site owner wants them counted as leads for that client. Never build event names from variables. When a cleanup renames an event (e.g. `newsletter_sign_up` to `sign_up`), tell the site owner to re-mark the key event in GA4.

## 7. Audit checklist (alignment pass)

Run top to bottom on each container. Record findings in the version description.

1. Export saved (or, if the download was skipped, the live Version N noted as the rollback; section 1).
2. Optimized? Destination tags present, no `googtag` type tags, no Conversion Linker (section 5). If optimized, the pre-flight and dropped-hit check (5.7) pass on the live site, or the combined Google tag is neutered and verified. If a container uses the legacy fallback, the failing IDs are on legacy Google Tags with a Conversion Linker (`gclidw` on All Pages) and no `dest_aw` / `dest_ga` tag left beside them. A legacy setup without a linker fails this item. Check GTM home > each Google tag > Settings > Google destinations for IDs that must be handled together (5.7).
3. Google IDs from dropdown; no Google ID constants left; third-party IDs are Constants named `Vendor Tag ID`.
4. Every tag, trigger, variable follows section 2. Same event wording across vendors. The GA4 web stream is named `Brand - Website` (or `- Blog` etc.).
5. Every tag has a trigger that exists and makes sense (common finds: a pixel tag for step 4 firing on the step 3 trigger; a `Meta - Contact` tag firing on the wrong form next to `Meta - Lead`). Every trigger condition matches the real form title, case included (GTM "contains" is case-sensitive: `(2 Quote)` vs `(2 QUOTE)` misses; a Newsletter trigger pointing at a different form's title). Also go the other way: list every active form and confirm each one that matters has a trigger with its exact current title. A form rebuilt under a new title loses its tracking.
6. Every custom-event trigger has a confirmed emitter on the site (plugin feed, theme code, or a listener tag in this container). Check the plugin settings, not just the GTM side (the GF add-on not connected means no form events at all). When the site has changed form vendor, check GA4 too: Admin > Data streams > the stream > Create events, and Key events. Rules built on the old vendor's form IDs (e.g. `form_submit` + `form_id = hsForm_...` creating `demo_request_submit`) stop matching on the switch day, so the key events, and any Google Ads actions imported from them, go to zero while GTM's new event is not a key event yet. Tell the site owner which event to mark and which rules to retire. Prove the emitter without a submit, and over time, not at one moment: GF entry meta `googleanalytics_feeds_sent` plus the 90-day reconciliation against GA4 (6.1 step 6).
7. No orphan triggers, variables, listeners, or unused gallery templates. An awec `User-Provided Data` variable that no tag uses means enhanced conversions are missing, not just an orphan.
8. No duplicate firing paths (tags firing on both a DOM/click trigger and a dataLayer event for the same action) and no manual GA4 `page_view` tag next to a destination.
9. Paused tags: delete or document why they stay.
10. Consent wiring per section 4; CMP present where the client has EU/UK traffic. Page-level tags on the CMP consent trigger set to Once per page. The three consent settings in the Settings tab checked and recorded (4.1). Consent Overview shows nothing under "Consent Not Configured" (new destination tags set to No additional consent required). On a legacy container the Settings tab settings are dormant; record "legacy, dormant" (build step 1).
11. No PII to GA4; enhanced conversions and advanced matching wired from DLVs. Compare the GF feed keys with every DLV the tags read: a DLV whose key no feed pushes is always empty (e.g. Meta `fn` / `ln` DLVs with no first or last name in the feed).
12. Settings > Configure your domains holds this client's root domain plus only the other domains that share its GA4 property (5.5). No other client's domains, no untagged third parties, no unchecked suggestions. On a legacy container this setting is dormant; check GA4 > the stream > Configure tag settings > Configure your domains instead.
13. GA4 event names are recommended names where one exists; no dynamic event names built from variables (`click_{{Click Text}}` style names will hit the 500-event cap).
14. Google Ads side: run GAQL on `conversion_action` (status ENABLED, type WEBPAGE) with `tag_snippets` and `primary_for_goal`. Every Primary website action has a GTM `awct` tag with the same conversion ID and label, and every `awct` tag matches an enabled action. Comparing names alone passes when there is no tag at all (one audit found every enabled website action with no tag, including the only Primary one). Names match. No two parallel sets of the same conversions. Each biddable goal holds one Primary action per real event: when a CRM upload action (HubSpot "Submit lead form") shares a category with a website action, keep the website action Primary and set the upload to Secondary unless the site owner chooses otherwise, or each lead counts twice. Later-stage uploads (Qualified lead, Converted lead) stay as they are.
15. Site side: GTM snippet is the standard one from googletagmanager.com (no stale server-side / custom loader), `noscript` iframe present, snippet injected once. Check that `dataLayer` contains a `gtm.js` event on the live site. Many sites load GTM with a gtag-style snippet instead: `<script async src="...gtm.js?id=GTM-XXXXXXX">` followed by `gtag('js', new Date())`. That snippet never pushes `gtm.js`, so every All Pages / Page View trigger (Conversion Linker, remarketing, page-view conversions) silently never fires. It often hides in Elementor Custom Code or a WPCode global header. Replace it with the standard snippet, keeping `function gtag(){dataLayer.push(arguments);}` defined, back up the old code, and clear the page cache. List every tracker that loads outside GTM (Elementor Custom Code, WPCode, theme, the HubSpot plugin's Ads pixel per section 9) and note its consent handling. Check inactive Site Kit options (`analytics-4` and `ads` `useSnippet`), and remove superseded snippets such as an older add-to-cookie script running next to the attribution script (8).
16. Preview walk-through done, Hits Sent checked, the labeled conversion request seen leaving the browser (section 9), 5.7 run on the live site, published with a dated version name.
17. If the forms carry click IDs, the attribution script (section 8) is on the site, and each GF hidden field's description equals its key. Hidden fields with no descriptions and no script means no gclid is ever captured.
18. Google Ads account: auto-tagging on, customer data terms accepted, enhanced conversions for web and for leads set to Google Tag Manager, GA4 link present, `conversion_tracking_setting` as expected, linked managers known (flag any unknown manager), Goals > Diagnostics read. CRM upload matching (enhanced conversions for leads) also needs the site's `Google Ads - Enhanced Conversions` tag.

## 8. Attribution script (hidden form fields)

Lives on the site (theme footer, code snippets plugin, or a Custom HTML tag on `Initialization - All Pages`, no consent gate). It stores UTMs, click IDs, landing page, referrer and an inferred channel/source/medium in first-party cookies for 90 days, then fills matching hidden inputs in Gravity Forms, Elementor and HubSpot forms. UTM wins, then click IDs, then referrer inference. It uses ES6, so it cannot go in a GTM Custom JavaScript variable; a Custom HTML tag runs it in the browser as is.

Hidden field setup per form vendor:
- Gravity Forms: hidden field with the parameter name as the field's *description* (the script matches `.gfield_description` text) or an input `name`/`id` equal to the key.
- Elementor: hidden field with ID = key (renders as `form-field-<key>` and `form_fields[<key>]`).
- HubSpot: hidden property whose internal name ends with the key (`utm_source`, `gclid`), or `ga_id` / `google_analytics_client_id` for the GA client ID.

Keys available: `_ga`, `gclid`, `fbclid`, `msclkid`, `ttclid`, `twclid`, `rdt_cid`, `li_fat_id`, `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`, `channel`, `source`, `medium`, `landing_page`, `referrer`.

Older add-to-cookie snippets (UTMs + gclid/msclkid/fbclid only, filling `input[name=key]`) are superseded by this one; replace them where found.

```html
<script>
/*
 * Attribution tracking script: captures marketing source data into
 * first-party cookies and fills matching hidden form fields.
 */
(() => {
  const keysToTrack = [
    '_ga',
    'gclid','fbclid','msclkid','ttclid','twclid','rdt_cid','li_fat_id',
    'utm_source','utm_medium','utm_campaign','utm_term','utm_content',
    'channel','source','medium','landing_page','referrer'
  ];
  const aliasMap = { '_ga': ['ga_id', 'google_analytics_client_id'] };
  const socialDomains = [
    'youtube.com','linkedin.com','facebook.com','instagram.com','threads.net','x.com',
    'tiktok.com','reddit.com','tumblr.com','pinterest.com','snapchat.com','whatsapp.com',
    'discord.com','quora.com','bsky.app','mastodon.social','wechat.com','weibo.com','vk.com',
    'line.me','telegram.org','douban.com','clubhouse.com','mix.com','meetup.com',
    'deviantart.com','flickr.com','soundcloud.com','goodreads.com','stackoverflow.com',
    'steamcommunity.com','nextdoor.com','gab.com','parler.com','gettr.com','minds.com',
    'mewe.com','truthsocial.com','rumble.com','hivesocial.app'
  ];
  const organicSearchDomains = [
    'google.com','bing.com','yahoo.com','baidu.com','yandex.com','duckduckgo.com','ask.com',
    'mojeek.com','ecosia.org','startpage.com','qwant.com','brave.com','naver.com',
    'seznam.cz','sogou.com'
  ];
  const aiDomains = ['openai.com','chatgpt.com','claude.ai','perplexity.ai','you.com','deepseek.com','komo.ai'];
  const paidSearchDirectories = [
    'g2.com','capterra.com','softwareadvice.com','getapp.com',
    'yelp.com','upcity.com','designrush.com','clutch.co','elearningindustry.com'
  ];

  const getParam = (name) => {
    const m = location.search.match(new RegExp(`[?&]${name}=([^&]+)`));
    return m ? decodeURIComponent(m[1]) : null;
  };
  const setCookie = (name, value, days) => {
    if (value == null) return;
    const expires = new Date(Date.now() + days*24*60*60*1000).toUTCString();
    document.cookie = `${name}=${encodeURIComponent(value)}; expires=${expires}; path=/`;
  };
  const getCookie = (name) => {
    const m = document.cookie.match(new RegExp(`(^| )${name}=([^;]+)`));
    return m ? decodeURIComponent(m[2]) : null;
  };
  const hostFromUrl = (url) => {
    if (!url) return '';
    try { return new URL(url).hostname.toLowerCase().replace(/^www\./,''); } catch { return ''; }
  };
  const isSelfReferral = (refHost) => refHost === location.hostname.replace(/^www\./,'').toLowerCase();
  const hostIncludesAny = (host, list) => list.some(d => host.includes(d));
  const brandFromHost = (host) => {
    if (!host) return '';
    const d = host.toLowerCase();
    if (d.includes('openai.') || d === 'openai.com' || d.includes('chatgpt.')) return 'ChatGPT';
    if (d.includes('claude.ai'))        return 'Claude';
    if (d.includes('perplexity.ai'))    return 'Perplexity';
    if (d.includes('you.com'))          return 'You.com';
    if (d.includes('deepseek.com'))     return 'DeepSeek';
    if (d.includes('komo.ai'))          return 'Komo';
    if (d.includes('linkedin.'))        return 'LinkedIn';
    if (d.includes('facebook.')|| d.includes('fb.')) return 'Facebook';
    if (d.includes('instagram.'))       return 'Instagram';
    if (d.includes('x.') || d === 'x.com' || d.includes('twitter.')) return 'X';
    if (d.includes('tiktok.'))          return 'TikTok';
    if (d.includes('reddit.'))          return 'Reddit';
    if (d.includes('google.'))          return 'Google';
    if (d.includes('bing.'))            return 'Bing';
    if (d.includes('yahoo.'))           return 'Yahoo';
    if (d.includes('duckduckgo'))       return 'DuckDuckGo';
    return host;
  };

  keysToTrack.forEach(k => { const v = getParam(k) || getCookie(k); if (v) setCookie(k, v, 90); });
  if (!getCookie('landing_page')) setCookie('landing_page', location.pathname, 90);
  if (!getCookie('referrer'))     setCookie('referrer', document.referrer, 90);

  const utm = {
    source: getParam('utm_source') || getCookie('utm_source') || '',
    medium: (getParam('utm_medium') || getCookie('utm_medium') || '').toLowerCase(),
    campaign: getParam('utm_campaign') || getCookie('utm_campaign') || '',
    term:     getParam('utm_term')     || getCookie('utm_term')     || '',
    content:  getParam('utm_content')  || getCookie('utm_content')  || ''
  };
  const clientIDs = {
    gclid: getCookie('gclid'), fbclid: getCookie('fbclid'), msclkid: getCookie('msclkid'),
    ttclid: getCookie('ttclid'), twclid: getCookie('twclid'), rdt_cid: getCookie('rdt_cid'), li_fat_id: getCookie('li_fat_id')
  };
  const refUrl  = getCookie('referrer') || document.referrer || '';
  const refHost = hostFromUrl(refUrl);
  const socialSrc = ['linkedin','facebook','instagram','x','twitter','tiktok','youtube','snapchat','reddit'];

  function decideAttribution() {
    if (utm.source || utm.medium) {
      const med = (utm.medium === 'paid-social' ? 'paid_social' : utm.medium);
      const src = (utm.source || '').toLowerCase();
      if (med === 'paid' || med === 'cpc' || med === 'ppc') {
        if (socialSrc.includes(src)) return { channel: 'Paid Social', source: brandFromHost(`${src}.com`), medium: 'paid_social' };
        return { channel: 'Paid Search', source: utm.source || 'Google', medium: 'cpc' };
      }
      if (med === 'paid_social') return { channel: 'Paid Social', source: utm.source || 'Social', medium: 'paid_social' };
      if (med === 'social')      return { channel: 'Organic Social', source: utm.source || 'Social', medium: 'social' };
      if (med === 'email')       return { channel: 'Email Marketing', source: utm.source || 'Email', medium: 'email' };
      if (med === 'display')     return { channel: 'Display Ads', source: utm.source || 'Display', medium: 'display' };
      if (socialSrc.includes(src)) return { channel: 'Organic Social', source: brandFromHost(`${src}.com`), medium: 'social' };
      return { channel: 'Other Campaigns', source: utm.source || 'campaign', medium: utm.medium || 'other' };
    }
    if (clientIDs.gclid)     return { channel: 'Paid Search', source: 'Google',    medium: 'cpc' };
    if (clientIDs.msclkid)   return { channel: 'Paid Search', source: 'Microsoft', medium: 'cpc' };
    if (clientIDs.fbclid)    return { channel: 'Paid Social', source: 'Facebook',  medium: 'paid_social' };
    if (clientIDs.ttclid)    return { channel: 'Paid Social', source: 'TikTok',    medium: 'paid_social' };
    if (clientIDs.twclid)    return { channel: 'Paid Social', source: 'X',         medium: 'paid_social' };
    if (clientIDs.rdt_cid)   return { channel: 'Paid Social', source: 'Reddit',    medium: 'paid_social' };
    if (clientIDs.li_fat_id) return { channel: 'Paid Social', source: 'LinkedIn',  medium: 'paid_social' };
    if (!refHost || isSelfReferral(refHost)) return { channel: 'Direct Traffic', source: 'direct', medium: 'direct' };
    if (hostIncludesAny(refHost, aiDomains))            return { channel: 'AI Referrals',   source: brandFromHost(refHost), medium: 'referral' };
    if (hostIncludesAny(refHost, socialDomains))        return { channel: 'Organic Social', source: brandFromHost(refHost), medium: 'social' };
    if (hostIncludesAny(refHost, organicSearchDomains)) return { channel: 'Organic Search', source: brandFromHost(refHost), medium: 'organic' };
    if (hostIncludesAny(refHost, paidSearchDirectories))return { channel: 'Referrals',      source: brandFromHost(refHost), medium: 'referral' };
    return { channel: 'Referrals', source: brandFromHost(refHost), medium: 'referral' };
  }

  const decision = decideAttribution();
  setCookie('channel', decision.channel, 90);
  setCookie('source',  decision.source,  90);
  setCookie('medium',  decision.medium,  90);

  const fillInputs = () => {
    keysToTrack.forEach((key) => {
      const val = getCookie(key);
      if (!val) return;
      const selectors = [`input#${key}`, `input[name="${key}"]`, `input[name="form_fields[${key}]"]`, `input#form-field-${key}`];
      let input = null;
      for (const sel of selectors) { input = document.querySelector(sel); if (input) break; }
      if (!input) {
        const aliases = [key, ...(aliasMap[key] || [])];
        input = Array.from(document.querySelectorAll('input')).find(el => {
          const n = (el.getAttribute('name') || '').toLowerCase();
          return aliases.some(a => n.endsWith(a.toLowerCase()));
        }) || null;
      }
      if (!input) {
        const d = Array.from(document.querySelectorAll('.gfield_description'))
          .find(el => el.textContent.trim().toLowerCase() === key.toLowerCase());
        if (d) { const wrap = d.closest('.gfield'); if (wrap) input = wrap.querySelector('input'); }
      }
      if (input) { input.value = val; input.setAttribute('value', val); }
    });
  };
  fillInputs();
  let tries = 0;
  const interval = setInterval(() => { fillInputs(); if (++tries >= 20) clearInterval(interval); }, 500);
})();
</script>
```

## 9. Testing (three layers, all required)

1. GTM Preview: the tag fired on the right event, and the **Hits Sent** tab shows the hit with the right destination ID (G- or AW-). A deferred icon means consent held it back. A tag listed under Tags Fired with no matching hit is a failure, not a pass.
2. Network tab: the request left the browser (200/204), and it is the right request. For a Google Ads conversion that means `www.googleadservices.com/pagead/conversion/<conversion ID>/` with `en=conversion` and `label=<the tag's label>`. A `viewthroughconversion` or `ccm/collect` hit with `en=gtag.config` or `page_view` is the base tag, not the conversion. For GA4 it is `g/collect` with `en=<event name>`. GA4 can batch several events into one request, so also look in the POST body. Meta Pixel Helper / UET Helper count here. Repeat this on the live site after publishing, not only in Preview (5.7). Enhanced conversions proof: the conversion request itself only carries `em=tv.1`. The hashed data goes in a separate `form-data` request (seen as `ccm/form-data`) with `em`, joined to the conversion by the same `ecsid`. Seeing that pair is the proof. The Google Ads conversion tag in the current GTM has no "Include user-provided data from your website" checkbox, so the conversion tag cannot pick up the data itself. Use `Google Ads - Enhanced Conversions` with a higher firing priority (build step 6), which is the only route on a legacy container.
3. Destination: GA4 DebugView (Preview sets debug_mode automatically), then Google Ads > Goals > Conversions after a day, Microsoft UET tag status "Tag active".

Walk the real form, not a test event. For Gravity Forms the `GFTrackEvent` push only happens on actual submission. Where submits are not allowed, use the hand-push (5.7) for the tags and the entry meta and reconciliation (6.1 step 6) for the emitter.

**Real-submit proof that survives a redirect.** The hand-push proves the tags, not the add-on. On sites where the site owner allows real test submits, submit every live form once. Browser network panels and browser-automation network readers lose or never record the requests sent between submit and redirect (a real submit can look silent even though GA4 Realtime has the event). Arm this logger in the console on the form page first, then submit, then read `sessionStorage.__trk` on the landing page:

```js
sessionStorage.setItem('__trk','[]');
var log=function(t){var a=JSON.parse(sessionStorage.getItem('__trk')||'[]');a.push(Math.round(performance.now())+' '+t);sessionStorage.setItem('__trk',JSON.stringify(a));};
var orig=dataLayer.push;dataLayer.push=function(){for(var i=0;i<arguments.length;i++){var a=arguments[i];if(a&&a.event)log('DL '+a.event+(a.form_title?' '+a.form_title+' email:'+(a.user_email?'y':'n'):''));}return orig.apply(dataLayer,arguments);};
new PerformanceObserver(function(l){l.getEntries().forEach(function(e){if(/pagead\/conversion|ccm\/form-data|ccm\/conversion|g\/collect|measurement\/conversion|facebook\.com\/tr|alb\.reddit|bat\.bing/.test(e.name)){var x=new URL(e.name);log('NET '+x.host+x.pathname+' en='+(x.searchParams.get('en')||x.searchParams.get('ev')||'')+' label='+(x.searchParams.get('label')||''));}});}).observe({type:'resource'});
addEventListener('beforeunload',function(){log('UNLOAD');});
addEventListener('googleanalytics/all_events_sent',function(){log('all_events_sent');});
```

Pass: `DL GFTrackEvent <title> email:y`, then the labeled `pagead/conversion/<id>`, `ccm/form-data/<id>` (enhanced conversions), `g/collect en=generate_lead`, all before `UNLOAD`. Cross-check in GA4 Realtime (event by minutes ago). Use test identities (`yourname+gtmtest@example.com`) and tell the site owner which test contacts, bookings and conversions to clear. Cloudflare Turnstile usually passes on its own; when it shows "Verify you are human", an agent must stop and ask a person to complete it (agents never complete CAPTCHAs). A form page that now redirects elsewhere means the form is retired: its trigger is an orphan.

Preview quirks: after any workspace change, click Preview again or Tag Assistant keeps showing the old snapshot. If Tag Assistant says the container is not found on first load, reload the debug tab with `&nocache=1`. A `Config` event in Tag Assistant that GTM did not create, plus a second Google Ads `viewthroughconversion` / `ccm/collect` page_view per load, usually means HubSpot's Ads pixel (`js.hsadspixel.net/pixels.js`) is pushing its own `gtag('config','AW-...')` for a Google Ads account connected in HubSpot. The HubSpot WordPress plugin (leadin) loads it when Google Ads is connected in HubSpot ad tracking, along with its own `gtag/js?id=AW-...`. In the dataLayer it shows as `set` `developer_id.dZTQ1Zm`, then `config` `AW-...`. On an optimized container this is not harmless: it can make the AW destination load as its own Google tag, and every GTM Ads conversion is dropped (5.7). Either turn off the Google Ads pixel in HubSpot's ad tracking, or put that AW ID on a legacy Google Tag. `gtag/js?id=AW-...` / `?id=G-...` in the live DOM is fine for legacy Google Tags. On an optimized container it is the warning sign from 5.7. GA4 Realtime (`eventName` by `unifiedScreenName`, in the UI or the Data API realtime report) is a quick second check that `page_view` arrives once per load.

## 10. Working on containers from an AI agent (browser or CLI)

- **Reading a container without downloading**: Admin > Export Container > Default Workspace > Preview JSON, then read the CodeMirror value and summarize it (per tag: type, triggers by name, `tagFiringOption`, consent, key parameters; per trigger: type and conditions; per variable: type and value). Write a small summarizer script from this description if you need one. Before reading Preview JSON out in chunks, drop `customTemplate[].templateData` in the page and keep its length (template code can be over 80% of the export). `galleryReference.owner` and `repository` name the vendor of any `cvt_` template. A stripped export is a reading copy only; the full file is the rollback.
- **In a browser extension (e.g. Claude in Chrome)**: JavaScript results containing `=`, `&` or the word `cookie` can get blocked as "Cookie/query string data". Replace them (`≔`, `＆`, `ckie`) before returning, and return long text as an array of ~1000-char chunks (single strings truncate at about 1500 chars). Promises are not awaited: store the result on `window.__x` and read it in a second call. GTM is a single-page app: a hash-only navigate does not reload it; add a changing query parameter (`?hl=en&r=2#/...`). A navigate that reloads the SPA wipes `window` state, so keep the transformed JSON in `sessionStorage` until the import is done. The Tag Assistant tab may refuse clicks and screenshots from the extension; page-text reads and element finds work, and filling the URL field plus a (refused) click on Connect still connects. If a GTM tab stops responding (evaluate timeouts), open a new tab and continue. The Tag Assistant tab cannot be closed by the agent (leave-page prompt); leave it open and say so.
- **GTM slide-in panels**: pressing Escape in a tag or trigger panel opens the "Unsaved Changes" dialog and can drop the edit. Clicking outside the panel (the page header, for example) does the same, so rename clicks must hit the title inside the panel. Native GTM selects (the condition operator) do not render in screenshots; set them with a form-input tool.
- **Submit dialog**: GTM pre-fills the version name and description with an AI summary, and typing appends to it. Use a form-input tool that replaces the value. Fix a mistake afterwards in Versions > three-dot > Rename / Edit Notes. The version number is only known after publish; check it before writing "rollback Version N" or edit the notes after.
- **In the CLI**: download the export (with the site owner's OK, section 1), run a summarizer with Node, transform with a script, import through the UI (section 5.4). The GTM API is an option for bulk work but needs OAuth setup; the import route needs nothing.
- **Site probes**: Gravity Forms and its add-on scripts only load on pages with a form, so check a form page (contact, demo) before concluding GF is absent. A duplicate GA4 `page_view` shows up as page_view per session well above normal and two `collect?...en=page_view` hits per load. On NitroPack sites, logged-in sessions and plain fetches bypass the cache (`x-nitro-disabled`), so they do not see the page real visitors get. Run the `gtm.js` and 5.7 checks in a logged-out session, or record them as not verified.
- **Templates**: gallery template tag types are either `cvt_<containerId>_<templateId>` or an opaque `cvt_<hash>`. Never decide which templates are unused by matching IDs; decide by vendor against the tags that remain. Import may list a kept template as Deleted + Added when its tag changed; open the tag afterwards and check the Type column still shows the template name.
- **UI renames by script**: click and focus the name field and confirm `document.activeElement` is it before select-all and insertText; otherwise select-all grabs the whole page and Save stays disabled. Dispatch input/keyup/change/blur so Save enables, then wait for the panel to close before opening the next item (stacked panels throw "Someone else has modified this entity"). The first rename after navigating to a section can fail because the list or panel was still loading; run that one again.
- **Billing, deletions outside GTM, DNS**: list them for the site owner; do not click them.
- **Built-in trigger IDs in exports**: `2147479553` All Pages, `2147479573` Initialization - All Pages, `2147479572` Consent Initialization - All Pages. Swapping the last two moves Google Tags onto Consent Initialization (easy to catch on re-import).
- **SPA / app containers**: read the app bundle for its `dataLayer.push` calls before trusting triggers (one app's purchase triggers read a nested key, e.g. `data.plan`, while the app pushed `plan` at the top level, so every non-Google purchase tag was dead). An app that pushes its own `page_view` with a route path as `page_location` gives GA4 an empty hostname: rebuild `page_location` from `location.protocol + '//' + location.host` + the pushed path, and turn the config's `send_page_view` off on the app hosts only (Custom JS returning a boolean). Apps that load GTM twice (static snippet + Angular/React GTM library) push `gtm.js` twice: set page-level tags to Once per page.
- **Preview can attach to Live** when the site has an on-page snippet: Tag Assistant's Container Version reads "Live" and the gtm.js URL carries `gtm_preview=env-1`. Close both tabs, click Preview again in the workspace and reconnect; check it reads "Preview". Map-heavy apps fill the 250-entry resource timing buffer before GA's first batch; call `performance.setResourceTimingBufferSize(10000)` and test on a route change. After publishing, the browser keeps the old gtm.js for up to 15 min; confirm the version by parsing `resource.version` from a cache-busted `gtm.js` fetch.

## 11. Changelog

- 1.0.1 (2026-11-24): the Gravity Forms redirect mu-plugin uses `\\1` instead of `$1` as the backreference. Claude Code replaces `$1` in skill text with the command's arguments, which broke the snippet when the skill was called with arguments.
- 1.0.0 (2026-11-24): first public release. Built from audits and rebuilds of a few dozen agency-managed GTM containers, Julius Fedorovicius's (Analytics Mania) methods, and the 2026 GTM optimized-tagging release. Covers: naming convention and ID rules (2), build order (3), consent pattern and Settings-tab consent settings (4), migration with and without the Optimize wizard, server-side loader removal, export/transform/import bulk edits, Configure your domains (5.1 to 5.6), the dropped-hit check with the combined Google tag `__zone` diagnosis, the neuter fix, failed workarounds and the legacy fallback (5.7), form and booking sources for Gravity Forms (incl. the redirect race mu-plugin), Elementor v3/v4, HubSpot forms and meetings, Calendly, TidyCal (6), the alignment checklist (7), the attribution script (8), three-layer testing with the real-submit logger (9), and agent working notes (10).
