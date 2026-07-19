#!/usr/bin/env node
const palettes = {
  dark: { bg:'#16191D', surface:'#1E2228', raised:'#262B33', text:'#E6E9ED', dim:'#9AA3AE', accent:'#2563EB' },
  light: { bg:'#F4F5F7', surface:'#FFFFFF', raised:'#FFFFFF', text:'#1B2430', dim:'#5A6572', accent:'#1D4ED8' }
};
function lum(hex) {
  const rgb = hex.match(/[0-9a-f]{2}/gi).map(x => parseInt(x, 16) / 255)
    .map(x => x <= .04045 ? x / 12.92 : ((x + .055) / 1.055) ** 2.4);
  return .2126 * rgb[0] + .7152 * rgb[1] + .0722 * rgb[2];
}
function ratio(a, b) { const x=lum(a), y=lum(b); return (Math.max(x,y)+.05)/(Math.min(x,y)+.05); }
let failed = false;
for (const [name, p] of Object.entries(palettes)) {
  for (const [fg, bg, minimum] of [['text','bg',4.5], ['text','surface',4.5], ['text','raised',4.5], ['dim','bg',4.5], ['dim','surface',4.5], ['accent','surface',3]]) {
    const actual = ratio(p[fg], p[bg]);
    console.log(`${name}: ${fg}/${bg} ${actual.toFixed(2)}:1 (minimum ${minimum}:1)`);
    if (actual < minimum) failed = true;
  }
}
if (failed) { console.error('Contrast validation failed.'); process.exit(1); }

