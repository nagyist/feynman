param(
  [string]$Version = "edge",
  [ValidateSet("User", "Repo")]
  [string]$Scope = "User",
  [string]$TargetDir = ""
)

$ErrorActionPreference = "Stop"

function Normalize-Version {
  param([string]$RequestedVersion)

  if (-not $RequestedVersion) {
    return "edge"
  }

  switch ($RequestedVersion.ToLowerInvariant()) {
    "edge" { return "edge" }
    "latest" { return "latest" }
    "stable" { return "latest" }
    default { return $RequestedVersion.TrimStart("v") }
  }
}

function Resolve-VersionMetadata {
  param([string]$RequestedVersion)

  $normalizedVersion = Normalize-Version -RequestedVersion $RequestedVersion

  if ($normalizedVersion -eq "edge") {
    return [PSCustomObject]@{
      ResolvedVersion = "edge"
      GitRef = "main"
      DownloadUrl = "https://github.com/getcompanion-ai/feynman/archive/refs/heads/main.zip"
    }
  }

  if ($normalizedVersion -eq "latest") {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/getcompanion-ai/feynman/releases/latest"
    if (-not $release.tag_name) {
      throw "Failed to resolve the latest Feynman release version."
    }

    $resolvedVersion = $release.tag_name.TrimStart("v")
  } else {
    $resolvedVersion = $normalizedVersion
  }

  return [PSCustomObject]@{
    ResolvedVersion = $resolvedVersion
    GitRef = "v$resolvedVersion"
    DownloadUrl = "https://github.com/getcompanion-ai/feynman/archive/refs/tags/v$resolvedVersion.zip"
  }
}

function Resolve-InstallDir {
  param(
    [string]$ResolvedScope,
    [string]$ResolvedTargetDir
  )

  if ($ResolvedTargetDir) {
    return $ResolvedTargetDir
  }

  if ($ResolvedScope -eq "Repo") {
    return Join-Path (Get-Location) ".agents\skills\feynman"
  }

  $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
  return Join-Path $codexHome "skills\feynman"
}

$metadata = Resolve-VersionMetadata -RequestedVersion $Version
$resolvedVersion = $metadata.ResolvedVersion
$downloadUrl = $metadata.DownloadUrl
$installDir = Resolve-InstallDir -ResolvedScope $Scope -ResolvedTargetDir $TargetDir

$tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("feynman-skills-install-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmpDir | Out-Null

try {
  $archivePath = Join-Path $tmpDir "feynman-skills.zip"
  $extractDir = Join-Path $tmpDir "extract"

  Write-Host "==> Downloading Feynman skills $resolvedVersion"
  Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath

  Write-Host "==> Extracting skills"
  Expand-Archive -LiteralPath $archivePath -DestinationPath $extractDir -Force

  $sourceRoot = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1
  if (-not $sourceRoot) {
    throw "Could not find extracted Feynman archive."
  }

  $skillsSource = Join-Path $sourceRoot.FullName "skills"
  if (-not (Test-Path $skillsSource)) {
    throw "Could not find skills/ in downloaded archive."
  }

  $installParent = Split-Path $installDir -Parent
  if ($installParent) {
    New-Item -ItemType Directory -Path $installParent -Force | Out-Null
  }

  if (Test-Path $installDir) {
    Remove-Item -Recurse -Force $installDir
  }

  New-Item -ItemType Directory -Path $installDir -Force | Out-Null
  Copy-Item -Path (Join-Path $skillsSource "*") -Destination $installDir -Recurse -Force

  Write-Host "==> Installed skills to $installDir"
  if ($Scope -eq "Repo") {
    Write-Host "Repo-local skills will be discovered automatically from .agents/skills."
  } else {
    Write-Host "User-level skills will be discovered from `$CODEX_HOME/skills."
  }

  Write-Host "Feynman skills $resolvedVersion installed successfully."
} finally {
  if (Test-Path $tmpDir) {
    Remove-Item -Recurse -Force $tmpDir
  }
}
