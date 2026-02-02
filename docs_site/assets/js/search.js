(function() {
  'use strict';

  var searchData = null;
  var searchIndex = null;

  // Load search data once
  fetch('/assets/js/search-data.json')
    .then(function(response) { return response.json(); })
    .then(function(data) {
      searchData = data;
      searchIndex = lunr(function() {
        this.ref('id');
        this.field('title', { boost: 100 });
        this.field('methods', { boost: 10 });
        this.field('content');

        Object.keys(data).forEach(function(key) {
          this.add({
            id: key,
            title: data[key].title,
            methods: data[key].methods,
            content: data[key].content
          });
        }, this);
      });
    });

  function initSearch() {
    var searchInput = document.getElementById('search-input');
    var searchResults = document.getElementById('search-results');

    if (!searchInput || !searchResults) return;

    searchInput.addEventListener('input', function() {
      var query = this.value.trim();

      if (query.length < 2) {
        searchResults.innerHTML = '';
        searchResults.style.display = 'none';
        return;
      }

      if (!searchIndex) return;

      var phraseMatch = query.match(/^"(.+)"$/);
      var phrase = phraseMatch ? phraseMatch[1].toLowerCase() : null;
      var lunrQuery = query;

      if (phrase) {
        lunrQuery = phrase.split(/\s+/).map(function(w) { return '+' + w; }).join(' ');
      } else {
        lunrQuery = query + ' ' + query + '*';
      }

      var results = searchIndex.search(lunrQuery);

      if (phrase) {
        results = results.filter(function(r) {
          var doc = searchData[r.ref];
          var all = (doc.title + ' ' + doc.methods + ' ' + doc.content).toLowerCase();
          return all.includes(phrase);
        });
      }

      if (results.length === 0) {
        searchResults.innerHTML = '<div class="search-result-item">No results found</div>';
        searchResults.style.display = 'block';
        return;
      }

      var queryLower = query.toLowerCase();

      results.sort(function(a, b) {
        var docA = searchData[a.ref];
        var docB = searchData[b.ref];
        var titleA = docA.title.toLowerCase();
        var titleB = docB.title.toLowerCase();

        var aExact = titleA === queryLower;
        var bExact = titleB === queryLower;
        if (aExact && !bExact) return -1;
        if (bExact && !aExact) return 1;

        var aTitle = titleA.includes(queryLower);
        var bTitle = titleB.includes(queryLower);
        if (aTitle && !bTitle) return -1;
        if (bTitle && !aTitle) return 1;

        var aMethod = (docA.methods || '').toLowerCase().includes(queryLower);
        var bMethod = (docB.methods || '').toLowerCase().includes(queryLower);
        if (aMethod && !bMethod) return -1;
        if (bMethod && !aMethod) return 1;

        return b.score - a.score;
      });

      var html = results.slice(0, 10).map(function(result) {
        var doc = searchData[result.ref];
        var badge = doc.type === 'module' ? '<span class="badge bg-success">M</span>' : '<span class="badge bg-primary">C</span>';
        var titleLower = doc.title.toLowerCase();
        var snippet = '';

        if (!titleLower.includes(queryLower)) {
          var methodsLower = (doc.methods || '').toLowerCase();
          var methodMatch = methodsLower.indexOf(queryLower);
          if (methodMatch !== -1) {
            var start = methodsLower.lastIndexOf(' ', methodMatch);
            start = start === -1 ? 0 : start + 1;
            var end = doc.methods.indexOf(' ', methodMatch);
            end = end === -1 ? doc.methods.length : end;
            var methodName = doc.methods.substring(start, end);
            snippet = '<span class="search-snippet">#' + methodName + '</span>';
          } else {
            var contentLower = doc.content.toLowerCase();
            var matchIdx = contentLower.indexOf(queryLower);
            if (matchIdx !== -1) {
              var start = Math.max(0, matchIdx - 15);
              var end = Math.min(matchIdx + queryLower.length + 25, doc.content.length);
              var matchText = doc.content.substring(start, end).trim();
              if (start > 0) matchText = '...' + matchText;
              if (end < doc.content.length) matchText += '...';
              snippet = '<span class="search-snippet">' + matchText + '</span>';
            }
          }
        }

        return '<a href="' + doc.url + '" class="search-result-item">' + badge + ' ' + doc.title + snippet + '</a>';
      }).join('');

      searchResults.innerHTML = html;
      searchResults.style.display = 'block';
    });

    searchInput.addEventListener('focus', function() {
      if (this.value.trim().length >= 2 && searchResults.innerHTML) {
        searchResults.style.display = 'block';
      }
    });

    document.addEventListener('click', function(e) {
      if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
        searchResults.style.display = 'none';
      }
    });
  }

  // Init on first load and after Turbo navigation
  initSearch();
  document.addEventListener('turbo:load', initSearch);
})();
