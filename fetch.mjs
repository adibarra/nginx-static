import { setOutput } from '@actions/core'

// Fetch the current versions from the download page
const URL = `https://nginx.org/en/download.html`
const html = await fetch(URL).then((r) => r.text())

// Find all the downloadable versions
const re = /"\/download\/nginx-(\d+\.){3}tar\.gz"/g
const matches = html.match(re)

// Clean up the matches to semver format
const clean = (match) => match.replace(/"/g, '').replace('/download/nginx-', '').replace('.tar.gz', '')
const versions = matches.map(clean)

// Map the docker tags to the versions
const tagsMap = Object.fromEntries(versions.map((v) => [v, v]))

// Add the mainline, stable and latests tags
tagsMap['latest'] = versions[0]
tagsMap['mainline'] = versions[0]
tagsMap['stable'] = versions[1]

// Export as github action matrix
// https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#expanding-or-adding-matrix-configurations
const githubActionMatrix = {
  include: Object.entries(tagsMap).map(([tag, version]) => ({ tag, version })),
}

setOutput('matrix', githubActionMatrix)
