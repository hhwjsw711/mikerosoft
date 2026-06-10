# remove-portrait/deps.ps1
# Checks Python packages used for local video background removal.
# CPU-only config for Intel Iris Xe (no NVIDIA).

Write-Host "  [remove-portrait] Checking dependencies..." -ForegroundColor Cyan

$repoRoot = Resolve-Path "$PSScriptRoot\..\.."
$toolsDir = Resolve-Path "$repoRoot\..\..\tools"

$packages = @(
    @{ Import = "rembg"; Pip = "rembg" },
    @{ Import = "cv2"; Pip = "opencv-python" },
    @{ Import = "PIL"; Pip = "pillow" },
    @{ Import = "torch"; Pip = "torch" },
    @{ Import = "onnxruntime"; Pip = "onnxruntime" }
)

foreach ($package in $packages) {
    $ok = python -c "import $($package.Import); print('ok')" 2>$null
    if ($ok -eq "ok") {
        Write-Host "    OK  $($package.Import)" -ForegroundColor Green
        continue
    }

    Write-Host "    Installing $($package.Pip) via pip..." -ForegroundColor Yellow
    pip install $package.Pip
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ERROR: Failed to install $($package.Pip)" -ForegroundColor Red
    }
}

if (Test-Path "$toolsDir\ffmpeg.exe") {
    Write-Host "    OK  ffmpeg.exe found in $toolsDir" -ForegroundColor Green
} elseif (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
    Write-Host "    OK  ffmpeg found on PATH" -ForegroundColor Green
} else {
    Write-Host "    WARN ffmpeg.exe not found. Put it in $toolsDir or on PATH." -ForegroundColor Yellow
}

$modelDir = "$toolsDir\_models\remove-portrait"
$rvmRepo = Join-Path $modelDir "RobustVideoMatting"
$rvmWeights = Join-Path $modelDir "rvm_mobilenetv3.pth"
New-Item -ItemType Directory -Force -Path $modelDir | Out-Null

if (Test-Path $rvmRepo) {
    Write-Host "    OK  RobustVideoMatting repo found" -ForegroundColor Green
} elseif (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "    Cloning RobustVideoMatting..." -ForegroundColor Yellow
    git clone --depth 1 https://github.com/PeterL1n/RobustVideoMatting.git $rvmRepo
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    OK  RobustVideoMatting cloned" -ForegroundColor Green
    } else {
        Write-Host "    ERROR: Failed to clone RobustVideoMatting" -ForegroundColor Red
    }
} else {
    Write-Host "    WARN git not found; cannot clone RobustVideoMatting" -ForegroundColor Yellow
}

if (Test-Path $rvmWeights) {
    Write-Host "    OK  RVM MobileNetv3 weights found" -ForegroundColor Green
} else {
    Write-Host "    Downloading RVM MobileNetv3 weights..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/PeterL1n/RobustVideoMatting/releases/download/v1.0.0/rvm_mobilenetv3.pth" -OutFile $rvmWeights
    if (Test-Path $rvmWeights) {
        Write-Host "    OK  RVM weights downloaded" -ForegroundColor Green
    } else {
        Write-Host "    ERROR: Failed to download RVM weights" -ForegroundColor Red
    }
}
