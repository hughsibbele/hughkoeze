/**
 * Lightbox and Masonry Gallery for Stranger to the House
 * Matches the style of the main photography page
 */

(function() {
  'use strict';

  const GAP = 16; // var(--space-2)

  // Lightbox elements
  const lightbox = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightboxImg');
  const lightboxCaption = document.getElementById('lightboxCaption');

  if (!lightbox) return;

  let currentGalleryImages = [];
  let currentLightboxIndex = -1;

  // =========================================
  // MASONRY LAYOUT
  // =========================================

  function initMasonryGallery(grid) {
    const items = Array.from(grid.querySelectorAll('.photo-item'));
    if (items.length === 0) return;

    let columnHeights = [];
    let numColumns = 4;
    let columnWidth = 0;

    function calculateGrid() {
      const containerWidth = grid.clientWidth;
      if (containerWidth < 480) numColumns = 1;
      else if (containerWidth < 768) numColumns = 2;
      else if (containerWidth < 1000) numColumns = 3;
      else numColumns = 4;

      columnWidth = (containerWidth - (numColumns - 1) * GAP) / numColumns;
      columnHeights = new Array(numColumns).fill(0);
    }

    function findShortestColumn() {
      let minHeight = Math.min(...columnHeights);
      return columnHeights.indexOf(minHeight);
    }

    function positionItem(item, img) {
      const col = findShortestColumn();
      const aspectRatio = img.naturalHeight / img.naturalWidth;
      const itemHeight = columnWidth * aspectRatio;

      item.style.left = (col * (columnWidth + GAP)) + 'px';
      item.style.top = columnHeights[col] + 'px';
      item.style.width = columnWidth + 'px';

      columnHeights[col] += itemHeight + GAP;
      grid.style.height = Math.max(...columnHeights) + 'px';
    }

    function layoutAll() {
      calculateGrid();
      items.forEach(item => {
        const img = item.querySelector('img');
        if (img && img.naturalWidth) {
          positionItem(item, img);
        }
      });
    }

    // Wait for images to load then layout
    let loadedCount = 0;
    const totalImages = items.filter(item => item.querySelector('img')).length;

    if (totalImages === 0) {
      // Handle placeholders - just stack them
      calculateGrid();
      items.forEach((item, i) => {
        const col = i % numColumns;
        const row = Math.floor(i / numColumns);
        item.style.left = (col * (columnWidth + GAP)) + 'px';
        item.style.top = (row * (200 + GAP)) + 'px';
        item.style.width = columnWidth + 'px';
        item.style.height = '200px';
      });
      grid.style.height = (Math.ceil(items.length / numColumns) * (200 + GAP)) + 'px';
      return;
    }

    items.forEach(item => {
      const img = item.querySelector('img');
      if (img) {
        if (img.complete && img.naturalWidth) {
          loadedCount++;
          if (loadedCount === totalImages) layoutAll();
        } else {
          img.onload = () => {
            loadedCount++;
            if (loadedCount === totalImages) layoutAll();
          };
          img.onerror = () => {
            loadedCount++;
            if (loadedCount === totalImages) layoutAll();
          };
        }
      }
    });

    // Handle resize
    let resizeTimeout;
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(layoutAll, 150);
    });
  }

  // Initialize all masonry grids
  document.querySelectorAll('.photo-grid').forEach(initMasonryGallery);

  // =========================================
  // LIGHTBOX
  // =========================================

  function getGalleryImages(grid) {
    return Array.from(grid.querySelectorAll('.photo-item img'));
  }

  function openLightbox(src, caption, index, galleryImages) {
    currentGalleryImages = galleryImages;
    currentLightboxIndex = index;

    lightboxImg.src = src;
    if (lightboxCaption) {
      lightboxCaption.textContent = caption || '';
    }

    lightbox.classList.add('active');
    document.body.style.overflow = 'hidden';
  }

  function navigateLightbox(direction) {
    if (currentGalleryImages.length === 0 || currentLightboxIndex < 0) return;

    currentLightboxIndex = (currentLightboxIndex + direction + currentGalleryImages.length) % currentGalleryImages.length;
    const img = currentGalleryImages[currentLightboxIndex];

    // Use full image if available, otherwise use the src
    lightboxImg.src = img.dataset.full || img.src;

    if (lightboxCaption) {
      lightboxCaption.textContent = img.dataset.caption || img.alt || '';
    }
  }

  function closeLightbox() {
    lightbox.classList.remove('active');
    document.body.style.overflow = '';
    currentLightboxIndex = -1;
    currentGalleryImages = [];
  }

  // Click handlers for lightbox
  lightbox.addEventListener('click', (e) => {
    if (e.target === lightbox || e.target.classList.contains('lightbox-close')) {
      closeLightbox();
    }
  });

  const prevBtn = lightbox.querySelector('.lightbox-prev');
  const nextBtn = lightbox.querySelector('.lightbox-next');

  if (prevBtn) {
    prevBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      navigateLightbox(-1);
    });
  }

  if (nextBtn) {
    nextBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      navigateLightbox(1);
    });
  }

  // Keyboard navigation
  document.addEventListener('keydown', (e) => {
    if (!lightbox.classList.contains('active')) return;
    if (e.key === 'Escape') closeLightbox();
    else if (e.key === 'ArrowLeft') navigateLightbox(-1);
    else if (e.key === 'ArrowRight') navigateLightbox(1);
  });

  // Touch swipe support
  let touchStartX = 0;
  let touchEndX = 0;

  lightbox.addEventListener('touchstart', (e) => {
    touchStartX = e.changedTouches[0].screenX;
  }, { passive: true });

  lightbox.addEventListener('touchend', (e) => {
    touchEndX = e.changedTouches[0].screenX;
    const diff = touchStartX - touchEndX;
    if (Math.abs(diff) > 50) {
      if (diff > 0) navigateLightbox(1);
      else navigateLightbox(-1);
    }
  }, { passive: true });

  // Click handlers for gallery images
  document.querySelectorAll('.photo-grid').forEach(grid => {
    grid.addEventListener('click', (e) => {
      const img = e.target.closest('img');
      if (!img) return;

      const galleryImages = getGalleryImages(grid);
      const index = galleryImages.indexOf(img);

      // Use full image if available (data-full attribute)
      const fullSrc = img.dataset.full || img.src;
      const caption = img.dataset.caption || img.alt || '';

      openLightbox(fullSrc, caption, index, galleryImages);
    });
  });

  // Also handle inline images in essay text
  document.querySelectorAll('.inline-image img, .image-comparison img').forEach(img => {
    img.style.cursor = 'pointer';
    img.addEventListener('click', () => {
      const fullSrc = img.dataset.full || img.src;
      const caption = img.dataset.caption || img.alt || '';
      openLightbox(fullSrc, caption, -1, []);
    });
  });

})();
