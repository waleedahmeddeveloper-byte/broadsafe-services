const fs = require('fs');
const path = require('path');

// Load configuration
const config = JSON.parse(fs.readFileSync('site-config.json', 'utf8'));

// Load components
function loadComponent(componentPath) {
    try {
        return fs.readFileSync(componentPath, 'utf8');
    } catch (error) {
        console.warn(`Warning: Could not load component ${componentPath}`);
        return '';
    }
}

// Build single page
function buildPage(pageConfig) {
    try {
        console.log(`Building: ${pageConfig.output}...`);
        
        // Load base template
        const template = fs.readFileSync(path.join(config.directories.templates, 'base.html'), 'utf8');
        
        // Load page content
        const content = fs.readFileSync(pageConfig.source, 'utf8');
        
        // Extract content between main tags (preserve existing content)
        const mainContent = extractMainContent(content);
        
        // Load all components
        const metaComponent = loadComponent(config.components.meta);
        const trackingNoscript = loadComponent(config.components.trackingNoscript);
        const headerComponent = loadComponent(config.components.header);
        const mobileNavComponent = loadComponent(config.components.mobileNav);
        const footerComponent = loadComponent(config.components.footer);
        const sharedScripts = loadComponent(config.components.sharedScripts);
        
        // Replace placeholders with components
        let output = template
            .replace('<!-- {{meta}} -->', metaComponent)
            .replace('<!-- {{trackingNoscript}} -->', trackingNoscript)
            .replace('<!-- {{header}} -->', headerComponent)
            .replace('<!-- {{mobileNav}} -->', mobileNavComponent)
            .replace('<!-- {{content}} -->', mainContent)
            .replace('<!-- {{footer}} -->', footerComponent)
            .replace('<!-- {{sharedScripts}} -->', sharedScripts);
        
        // Replace page-specific variables
        output = replaceVariables(output, pageConfig);
        
        // Insert CSS/JS references
        output = insertAssets(output, config.globalAssets, pageConfig);
        
        // Write output
        const outputPath = path.join(config.directories.output, pageConfig.output);
        fs.mkdirSync(path.dirname(outputPath), { recursive: true });
        fs.writeFileSync(outputPath, output, 'utf8');
        
        console.log(`✅ Built: ${pageConfig.output}`);
    } catch (error) {
        console.error(`❌ Error building ${pageConfig.output}:`, error.message);
    }
}

function extractMainContent(html) {
    // Extract content within main/article/section tags
    // Preserve exactly as-is
    const mainMatch = html.match(/<main[^>]*>([\s\S]*?)<\/main>/i);
    if (mainMatch) {
        return mainMatch[1]; // Return inner content only
    }
    
    // Fallback: try to extract body content minus header/footer
    const bodyMatch = html.match(/<body[^>]*>([\s\S]*?)<\/body>/i);
    if (bodyMatch) {
        let content = bodyMatch[1];
        // Remove header, nav, footer if present
        content = content.replace(/<header[^>]*>[\s\S]*?<\/header>/gi, '');
        content = content.replace(/<nav[^>]*>[\s\S]*?<\/nav>/gi, '');
        content = content.replace(/<footer[^>]*>[\s\S]*?<\/footer>/gi, '');
        return content.trim();
    }
    
    return html;
}

function replaceVariables(html, pageConfig) {
    // Replace all template variables
    html = html.replace(/\{\{title\}\}/g, pageConfig.title || '');
    html = html.replace(/\{\{siteName\}\}/g, config.siteName || '');
    html = html.replace(/\{\{PAGE_TITLE\}\}/g, pageConfig.title || '');
    html = html.replace(/\{\{PAGE_DESCRIPTION\}\}/g, pageConfig.description || '');
    html = html.replace(/\{\{PAGE_URL\}\}/g, pageConfig.canonical || config.baseUrl);
    html = html.replace(/\{\{OG_TYPE\}\}/g, pageConfig.schemaType || 'website');
    html = html.replace(/\{\{OG_IMAGE\}\}/g, pageConfig.ogImage || `${config.baseUrl}/images/og-image.png`);
    
    return html;
}

function getAssetPrefix(outputPath) {
    const normalized = outputPath.replace(/\\/g, '/');
    const dir = path.posix.dirname(normalized);
    if (dir === '.' || dir === '/') {
        return '';
    }
    const depth = dir.split('/').filter(Boolean).length;
    return '../'.repeat(depth);
}

function insertAssets(html, globalAssets, pageConfig) {
    // Insert site.css FIRST (before CDN assets)
    const assetPrefix = getAssetPrefix(pageConfig.output || '');
    let cssLinks = `<link rel="stylesheet" href="${assetPrefix}assets/css/site.css">\n    `;
    
    // Add global CSS from CDN
    cssLinks += globalAssets.css.map(css => 
        `<link rel="stylesheet" href="${css}">`
    ).join('\n    ');
    
    html = html.replace('<!-- {{globalCSS}} -->', cssLinks);
    
    // Insert global JS
    const jsLinks = globalAssets.js.map(js => 
        `<script src="${js}" defer></script>`
    ).join('\n    ');
    html = html.replace('<!-- {{globalJS}} -->', jsLinks);
    
    // Handle page-specific CSS/JS
    html = html.replace('<!-- {{pageCSS}} -->', pageConfig.customCSS || '');
    html = html.replace('<!-- {{pageJS}} -->', pageConfig.customJS || '');
    
    return html;
}

// Build all pages
console.log('🚀 Starting build process...\n');
config.pages.forEach(buildPage);
console.log('\n✅ Build complete!');
