# serve.ps1 - a tiny web server for MiiNSCC on this computer only (http://localhost:8765).
# Start MiiNSCC.bat starts it; close its window to stop it. Nothing to install.
# Only this computer can reach it (it listens on "localhost"), and it only hands out files
# from this folder.
param([int]$Port = 8765)
$root = [System.IO.Path]::GetFullPath($PSScriptRoot).TrimEnd("\") + "\"
$types = @{ ".html"="text/html; charset=utf-8"; ".js"="text/javascript; charset=utf-8"; ".css"="text/css; charset=utf-8";
  ".json"="application/json"; ".png"="image/png"; ".jpg"="image/jpeg"; ".svg"="image/svg+xml"; ".glb"="model/gltf-binary";
  ".woff2"="font/woff2"; ".woff"="font/woff"; ".ogg"="audio/ogg"; ".mp3"="audio/mpeg"; ".stl"="model/stl"; ".ico"="image/x-icon" }
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
try { $listener.Start() } catch { Write-Host "MiiNSCC is already running at http://localhost:$Port/"; exit 0 }
$host.UI.RawUI.WindowTitle = "MiiNSCC server - close this window to stop it"
Write-Host "MiiNSCC is running at http://localhost:$Port/  (close this window to stop it)"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $res = $ctx.Response
  try {
    $rel = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart("/")
    if ($rel -eq "__nscc/folder") {
      # (for Settings: which folder this is, so it can show the update command)
      $bytes = [System.Text.Encoding]::UTF8.GetBytes((@{ folder = $root; os = "Windows" } | ConvertTo-Json -Compress))
      $res.ContentType = "application/json"
    } else {
      if ($rel -eq "") { $rel = "index.html" }
      $file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($root, $rel))
      if (-not $file.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -or -not [System.IO.File]::Exists($file) -or $rel -match '(^|/)\.') {
        $res.StatusCode = 404; $bytes = [System.Text.Encoding]::UTF8.GetBytes("Not found")
      } else {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $ext = [System.IO.Path]::GetExtension($file).ToLower()
        $res.ContentType = $(if ($types.ContainsKey($ext)) { $types[$ext] } else { "application/octet-stream" })
      }
    }
    $res.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate") # (always the newest files)
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
  } catch { } finally { $res.Close() }
}
