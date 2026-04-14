# Script untuk mengganti legacy brand image dengan text-based logo di semua HTML files

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Arah Berita"
$htmlFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" -File

$textBasedLogo = @"
<span style="font-weight: 700; color: #1D4ED8; font-size: 24px; letter-spacing: -0.5px;">ARAH<span style="color: #7F2F4F; font-weight: 500; font-size: 18px; margin-left: 2px;">BERITA</span></span>
"@

$replaceCount = 0

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        # Replace any legacy brand image inside navbar-brand with text-based logo
        $pattern1 = '<img[^>]*src="img\/[^"'']*logo\.(png|svg|jpg)"[^>]*>'
        $pattern2 = '<img[^>]*src="\.\.\/img\/[^"'']*logo\.(png|svg|jpg)"[^>]*>'
        
        $newContent = $content -replace $pattern1, $textBasedLogo
        $newContent = $newContent -replace $pattern2, $textBasedLogo
        
        if ($newContent -ne $content) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $replaceCount++
            Write-Host "Updated navbar brand in: $($file.Name)"
        }
    } catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Logo replacement complete!"
Write-Host "Total files updated: $replaceCount"
