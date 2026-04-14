$file = "contact.html"
$content = Get-Content -Path $file -Raw -Encoding UTF8
$content = $content -replace "(?i)arah berita", "Seputar Jabar"
Set-Content -Path $file -Value $content -Encoding UTF8
Write-Host "Done"