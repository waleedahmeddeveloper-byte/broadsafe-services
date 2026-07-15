# Broadsafe Page Template Checklist

Use this checklist when creating or updating any page on the Broadsafe website.

## ✅ HTML Structure

### `<head>` Section
- [ ] Copy meta tags from `components/meta.html`
- [ ] Update page-specific values:
  - [ ] `<title>` tag
  - [ ] Meta description
  - [ ] Meta keywords
  - [ ] Canonical URL
  - [ ] Open Graph title, description, URL
  - [ ] Schema.org JSON-LD markup (page-specific)
- [ ] Include FontAwesome CSS
- [ ] Include Slick Carousel CSS (if needed)
- [ ] Add page-specific `<style>` block with:
  - [ ] Copy responsive-master.css base styles
  - [ ] Add page-specific CSS
  - [ ] Include all media queries

### `<body>` Section Structure
```html
<body>
  <!-- 1. Google Tag Manager noscript -->
  <!-- 2. Header component -->
  <!-- 3. Mobile nav component -->
  <!-- 4. Page content -->
  <!-- 5. Footer component -->
  <!-- 6. Page-specific scripts -->
  <!-- 7. Shared scripts component -->
</body>
```

## ✅ Components to Include

- [ ] `components/tracking-noscript.html` (after `<body>`)
- [ ] `components/header.html`
- [ ] `components/mobile-nav.html`
- [ ] `components/footer.html` (before closing `</body>`)
- [ ] `components/shared-scripts.html` (before closing `</body>`)

## ✅ Responsive CSS Checklist

### Variables
- [ ] CSS custom properties defined in `:root`
- [ ] `--vh` variable for mobile viewport height

### Base Styles
- [ ] Mobile-first approach
- [ ] `box-sizing: border-box` on all elements
- [ ] Proper font sizing (16px minimum for iOS)
- [ ] Line height for readability

### Hero Section (if applicable)
- [ ] Height: `100vh` fallback, then `100dvh`
- [ ] Min-height set appropriately
- [ ] Background image with `object-fit: cover`
- [ ] Overlay for text readability
- [ ] Content properly z-indexed

### Navigation
- [ ] Desktop nav hidden on mobile
- [ ] Mobile menu button visible on mobile
- [ ] Mobile nav slide-in animation
- [ ] Header scroll effects
- [ ] Touch targets minimum 44x44px

### Breakpoints Required
- [ ] `@media (max-width: 992px)` - Tablet
- [ ] `@media (max-width: 768px)` - Mobile
- [ ] `@media (max-width: 480px)` - Small mobile
- [ ] `@media (max-width: 360px)` - Extra small
- [ ] `@media (max-height: 500px) and (orientation: landscape)` - Landscape
- [ ] `@media (hover: none) and (pointer: coarse)` - Touch devices
- [ ] `@media (prefers-reduced-motion: reduce)` - Accessibility

## ✅ JavaScript Checklist

### Required Functions
- [ ] Cookie consent functions
- [ ] Theme toggle (if applicable)
- [ ] Mobile menu toggle
- [ ] Header scroll effects (requestAnimationFrame)
- [ ] Debounced resize handler
- [ ] Viewport height management
- [ ] Touch optimizations
- [ ] iOS zoom prevention

### Event Listeners
- [ ] No duplicate listeners
- [ ] Use `{ passive: true }` for scroll/touch events
- [ ] Properly remove listeners when needed
- [ ] Clean up on page unload

### Performance
- [ ] Use `requestAnimationFrame` for scroll effects
- [ ] Debounce resize handlers
- [ ] Lazy load images (if applicable)
- [ ] Minimize DOM queries

## ✅ Content Requirements

### Text Content
- [ ] All text is readable on mobile
- [ ] Font sizes use `clamp()` or responsive units
- [ ] Line lengths appropriate (45-75 characters)
- [ ] Sufficient contrast ratios (WCAG AA minimum)

