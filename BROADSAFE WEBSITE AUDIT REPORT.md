# BROADSAFE WEBSITE AUDIT REPORT

## Executive Summary
A full scan of the active site sources, shared components, templates, stylesheets, scripts, and rebuilt dist output was completed. The requested client fixes were implemented in the canonical sources and regenerated into dist. The main cross-browser inconsistency was traced to shared mobile-nav state handling and duplicated stale markup across source layers; the shared script state was aligned and the rebuilt output now renders consistently from the same source of truth.

## Pages Scanned
Active site sources scanned:
- `about.html`
- `contact.html`
- `index.html`
- `apply-online.html`
- `blog.php`
- `blog-setup.php`
- `site-config.json`
- `components/footer.html`
- `components/shared-scripts.html`
- `components/meta.html`
- `components/header.html`
- `components/mobile-nav.html`
- `components/tracking-noscript.html`
- `components/schema.html`
- `pages/about-content.html`
- `pages/contact-content.html`
- `pages/index-content.html`
- `pages/blog-content.php`
- `pages/services/alarmresponses-content.html`
- `pages/services/cashintransit-content.html`
- `pages/services/commercialsitesecurity-content.html`
- `pages/services/constructionsitesecurity-content.html`
- `pages/services/corporatesecurity-content.html`
- `pages/services/eventsecurity-content.html`
- `pages/services/manufacturingwarehousingsecurity-content.html`
- `pages/services/mobilepatrols-content.html`
- `pages/services/staticguarding-content.html`
- `pages/services/index-content.html`
- `services/alarmresponses.html`
- `services/cashintransit.html`
- `services/carparkmanagementservices.html`
- `services/cleaningservices.html`
- `services/commercialsitesecurity.html`
- `services/constructionsitesecurity.html`
- `services/corporatesecurity.html`
- `services/eventsecurity.html`
- `services/facilitymanagementservices.html`
- `services/index.html`
- `services/maintenanceservices.html`
- `services/manufacturingwarehousingsecurity.html`
- `services/mobilepatrols.html`
- `services/staticguarding.html`
- `assets/css/site.css`
- `assets/css/responsive.css`
- `assets/js/responsive.js`
- `templates/base.html`
- `templates/responsive-master.css`
- `templates/responsive-master.js`

Generated output rebuilt and scanned:
- `dist/index.html`
- `dist/about.html`
- `dist/contact.html`
- `dist/apply-online.html`
- `dist/services/index.html`
- `dist/services/alarmresponses.html`
- `dist/services/cashintransit.html`
- `dist/services/commercialsitesecurity.html`
- `dist/services/constructionsitesecurity.html`
- `dist/services/corporatesecurity.html`
- `dist/services/eventsecurity.html`
- `dist/services/manufacturingwarehousingsecurity.html`
- `dist/services/mobilepatrols.html`
- `dist/services/staticguarding.html`

Backup folders were reviewed for comparison only and intentionally excluded from fixes.

## Issues Found
### Browser Issues
- Mobile navigation state was inconsistent across shared page scripts because different templates used different open-state class handling.
- Some pages relied on duplicated markup layers that could drift from the live source and create different behavior between source and dist output.

### Responsive Issues
- The shared mobile-nav open/close state could diverge between breakpoints because the active state was not synchronized across script paths.
- The rebuilt output now uses the shared script state and consistent source fragments.

### Developer Issues
- Repeated content existed across root pages, source fragments, and dist output, which made stale markup easy to leave behind.
- Some generated metadata depended on site-config descriptions that needed to be normalized to match the requested copy rules.

### Security Issues
- No new client-side security defect was introduced during this audit.
- External scripts remain in use for analytics and consent handling; no additional security changes were requested.

### SEO Issues
- Some generated page metadata required Australian spelling and comma normalization.
- Canonical, schema, title, and social metadata were preserved as-is unless they were part of the requested copy fixes.

