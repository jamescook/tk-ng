document.addEventListener('click', function(e) {
  var btn = e.target.closest('.copy-path-btn');
  if (!btn) return;

  var path = btn.getAttribute('data-path');
  var img = btn.querySelector('img');
  if (!img) return;

  var baseUrl = document.body.getAttribute('data-baseurl') || '';
  var copySrc = img.getAttribute('src');
  var checkSrc = baseUrl + '/assets/images/check.svg';

  navigator.clipboard.writeText(path).then(function() {
    img.setAttribute('src', checkSrc);
    btn.style.opacity = '1';
    setTimeout(function() {
      img.setAttribute('src', copySrc);
      btn.style.opacity = '';
    }, 1000);
  });
});
