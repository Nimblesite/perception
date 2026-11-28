// The coverage gate [REPO-SPLIT]: merges every `osprey test --coverage-json` report the test jobs
// wrote, keeps only this repository's own files (every path its `paths` file lists), and fails when
// the merged line coverage is below scripts/coverage-thresholds.json. A line counts as covered when any
// suite, under any memory backend, ran it. Reads reports only; runs nothing.
// usage: node scripts/coverage.mjs <workspace> <report.json...>
import { readFileSync } from 'node:fs'
import { dirname, join, relative, resolve, sep } from 'node:path'
import { fileURLToPath } from 'node:url'

const here = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const [workspace, ...reports] = process.argv.slice(2)
if (!workspace || reports.length === 0) {
  console.error('usage: node scripts/coverage.mjs <workspace> <report.json...>')
  process.exit(2)
}
const owned = readFileSync(join(here, 'paths'), 'utf8').split('\n').filter(Boolean)
const { threshold } = JSON.parse(readFileSync(join(here, 'scripts', 'coverage-thresholds.json'), 'utf8'))
const ours = (file) => owned.some((path) => file === path || file.startsWith(`${path}/`))

const lines = new Map()
for (const report of reports) {
  const { files } = JSON.parse(readFileSync(report, 'utf8'))
  for (const [absolute, { lines: counts }] of Object.entries(files)) {
    const file = relative(resolve(workspace), resolve(absolute)).split(sep).join('/')
    if (!ours(file)) continue
    const hits = lines.get(file) ?? new Map()
    for (const [line, count] of Object.entries(counts)) hits.set(line, (hits.get(line) ?? 0) + count)
    lines.set(file, hits)
  }
}
const counted = [...lines.values()].flatMap((hits) => [...hits.values()])
const covered = counted.filter((count) => count > 0).length
const percent = counted.length === 0 ? 0 : Math.floor((covered / counted.length) * 1000) / 10
console.log(`${lines.size} files, ${covered}/${counted.length} lines, ${percent}% (threshold ${threshold}%)`)
if (counted.length === 0 || percent < threshold) {
  console.error(counted.length === 0 ? 'no coverage of this repository\'s files was reported' : `coverage ${percent}% is below ${threshold}%`)
  process.exit(1)
}
