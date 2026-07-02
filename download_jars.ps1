$dir = Join-Path $PSScriptRoot "build\media_kit_libs_android_video\v1.1.5"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir }

$files = @(
    @{ Name="default-arm64-v8a.jar"; Hash="5f521b08692d7fef73c5df9bcc00ca4d" },
    @{ Name="default-armeabi-v7a.jar"; Hash="08d500ca1116c13e9c1296cc6f2207b0" },
    @{ Name="default-x86_64.jar"; Hash="0880d5fbc3ff0053409704617f54cb55" },
    @{ Name="default-x86.jar"; Hash="f6f51aa42b30d747099506cdc3277352" }
)

$mirrors = @(
    "https://ghproxy.net/https://github.com/media-kit/libmpv-android-video-build/releases/download/v1.1.5/",
    "https://gh-proxy.com/https://github.com/media-kit/libmpv-android-video-build/releases/download/v1.1.5/",
    "https://mirror.ghproxy.com/https://github.com/media-kit/libmpv-android-video-build/releases/download/v1.1.5/",
    "https://kkgithub.com/media-kit/libmpv-android-video-build/releases/download/v1.1.5/"
)

foreach ($f in $files) {
    $dest = Join-Path $dir $f.Name
    $success = $false
    
    if (Test-Path $dest) {
        $hash = (Get-FileHash $dest -Algorithm MD5).Hash.ToLower()
        if ($hash -eq $f.Hash) {
            Write-Host "$($f.Name) is already valid."
            $success = $true
        } else {
            Remove-Item $dest -Force
        }
    }

    foreach ($mirror in $mirrors) {
        if ($success) { break }
        $url = $mirror + $f.Name
        Write-Host "Trying $url"
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -TimeoutSec 60
            $hash = (Get-FileHash $dest -Algorithm MD5).Hash.ToLower()
            if ($hash -eq $f.Hash) {
                Write-Host "$($f.Name) downloaded successfully!"
                $success = $true
            } else {
                Write-Host "Hash mismatch for $($f.Name)."
                Remove-Item $dest -Force
            }
        } catch {
            Write-Host "Failed to download $($f.Name) from $mirror"
        }
    }
}
