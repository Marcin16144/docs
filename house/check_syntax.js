const fs = require('fs');
const html = fs.readFileSync('D:/docs/house/rosliny/kulinarne.html', 'utf8');
const start = html.indexOf('<script>') + 8;
const end = html.lastIndexOf('</script>');
const script = html.slice(start, end);

// Track state through the script
let inSingleStr = false, inDoubleStr = false, inTemplateLit = false;
let inLineComment = false, inBlockComment = false;
let escape = false;
const suspicious = [];

for (let i = 0; i < script.length; i++) {
  const ch = script[i];
  const code = script.charCodeAt(i);

  if (escape) { escape = false; continue; }

  if (inLineComment) {
    if (ch === '\n') inLineComment = false;
    continue;
  }
  if (inBlockComment) {
    if (ch === '*' && script[i+1] === '/') { inBlockComment = false; i++; }
    continue;
  }
  if (inSingleStr) {
    if (ch === '\\') { escape = true; continue; }
    if (ch === "'") inSingleStr = false;
    continue;
  }
  if (inDoubleStr) {
    if (ch === '\\') { escape = true; continue; }
    if (ch === '"') inDoubleStr = false;
    continue;
  }
  if (inTemplateLit) {
    if (ch === '\\') { escape = true; continue; }
    if (ch === '`') inTemplateLit = false;
    continue;
  }

  // Code context
  if (ch === '/' && script[i+1] === '/') { inLineComment = true; continue; }
  if (ch === '/' && script[i+1] === '*') { inBlockComment = true; continue; }
  if (ch === "'") { inSingleStr = true; continue; }
  if (ch === '"') { inDoubleStr = true; continue; }
  if (ch === '`') { inTemplateLit = true; continue; }

  // Check for non-ASCII in code context
  if (code > 127) {
    const lineNum = script.slice(0, i).split('\n').length;
    const lineStart = script.lastIndexOf('\n', i) + 1;
    suspicious.push('Script line ' + lineNum + ': U+' + code.toString(16).toUpperCase().padStart(4,'0') + ' [' + ch + '] in: ' + script.slice(lineStart, lineStart + 80).replace(/\n/g, '\\n'));
  }
}

if (suspicious.length === 0) {
  console.log('No non-ASCII chars in code context.');
} else {
  suspicious.forEach(s => console.log(s));
}

// Also search for template literals (backtick strings)
const backtickMatches = [];
for (let i = 0; i < script.length; i++) {
  if (script[i] === '`') {
    const lineNum = script.slice(0, i).split('\n').length;
    const lineStart = script.lastIndexOf('\n', i) + 1;
    backtickMatches.push('Backtick at script line ' + lineNum + ': ' + script.slice(lineStart, lineStart + 60).replace(/\n/g, '\\n'));
  }
}
if (backtickMatches.length > 0) {
  console.log('\nTemplate literals found:');
  backtickMatches.forEach(m => console.log(m));
}
