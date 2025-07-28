# Full path to mkvmerge.exe
$MKVMERGE = "C:\Program Files\MKVToolNix\mkvmerge.exe"

# Verify mkvmerge exists
if (-not (Test-Path $MKVMERGE)) {
    Write-Host "Error: mkvmerge.exe not found at: $MKVMERGE" -ForegroundColor Red
    Write-Host "Please verify MKVToolNix is installed at the specified path." -ForegroundColor Yellow
    exit 1
}

# Root directory to scan
$RootFolder = "\\adam-nas\Media\Labeled\TV Shows\The Office {tmdb-2316}\Season 1"

Write-Host "Starting PGS subtitle scan..." -ForegroundColor Green
Write-Host "Root folder: $RootFolder" -ForegroundColor Cyan
Write-Host "Using mkvmerge: $MKVMERGE" -ForegroundColor Cyan
Write-Host "" # Empty line for spacing

# Find all MKV (and optionally MP4) files
Write-Host "Scanning for video files..." -ForegroundColor Yellow
$VideoFiles = Get-ChildItem -Path $RootFolder -Recurse -Include *.mkv,*.mp4 -File
Write-Host "Found $($VideoFiles.Count) video files to process" -ForegroundColor Green
Write-Host ""

# Track matches
$FilesWithPGS = @()
$ProcessedCount = 0
$SkippedCount = 0

Write-Host "Beginning file analysis..." -ForegroundColor Magenta
Write-Host "" # Empty line for spacing

foreach ($File in $VideoFiles) {
    $ProcessedCount++
    Write-Host "[$ProcessedCount/$($VideoFiles.Count)]" -NoNewline -ForegroundColor DarkGray
    if ($File.Extension -ieq ".mp4") {
        $SkippedCount++
        Write-Host " Skipping MP4 (PGS not supported): $($File.FullName)" -ForegroundColor DarkGray
        continue
    }

    Write-Host " Checking: $($File.FullName)"
    
    # Run mkvmerge and capture output
    Write-Host "   Running mkvmerge analysis..." -ForegroundColor DarkCyan
    try {
        $output = & $MKVMERGE -i "$($File.FullName)" 2>&1
        Write-Host "   mkvmerge completed successfully" -ForegroundColor DarkGreen
    }
    catch {
        Write-Host "   Error running mkvmerge: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }

    # Look for subtitle lines containing "PGS"
    Write-Host "   Analyzing output for PGS subtitles..." -ForegroundColor DarkYellow
    if ($output -match "subtitles.*PGS") {
        Write-Host "   PGS FOUND!" -ForegroundColor Yellow -BackgroundColor DarkRed
        Write-Host "   Adding to results: $($File.FullName)" -ForegroundColor Yellow
        $FilesWithPGS += $File.FullName
    } else {
        Write-Host "   No PGS subtitles detected" -ForegroundColor DarkGreen
    }
    Write-Host "" # Empty line for spacing
}

Write-Host "SCAN STATISTICS:" -ForegroundColor Magenta
Write-Host "   Total files processed: $ProcessedCount" -ForegroundColor Cyan
Write-Host "   MP4 files skipped: $SkippedCount" -ForegroundColor Cyan
Write-Host "   MKV files analyzed: $($ProcessedCount - $SkippedCount)" -ForegroundColor Cyan
$PGSColor = if ($FilesWithPGS.Count -gt 0) { 'Yellow' } else { 'Green' }
Write-Host "   PGS files found: $($FilesWithPGS.Count)" -ForegroundColor $PGSColor

Write-Host "`n=================================="
Write-Host "FILES WITH PGS SUBTITLES:" -ForegroundColor Yellow
Write-Host "=================================="
if ($FilesWithPGS.Count -gt 0) {
    $FilesWithPGS | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
} else {
    Write-Host "   No files with PGS subtitles found!" -ForegroundColor Green
}

Write-Host "`nScan complete!" -ForegroundColor Green
$FinalColor = if ($FilesWithPGS.Count -gt 0) { 'Yellow' } else { 'Green' }
Write-Host "   Total PGS files found: $($FilesWithPGS.Count)" -ForegroundColor $FinalColor
