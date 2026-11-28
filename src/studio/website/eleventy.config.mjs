import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { HtmlBasePlugin } from "@11ty/eleventy";

const SITE_ROOT = path.resolve(import.meta.dirname, "src");

function contentHash(assetPath) {
  const fullPath = path.join(SITE_ROOT, assetPath.replace(/^\/+/, ""));
  if (!fs.existsSync(fullPath)) return "";
  return crypto
    .createHash("sha256")
    .update(fs.readFileSync(fullPath))
    .digest("hex")
    .slice(0, 10);
}

export default function (eleventyConfig) {
  // GitHub Pages serves the site under /perception/; the plugin prefixes every root-relative URL.
  eleventyConfig.addPlugin(HtmlBasePlugin);
  eleventyConfig.addPassthroughCopy({ "src/assets": "assets" });
  eleventyConfig.addPassthroughCopy({ "../screens": "screens" });

  eleventyConfig.addWatchTarget("src/assets/");

  // [WEBSITE-ASSET-VERSIONS] Content-hashed URLs for site-local CSS/JS.
  eleventyConfig.addFilter("versioned", (assetPath) => {
    const hash = contentHash(assetPath);
    return hash ? `${assetPath}?v=${hash}` : assetPath;
  });

  // Build-time syntax highlighting (JSON & code blocks) using Perception tokens.
  eleventyConfig.addFilter("highlightJson", (code) => {
    const escaped = String(code)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
    return escaped.replace(
      /(&quot;|")([^"]*)\1(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d+)?(?=[,\s}\]])|[{}[\]:,]/g,
      (match, quote, _inner, isKey, keyword) => {
        if (isKey) {
          const idx = match.lastIndexOf(":");
          return `<span class="tok-key">${match.slice(0, idx)}</span><span class="tok-punct">:</span>`;
        }
        if (quote) return `<span class="tok-str">${match}</span>`;
        if (keyword) return `<span class="tok-kw">${match}</span>`;
        if (/^-?\d/.test(match)) return `<span class="tok-num">${match}</span>`;
        return `<span class="tok-punct">${match}</span>`;
      }
    );
  });

  return {
    pathPrefix: process.env.PAGES_PATH_PREFIX || "/",
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      data: "_data",
    },
    htmlTemplateEngine: "njk",
    markdownTemplateEngine: "njk",
    templateFormats: ["njk", "md", "html"],
  };
}
