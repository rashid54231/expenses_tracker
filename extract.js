const fs = require('fs');

async function extract() {
    const data = fs.readFileSync('C:/Users/rashi/.gemini/antigravity-ide/brain/4ea6326e-3312-4163-bae3-fc5f4983d6f2/.system_generated/logs/transcript_full.jsonl', 'utf-8');
    const lines = data.split('\n');
    let validMatch = null;
    
    for (let i = lines.length - 1; i >= 0; i--) {
        const line = lines[i];
        if (line.includes('dashboard_screen.dart') && line.includes('Total Lines:') && line.includes('TOOL_RESPONSE')) {
            try {
                const obj = JSON.parse(line);
                const findStr = (o) => {
                    if (typeof o === 'string' && o.includes('<line_number>: <original_line>.')) return o;
                    if (typeof o === 'object' && o !== null) {
                        for (let k in o) {
                            let r = findStr(o[k]);
                            if (r) return r;
                        }
                    }
                    return null;
                }
                const content = findStr(obj);
                if (content) {
                    const cLines = content.split(/\r?\n/);
                    if (cLines.length > 500) {
                        validMatch = content;
                        break;
                    }
                }
            } catch (e) {}
        }
    }
    
    if (validMatch) {
        const cLines = validMatch.split(/\r?\n/);
        const original = [];
        let p = false;
        for (let l of cLines) {
            if (p) {
                let m = l.match(/^\d+:\s(.*)/);
                if (!m) m = l.match(/^\d+:(.*)/);
                if (m) original.push(m[1].replace(/^\s/, ''));
                else if (l.includes('The above content shows the entire') || l.includes('Showing lines')) break;
            }
            if (l.includes('<line_number>: <original_line>.')) {
                p = true;
            }
        }
        fs.writeFileSync('C:/Users/rashi/expenses_tracker/lib/features/dashboard/ui/dashboard_screen.dart', original.join('\n'));
        console.log('Restored! Lines: ' + original.length);
    } else {
        console.log('Not found');
    }
}
extract();
