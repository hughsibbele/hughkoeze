# Hugh's Personal Website

## Project Overview
A personal portfolio website for Hugh, a high school English teacher. The site should be clear and subtly distinctive.

## Structure
- **Home** — Name, tagline (Teacher, Writer, Photographer), portrait photo
- **Teaching** — Timeline/sectioned layout; embedded media where valuable; papers as clean links
- **Writing** — Featured papers with summaries/downloads; links to projects
- **Photography** — Infinite-scroll masonry gallery, randomly loads from `images/photography/`
- **About** — Bio, contact info, social links

## Design System (MUST FOLLOW)
The site has an established design system documented in `Design System.html`. **All new pages and components must adhere to this system.** Reference it for:

- **Colors**: Use only the defined CSS variables (warm tones like `--brick`, `--mortar`; accents like `--verdigris`, `--sage`; neutrals like `--charcoal`, `--cream`)
- **Typography**: Josefin Sans for headings (`--font-display`), Source Serif 4 for body (`--font-body`)
- **Decorative elements**: Use the established dividers (line, double, triple, grid, labyrinth, stepped, bracket, square), frames, and corner accents
- **Buttons**: Use existing button classes (`btn-primary`, `btn-secondary`, `btn-tertiary`, `btn-double`, `btn-arrow`)
- **Spacing**: Follow the 8px grid system (`--space-1` through `--space-6`)
- **Patterns**: Use established background patterns when appropriate (grid, lines, crosshatch, dots)

Do not invent new colors, fonts, or decorative styles. Maintain visual consistency across all pages.

## Style Direction
Key principle: distinctive creative choices on a subtle scale. Balance clarity and content with distinctive design. Text-forward on home and CV pages.

## Technical Approach
- **Hosting**: Netlify (free tier), connected to GitHub repo for auto-deploy
- **Stack**: Static HTML/CSS, no frameworks or build tools
- **Workflow**: Build/edit in Claude Code → push to GitHub via web interface → auto-deploy

Immersive photo essays are achievable with HTML/CSS alone (full-bleed images, text overlays, scroll pacing). Light JavaScript only if parallax or fade-in effects are desired.

## Mobile Responsiveness (MUST CHECK)
**Always verify mobile responsiveness when making layout or styling changes.** Test at these breakpoints:
- **768px**: Tablet/small laptop — layouts should adapt, preview panels become overlays
- **480px**: Phone — text sizes reduce, elements stack vertically, touch targets minimum 44px

Key mobile considerations:
- Remove fixed widths (e.g., `max-width: 60%`) on mobile
- Stack flex layouts vertically when horizontal space is limited
- Ensure buttons and interactive elements have touch-friendly sizing
- Test that preview/modal panels work as full-screen overlays on phones

## File Structure
```
/index.html
/teaching.html
/writing.html
/photography.html
/about.html
/css/styles.css
/images/
/images/photography/     ← photos for the gallery
/photos.json             ← manifest of available photos
/scripts/
```

## Maintenance Scripts

### Update Photography Gallery
After adding or removing photos from `images/photography/`, run:
```bash
./scripts/update-photos.sh
```
This regenerates `photos.json` with all image filenames and extracts year from EXIF metadata. The photography page randomly loads from this list.

## Git LFS (Large File Storage)

Photography images are stored using Git LFS to keep the repo lightweight. This was set up in January 2026.

**How it works:**
- Photos in `images/photography/` are tracked by LFS (configured in `.gitattributes`)
- GitHub stores tiny pointer files; actual images live on LFS servers
- When you push, LFS automatically uploads large files separately
- Netlify fetches the real files during deploy

**No maintenance required** — just commit and push as normal. LFS handles everything automatically.

**Tracked file types:** `*.jpg`, `*.jpeg`, `*.png`, `*.gif`, `*.webp`, `*.JPG`, `*.JPEG`, `*.HEIC`, `*.heic`

**If cloning on a new machine:**
```bash
git lfs install   # One-time setup
git clone <repo>  # LFS files download automatically
```

## Open Questions
1. Who is the primary audience (employers, academics, general readers)?
2. How often will content be updated? (Affects whether CMS is worthwhile)
3. What is the immersive photo essay project? What's the text/image relationship, pacing, length?
4. Any reference sites Hugh admires?