### Images
- [ ] All images have `alt` attributes
- [ ] Hero images compressed/optimized
- [ ] Responsive image sizes (if applicable)
- [ ] Lazy loading implemented (if applicable)

### Forms (if applicable)
- [ ] Input fields 16px minimum font size
- [ ] Labels properly associated
- [ ] Touch-friendly spacing
- [ ] Error messages visible
- [ ] Submit buttons 44x44px minimum

### Links & Buttons
- [ ] All clickable elements 44x44px minimum
- [ ] Hover states defined
- [ ] Active/focus states visible
- [ ] Phone numbers use `tel:` protocol
- [ ] Email links use `mailto:` protocol

## ✅ SEO Requirements

- [ ] Unique page title (50-60 characters)
- [ ] Unique meta description (150-160 characters)
- [ ] Relevant keywords
- [ ] Proper heading hierarchy (H1 → H2 → H3)
- [ ] Only one H1 per page
- [ ] Schema.org markup appropriate to page type
- [ ] Canonical URL set correctly
- [ ] No broken links

## ✅ Accessibility Requirements

- [ ] All images have descriptive alt text
- [ ] Proper heading hierarchy
- [ ] ARIA labels on interactive elements
- [ ] Keyboard navigation works
- [ ] Focus indicators visible
- [ ] Color contrast meets WCAG AA
- [ ] Form labels and errors
- [ ] Skip to content link (optional)

## ✅ Testing Checklist

### Desktop Browsers
- [ ] Chrome
- [ ] Firefox
- [ ] Safari
- [ ] Edge

### Mobile Devices
- [ ] iPhone (Safari)
- [ ] Android (Chrome)
- [ ] Tablet (iPad)

### Breakpoint Testing
- [ ] 320px - iPhone SE
- [ ] 360px - Small Android
- [ ] 375px - iPhone standard
- [ ] 480px - Landscape mobile
- [ ] 768px - iPad portrait
- [ ] 1024px - iPad landscape
- [ ] 1440px - Laptop
- [ ] 1920px - Desktop

### Functionality Testing
- [ ] Mobile menu opens/closes
- [ ] All links work
- [ ] Forms submit (if applicable)
- [ ] No console errors
- [ ] No horizontal scroll
- [ ] Smooth scrolling
- [ ] Images load correctly
- [ ] Phone links work on mobile
- [ ] Header hides on scroll down
- [ ] Header shows on scroll up

### Performance Testing
- [ ] Lighthouse score >90
- [ ] Page loads in <3 seconds
- [ ] No layout shift (CLS <0.1)
- [ ] Smooth 60fps animations

## ✅ Final Validation

- [ ] HTML validates (W3C Validator)
- [ ] CSS validates (W3C CSS Validator)
- [ ] No JavaScript errors in console
- [ ] Schema markup validates (Schema.org)
- [ ] OpenGraph tags test (Facebook Debugger)
- [ ] Twitter Card validates (Twitter Validator)
- [ ] Google Search Console no errors
- [ ] Mobile-friendly test passes (Google)

---

## 📋 Quick Copy-Paste Order

1. Copy `<head>` content from `components/meta.html`
2. Add page-specific meta values
3. Add responsive CSS from `templates/responsive-master.css`
4. Add page-specific CSS
5. Copy `<body>` structure:
   - Tracking noscript
   - Header
   - Mobile nav
   - Page content
   - Footer
   - Scripts
6. Test on all breakpoints
7. Validate and deploy

---

## 🎯 Page-Specific Notes

### Homepage (index.html)
- Multiple hero sections
- Service cards grid
- Testimonials slider
- Stats/counters

### Service Pages
- Single hero with service image
- Feature lists
- Pricing tables
- Related services

### Contact Page
- Contact form
- Map integration
- Contact information
- Social media links

### About Page
- Company history timeline
- Team section
- Values/mission

### FAQs Page
- Accordion functionality
- Search/filter
- Category navigation
