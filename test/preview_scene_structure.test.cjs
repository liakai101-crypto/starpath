const fs = require('fs');
const assert = require('assert');

const html = fs.readFileSync('preview.html', 'utf8');

function expectIncludes(token, message) {
  assert(html.includes(token), message);
}
function expectExcludes(token, message) {
  assert(!html.includes(token), message);
}

expectIncludes('bridge-command-strip', 'Command Core should expose a bridge command strip.');
expectIncludes('bridge-reactor-meaning', 'Command Core should describe the central reactor meaningfully.');
expectIncludes('profile-dossier-hero', 'Profile Archive should have a dossier-style hero section.');
expectIncludes('profile-memory-ribbon', 'Profile Archive should expose a curated memory ribbon.');
expectIncludes('profile-return-rail', 'Profile Archive should include a clear return rail to Command Core.');
expectIncludes('deep-space-parallax', 'Orbit should include a deeper parallax layer for wide space.');
expectIncludes('ship-wide-silhouette', 'Wide Space should use a distinct low-detail ship silhouette.');
expectIncludes('html[lang="zh-TW"] .orbit-grid-main', 'Traditional Chinese layout should define dedicated orbit grid tuning.');
expectIncludes('html[lang="zh-TW"] .signal-head', 'Traditional Chinese layout should rebalance signal header spacing.');
expectIncludes('解除隱形', 'Invisible routes should expose a release action in Traditional Chinese.');
expectIncludes('Invisible routes', 'Invisible route section should be renamed in English.');
expectExcludes("else if (nextTier === 'distant' && orbitViewMode === 'local') {\r\n          orbitViewMode = 'wide';", 'Selecting a distant friend should no longer force Wide Space.');

console.log('preview scene structure ok');
