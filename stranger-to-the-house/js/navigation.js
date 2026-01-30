/**
 * Navigation functionality for Stranger to the House
 */

(function() {
  'use strict';

  // Header scroll effect
  const header = document.getElementById('site-header');

  if (header && !header.classList.contains('scrolled')) {
    let lastScroll = 0;

    window.addEventListener('scroll', function() {
      const currentScroll = window.pageYOffset;

      if (currentScroll > 100) {
        header.classList.add('scrolled');
      } else {
        header.classList.remove('scrolled');
      }

      lastScroll = currentScroll;
    }, { passive: true });
  }

  // Mobile menu toggle
  const menuToggle = document.getElementById('menu-toggle');
  const siteNav = document.getElementById('site-nav');

  if (menuToggle && siteNav) {
    menuToggle.addEventListener('click', function() {
      siteNav.classList.toggle('open');

      // Update aria-expanded
      const isOpen = siteNav.classList.contains('open');
      menuToggle.setAttribute('aria-expanded', isOpen);

      // Update button text
      menuToggle.textContent = isOpen ? '✕' : '☰';
    });

    // Close menu when clicking a link
    siteNav.querySelectorAll('a').forEach(function(link) {
      link.addEventListener('click', function() {
        siteNav.classList.remove('open');
        menuToggle.textContent = '☰';
      });
    });

    // Close menu on escape
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && siteNav.classList.contains('open')) {
        siteNav.classList.remove('open');
        menuToggle.textContent = '☰';
      }
    });
  }

  // Smooth scroll for anchor links (backup for browsers without CSS smooth scroll)
  document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
    anchor.addEventListener('click', function(e) {
      const targetId = this.getAttribute('href');
      if (targetId === '#') return;

      const target = document.querySelector(targetId);
      if (target) {
        e.preventDefault();

        const headerHeight = header ? header.offsetHeight : 0;
        const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - headerHeight;

        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });

        // Update URL without jumping
        history.pushState(null, null, targetId);
      }
    });
  });

  // Highlight current section in navbar (optional enhancement)
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.navbar a');

  if (sections.length && navLinks.length) {
    const observerOptions = {
      rootMargin: '-20% 0px -80% 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          const id = entry.target.getAttribute('id');

          navLinks.forEach(function(link) {
            link.style.opacity = link.getAttribute('href') === '#' + id ? '1' : '';
          });
        }
      });
    }, observerOptions);

    sections.forEach(function(section) {
      observer.observe(section);
    });
  }

})();
