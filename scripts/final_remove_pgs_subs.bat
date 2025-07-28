@echo off
setlocal enabledelayedexpansion

:: Path to mkvmerge using 8.3 format (for space safety)
set "MKVMERGE=C:\PROGRA~1\MKVToolNix\mkvmerge.exe"

:: Root folder to scan
set "ROOT=\\adam-nas\Media\Labeled\TV Shows\The Office {tmdb-2316}\Season 1"

echo ======================================================
echo === Scanning MKV files in: %ROOT%
echo ======================================================

:: Recursively find all .mkv files
for /r "%ROOT%" %%F in (*.mkv) do (
    echo.
    echo === Processing: %%F
    set "INPUT=%%F"
    set "CLEANED=%%~dpnF_cleaned.mkv"
    set "TEXT_TRACK_IDS="

    :: Get subtitle track info
    for /f "delims=" %%L in ('%MKVMERGE% -i "%%F"') do (
        set "LINE=%%L"
        echo !LINE! | findstr /i "subtitles" >nul
        if !errorlevel! == 0 (
            set "TRACK_LINE=!LINE!"
            set "TRACK_ID="

            :: Extract clean track ID (strip colon)
            for /f "tokens=3 delims=: " %%a in ("!TRACK_LINE!") do (
                set "TRACK_ID=%%a"
            )

            :: Check if subtitle format is valid text
            echo !TRACK_LINE! | findstr /i "SRT UTF-8 ASS SSA" >nul
            if !errorlevel! == 0 (
                echo   -> Keeping text subtitle: !TRACK_LINE!
                set "TEXT_TRACK_IDS=!TEXT_TRACK_IDS!,!TRACK_ID!"
            ) else (
                echo   -> Skipping image-based subtitle: !TRACK_LINE!
            )
        )
    )

    :: Trim leading comma
    if defined TEXT_TRACK_IDS (
        set "TEXT_TRACK_IDS=!TEXT_TRACK_IDS:,=!"
        echo   -> Subtitle track IDs to keep: !TEXT_TRACK_IDS!
        %MKVMERGE% -o "!CLEANED!" --subtitle-tracks !TEXT_TRACK_IDS! "%%F"
    ) else (
        echo   -> No text-based subtitles found. Copying without subtitles.
        %MKVMERGE% -o "!CLEANED!" --no-subtitles "%%F"
    )

    :: Overwrite original if cleaned file exists
    if exist "!CLEANED!" (
        del "%%F"
        ren "!CLEANED!" "%%~nxF"
        echo ✅ Replaced original with cleaned file: %%F
    ) else (
        echo ❌ ERROR: Cleaned file not created. Skipping overwrite.
    )
)

echo.
echo ✅ All done cleaning PGS subs.
pause
