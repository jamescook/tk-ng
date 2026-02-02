(function() {
  'use strict';

  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        var code = entry.target;
        if (!code.classList.contains('hljs')) {
          hljs.highlightElement(code);
        }
        observer.unobserve(code);
      }
    });
  }, {
    rootMargin: '100px'
  });

  function observeCodeBlocks() {
    document.querySelectorAll('pre code:not(.hljs)').forEach(function(block) {
      observer.observe(block);
    });
  }

  // Initial observation
  observeCodeBlocks();

  // Re-observe after Turbo navigation
  document.addEventListener('turbo:load', observeCodeBlocks);
})();
