# Hugh's Personal Website

## Project Overview
A personal portfolio website for Hugh, a high school English teacher. The site should be clear and subtly distinctive.

## Structure
- **Home** — Brief intro (2-3 sentences), navigation, strong but simple visual element
- **CV** — Timeline or sectioned layout; selective use of embedded media (videos, presentations) only where they add genuine value; papers and standard items as clean links
- **Writing** — Featured papers with summaries/downloads; links to photo/writing projects (some with dedicated pages)
- **Photography** — May include immersive photo essays with full-bleed images, scroll-based pacing, text overlays
- **Contact** — Email, social links (Instagram, Twitter/X, Substack), possibly a contact form

## Style Direction
Leaning toward: Text-Forward on the home and cv page. Key principle: distinctive creative choices on a subtle scale. Balance clarity and content with distinctive design.

Undecided specifics:
- Exact, distinctive typography choices
- Color palette
- How prominent photography should be site-wide
- Substack integration (embed recent posts vs. simple link)

## Technical Approach
- **Hosting**: Netlify (free tier), connected to GitHub repo for auto-deploy
- **Stack**: Static HTML/CSS, no frameworks or build tools
- **Workflow**: Build/edit in Claude Code → push to GitHub via web interface → auto-deploy

Immersive photo essays are achievable with HTML/CSS alone (full-bleed images, text overlays, scroll pacing). Light JavaScript only if parallax or fade-in effects are desired.

## File Structure
```
/index.html
/cv.html
/writing.html
/photography.html
/contact.html
/css/styles.css
/images/
/files/
/projects/[immersive-project]/index.html
```

## Open Questions
1. Who is the primary audience (employers, academics, general readers)?
2. How often will content be updated? (Affects whether CMS is worthwhile)
3. What is the immersive photo essay project? What's the text/image relationship, pacing, length?
4. Any reference sites Hugh admires?
