const fs = require('fs');
const path = require('path');

// Pages to extract content from
const pages = [
    { source: 'index.html', output: 'pages/index-content.html' },
    { source: 'contact.html', output: 'pages/contact-content.html' },
    { source: 'apply-online.html', output: 'pages/apply-online-content.html' },
    { source: 'blog.php', output: 'pages/blog-content.php' }
];

// Service pages
const servicePages = [
    'index.html',
    'alarmresponses.html',
    'cashintransit.html',
    'commercialsitesecurity.html',
    'constructionsitesecurity.html',
    'corporatesecurity.html',
    'eventsecurity.html',
    'manufacturingwarehousingsecurity.html',
    'mobilepatrols.html',
    'staticguarding.html'
].map(file => ({
    source: `services/${file}`,
    output: `pages/services/${file.replace('.html', '-content.html')}`
}));

// Combine all pages
const allPages = [...pages, ...servicePages];

function extractMainContent(html) {
    // Extract content within main tag
    const mainMatch = html.match(/<main[^>]*>([\s\S]*?)<\/main>/i);
    if (mainMatch) {
        return mainMatch[1].trim();
    }
    
    // Fallback: extract body content minus header/nav/footer
    let content = html;
    content = content.replace(/<header[^>]*>[\s\S]*?<\/header>/gi, '');
    content = content.replace(/<nav[^>]*>[\s\S]*?<\/nav>/gi, '');
    content = content.replace(/<footer[^>]*>[\s\S]*?<\/footer>/gi, '');
    content = content.replace(/<head[^>]*>[\s\S]*?<\/head>/gi, '');
    content = content.replace(/<\/body>[\s\S]*$/gi, '');
    content = content.replace(/^[\s\S]*?<body[^>]*>/gi, '');
    
    return content.trim();
}

// Extract content from each page
console.log('🔍 Extracting content from existing pages...\n');

allPages.forEach(page => {
    try {
        if (!fs.existsSync(page.source)) {
            console.log(`⚠️  Skipping ${page.source} (not found)`);
            return;
        }
        
        const html = fs.readFileSync(page.source, 'utf8');
        const content = extractMainContent(html);
        
        // Create output directory if needed
        const outputDir = path.dirname(page.output);
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }
        
        // Write extracted content
        fs.writeFileSync(page.output, content, 'utf8');
        
        console.log(`✅ Extracted: ${page.source} → ${page.output}`);
    } catch (error) {
        console.error(`❌ Error extracting ${page.source}:`, error.message);
    }
});

console.log('\n✨ Content extraction complete!');