### Accessibility Issues
- Low-contrast service CTA headings were fixed through a shared stylesheet rule.
- The shared footer acknowledgements were unified so spacing and typography remain consistent across pages.

### Performance Issues
- No performance regression was introduced by the requested changes.
- The build was regenerated from the source fragments to avoid manual duplication in dist.

## Client Requested Issues
1. Footer copyright standardized to 2026 only.
2. Removed "Serving all of Australia" from the footer and page-level instances.
3. Unified Traditional Custodians section styling through the shared footer.
4. Removed commas before "and" where incorrect.
5. Replaced American spellings with Australian spellings where requested and where clearly part of the same pattern.
6. Fixed home page sector and quote copy.
7. Fixed static guarding copy, headings, FAQ wording, and readability.
8. Unified Request a Quote sections across the active page sources.
9. Removed Location boxes.
10. Removed Nationwide Coverage boxes from instructed pages.
11. Removed Business Hours from Contact page.
12. Removed map from Contact page.

## Fixed Issues
- Shared footer and acknowledgements were normalized.
- Contact page Location box, Business Hours box, and map were removed.
- Home page copy changes were applied.
- Static guarding page copy and visibility fixes were applied.
- Quote-section wording was standardized across the requested page sources.
- The shared mobile-nav behavior was aligned to the same open-state logic.
- Dist output was rebuilt from the updated source fragments.

## Remaining Issues
- Non-requested editorial/content patterns still exist in the blog seed/setup files, such as general Oxford commas in seed content.
- Some form option labels still use "Business Hours Only" as a choice label; these remain because they are functional form options, not the removed Contact-page Business Hours box.
- Some pages still contain legitimate mentions of business hours in service copy, such as mobile patrol and static guarding coverage descriptions.
- Backup snapshots still contain the pre-fix content and were intentionally left unchanged.

## Files Modified
- `components/footer.html`
- `components/shared-scripts.html`
- `assets/css/site.css`
- `site-config.json`
- `about.html`
- `contact.html`
- `index.html`
- `blog.php`
- `pages/about-content.html`
- `pages/blog-content.php`
- `pages/contact-content.html`
- `pages/index-content.html`
- `pages/services/alarmresponses-content.html`
- `pages/services/cashintransit-content.html`
- `pages/services/commercialsitesecurity-content.html`
- `pages/services/constructionsitesecurity-content.html`
- `pages/services/corporatesecurity-content.html`
- `pages/services/eventsecurity-content.html`
- `pages/services/manufacturingwarehousingsecurity-content.html`
- `pages/services/mobilepatrols-content.html`
- `pages/services/staticguarding-content.html`
- `services/alarmresponses.html`
- `services/cashintransit.html`
- `services/carparkmanagementservices.html`
- `services/cleaningservices.html`
- `services/commercialsitesecurity.html`
- `services/constructionsitesecurity.html`
- `services/corporatesecurity.html`
- `services/eventsecurity.html`
- `services/facilitymanagementservices.html`
- `services/index.html`
- `services/maintenanceservices.html`
- `services/manufacturingwarehousingsecurity.html`
- `services/mobilepatrols.html`
- `services/staticguarding.html`
- `dist/index.html`
- `dist/about.html`
- `dist/contact.html`
- `dist/apply-online.html`
- `dist/services/index.html`
- `dist/services/alarmresponses.html`
- `dist/services/cashintransit.html`
- `dist/services/commercialsitesecurity.html`
- `dist/services/constructionsitesecurity.html`
- `dist/services/corporatesecurity.html`
- `dist/services/eventsecurity.html`
- `dist/services/manufacturingwarehousingsecurity.html`
- `dist/services/mobilepatrols.html`
- `dist/services/staticguarding.html`

## Files Not Modified
- Backup folders under `backup_2026-*`
- Unrelated asset images
- Unrelated templates not involved in the requested fixes
- Unrequested blog/setup seed content beyond the one search result aligned with the requested comma cleanup
