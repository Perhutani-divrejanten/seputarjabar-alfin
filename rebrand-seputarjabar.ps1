# Rebrand script for Seputar Jabar
Write-Host "Starting rebrand script..."
# Backup articles.json
Copy-Item -Path "articles.json" -Destination "articles.json.bak.$(Get-Date -Format 'yyyyMMddHHmmss')" -Force

# Initialize counters
$mainPagesChanged = 0
$articlePagesChanged = 0
$cssChanged = 0
$packageChanged = 0
$docsChanged = 0

# Function to replace in file
function Replace-InFile {
    param (
        [string]$filePath,
        [string]$oldString,
        [string]$newString,
        [bool]$caseInsensitive = $false
    )
    $content = Get-Content -Path $filePath -Raw -Encoding UTF8
    $pattern = if ($caseInsensitive) { "(?i)$([regex]::Escape($oldString))" } else { [regex]::Escape($oldString) }
    if ($content -match $pattern) {
        $content = $content -replace $pattern, $newString
        Set-Content -Path $filePath -Value $content -Encoding UTF8
        return $true
    }
    return $false
}

# Branding replacements
$replacements = @(
    @{ Old = "arah berita"; New = "Seputar Jabar" },
    @{ Old = "Arah Berita"; New = "Seputar Jabar" },
    @{ Old = "arahberita"; New = "seputarjabar" },
    @{ Old = "ArahBerita"; New = "SeputarJabar" },
    @{ Old = "arahberita@gmail.com"; New = "seputarjabar@gmail.com" },
    @{ Old = "arahberita"; New = "seputarjabar" },  # for social handles
    @{ Old = "- Arah Berita"; New = "- Seputar Jabar" },
    @{ Old = "Arah Berita"; New = "Seputar Jabar" }  # for meta/title/footer
)

# Encoding fixes
$encodingReplacements = @(
    @{ Old = [char]0x201C; New = '"' },  # “
    @{ Old = [char]0x201D; New = '"' },  # ”
    @{ Old = [char]0x2018; New = "'" },  # ‘
    @{ Old = [char]0x2019; New = "'" },  # ’
    @{ Old = [char]0x2013; New = "-" },  # –
    @{ Old = [char]0x2014; New = "-" },  # —
    @{ Old = [char]0xFFFD; New = " " },  # �
    @{ Old = "&nbsp;"; New = " " }
)

# Logo replacement in HTML
$logoReplacement = @'
<a class="navbar-brand" href="index.html">
    <span style="font-weight: bold; color: #0F766E;">Seputar</span>
    <span style="font-size: smaller; color: #1F3F5F;">Jabar</span>
</a>
'@

# Process HTML files
Get-ChildItem -Path . -Recurse -Filter *.html | ForEach-Object {
    $file = $_.FullName
    $changed = $false

    # Branding
    foreach ($rep in $replacements) {
        if (Replace-InFile -filePath $file -oldString $rep.Old -newString $rep.New -caseInsensitive $true) {
            $changed = $true
        }
    }

    # Encoding
    foreach ($rep in $encodingReplacements) {
        if (Replace-InFile -filePath $file -oldString $rep.Old -newString $rep.New) {
            $changed = $true
        }
    }

    # Logo
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    if ($content -match '<a class="navbar-brand"[^>]*>.*?</a>') {
        $content = $content -replace '<a class="navbar-brand"[^>]*>.*?</a>', $logoReplacement
        Set-Content -Path $file -Value $content -Encoding UTF8
        $changed = $true
    }

    # Remove img src="../img/logo.png"
    if ($content -match 'img src="\.\./img/logo\.png"') {
        $content = $content -replace 'img src="\.\./img/logo\.png".*?/?>', ''
        Set-Content -Path $file -Value $content -Encoding UTF8
        $changed = $true
    }

    # Inline colors
    $colorReplacements = @(
        @{ Old = "#FFCC00"; New = "#0F766E" },
        @{ Old = "#1E2024"; New = "#042F2E" }
    )
    foreach ($rep in $colorReplacements) {
        if (Replace-InFile -filePath $file -oldString $rep.Old -newString $rep.New) {
            $changed = $true
        }
    }

    if ($changed) {
        if ($file -like "*\article\*") {
            $articlePagesChanged++
        } else {
            $mainPagesChanged++
        }
    }
}

# Process CSS files
Get-ChildItem -Path . -Recurse -Filter *.css | ForEach-Object {
    $file = $_.FullName
    $changed = $false

    # Theme colors
    $cssReplacements = @(
        @{ Old = "--primary:.*?"; New = "--primary: #0F766E" },
        @{ Old = "--dark:.*?"; New = "--dark: #042F2E" },
        @{ Old = "--secondary:.*?"; New = "--secondary: #1F3F5F" }
    )
    foreach ($rep in $cssReplacements) {
        if (Replace-InFile -filePath $file -oldString $rep.Old -newString $rep.New) {
            $changed = $true
        }
    }

    if ($changed) {
        $cssChanged++
    }
}

# Update package.json
$packageFile = "package.json"
$content = Get-Content -Path $packageFile -Raw -Encoding UTF8
$content = $content -replace '"name":\s*"[^"]*"', '"name": "seputarjabar"'
Set-Content -Path $packageFile -Value $content -Encoding UTF8
$packageChanged++

# Update tools/package.json if exists
$toolsPackageFile = "tools/package.json"
if (Test-Path $toolsPackageFile) {
    $content = Get-Content -Path $toolsPackageFile -Raw -Encoding UTF8
    $content = $content -replace '"name":\s*"[^"]*"', '"name": "seputarjabar-article-generator"'
    Set-Content -Path $toolsPackageFile -Value $content -Encoding UTF8
    $packageChanged++
}

# Update docs
$docFiles = @("AUTOMATION_README.md", "GOOGLE_DRIVE_GUIDE.md", "netlify.toml")
foreach ($doc in $docFiles) {
    if (Test-Path $doc) {
        $changed = $false
        foreach ($rep in $replacements) {
            if (Replace-InFile -filePath $doc -oldString $rep.Old -newString $rep.New) {
                $changed = $true
            }
        }
        if ($changed) {
            $docsChanged++
        }
    }
}

# Verification
$verificationFailed = $false
$filesToCheck = Get-ChildItem -Path . -Recurse -Include *.html,*.css,*.md,*.json,*.toml
foreach ($file in $filesToCheck) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    if ($content -match "Arah Berita|arahberita|ArahBerita|logo\.png") {
        Write-Host "Verification failed: Found old string in $($file.FullName)"
        $verificationFailed = $true
    }
}

# Output
Write-Host "Rebrand Seputar Jabar selesai ✅"
Write-Host "Main pages changed: $mainPagesChanged"
Write-Host "Article pages changed: $articlePagesChanged"
Write-Host "CSS files changed: $cssChanged"
Write-Host "Package files changed: $packageChanged"
Write-Host "Docs changed: $docsChanged"
if ($verificationFailed) {
    Write-Host "Verification: FAILED - Some old strings still present"
} else {
    Write-Host "Verification: PASSED - No old strings found"
}