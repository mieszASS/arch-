# GlassArch: skladanie czesci ISO w Windows PowerShell 5.1 / PowerShell 7
$ErrorActionPreference = 'Stop'
$shaFiles = @(Get-ChildItem -LiteralPath . -File -Filter '*.iso.sha256')
if ($shaFiles.Count -ne 1) { throw 'Umiesc w tym folderze dokladnie jeden plik *.iso.sha256 pobrany z Releases.' }
$checksumFile = $shaFiles[0]
$isoName = $checksumFile.Name.Substring(0, $checksumFile.Name.Length - '.sha256'.Length)
$isoPath = Join-Path (Get-Location).Path $isoName
$parts = @(Get-ChildItem -LiteralPath . -File -Filter "$isoName.chunk-*" | Sort-Object Name)
if ($parts.Count -gt 0) {
    if ($parts[0].Name -notlike '*chunk-001') { throw 'Brak pierwszej czesci ISO (chunk-001).' }
    for ($i = 0; $i -lt $parts.Count; $i++) {
        $suffix = ('{0:D3}' -f ($i + 1))
        if (-not $parts[$i].Name.EndsWith("chunk-$suffix")) { throw "Brak czesci chunk-$suffix." }
    }
    if (Test-Path -LiteralPath $isoPath) { throw "Plik juz istnieje: $isoName. Usun go lub przenies przed scaleniem." }
    Write-Host "Scalam $($parts.Count) plikow w $isoName ..."
    $destination = [System.IO.File]::Create($isoPath)
    try {
        foreach ($part in $parts) {
            Write-Host "Dodaje: $($part.Name)"
            $source = [System.IO.File]::OpenRead($part.FullName)
            try { $source.CopyTo($destination) } finally { $source.Dispose() }
        }
    } finally { $destination.Dispose() }
} elseif (-not (Test-Path -LiteralPath $isoPath)) {
    throw "Brak plikow *.chunk-* oraz gotowego $isoName. Pobierz wszystkie czesci wydania."
}
$firstLine = (Get-Content -LiteralPath $checksumFile.FullName | Select-Object -First 1)
$expected = ($firstLine -split '\s+')[0].ToUpperInvariant()
$actual = (Get-FileHash -LiteralPath $isoPath -Algorithm SHA256).Hash.ToUpperInvariant()
if ($actual -ne $expected) { throw 'SUMA SHA256 SIE NIE ZGADZA. Nie nagrywaj tego ISO; sprawdz czesci.' }
Write-Host "GOTOWE: $isoPath" -ForegroundColor Green
Write-Host "SHA256 OK: $actual"
