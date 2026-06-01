# Back up files first
mkdir backups; cp *.html _includes _config.yml styles.css backups -Recurse

# Files to fix
$files = @(
  'index.html','about.html','bass.html','contact.html','drums.html',
  'gigs.html','setlist.html','lead-guitar.html','media.html',
  'rhythm-guitar.html','vocals.html'
)

foreach ($f in $files) {
  if (Test-Path $f) {
    $text = Get-Content $f -Raw -ErrorAction Stop

    # Remove top YAML front-matter: --- layout: default ---
    $text = $text -replace '^\s*---\s*\r?\n\s*layout:\s*default\s*\r?\n\s*---\s*\r?\n',''

    # Replace header include block (<header> {% include header.html %} </header>) with <head> include
    $text = $text -replace '<header>\s*\{\%\s*include\s+header\.html\s*\%\}\s*</header>','<head>' + "`r`n" + '{% include header.html %}' + "`r`n" + '</head>'

    Set-Content -Path $f -Value $text -Encoding UTF8
    Write-Host "Patched $f"
  } else {
    Write-Host "Skipped (not found): $f"
  }
}

# Comment out theme in _config.yml (prevents GitHub Pages theme injection)
if (Test-Path '_config.yml') {
  (Get-Content _config.yml) -replace '^\s*theme:\s*jekyll-theme-cayman\s*$','# theme: jekyll-theme-cayman' | Set-Content _config.yml -Encoding UTF8
  Write-Host "Updated _config.yml (commented theme)"
}

# Append correct .home-cta CSS (ensures Watch & Listen pill styles apply)
$cssFix = @'
/* Added: ensure .home-cta styles apply (fix nested-sass-like rules) */
.home-cta {
  padding: 12px 30px;
  border-radius: 50px;
  text-decoration: none;
  font-weight: bold;
  text-transform: uppercase;
  display: inline-block;
  transition: all 0.3s ease;
  color: #000;
  background-color: transparent;
  border: none;
}
.home-cta:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}
'@

Add-Content -Path 'styles.css' -Value $cssFix
Write-Host "Appended CSS fix to styles.css"