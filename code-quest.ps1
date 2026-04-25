param (
    [string]$platform = "chrome"
)

# Supabase Config
$SUPABASE_URL = "https://rbqnbwklgwenqcfnqwes.supabase.co/"
$SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8"

Clear-Host
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host "CODE QUEST by Ninskie: STARTING UP" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host "Adventure awaits on: $platform" -ForegroundColor Cyan
Write-Host ""

if ($platform -eq "mobile") {
    flutter run --dart-define=SUPABASE_URL="$SUPABASE_URL" --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
} else {
    flutter run -d $platform --web-port 8888 --dart-define=SUPABASE_URL="$SUPABASE_URL" --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
}
