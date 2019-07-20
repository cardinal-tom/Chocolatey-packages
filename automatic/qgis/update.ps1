import-module au

$DownloadURI = 'https://www.qgis.org/en/site/forusers/download.html'

function global:au_GetLatest {
   $download_page = Invoke-WebRequest -Uri $DownloadURI

   $null = $download_page.content.split("`n") | Where-Object {$_ -cmatch 'current version is QGIS ([0-9.]*)'}
   
   $NewVersion = $Matches[1]

   $url32 = $download_page.Links | 
              Where-Object {$_.href -match "$NewVersion.*x86\.exe`$"} | 
              Select-Object -ExpandProperty href
   $url64 = $download_page.Links | 
              Where-Object {$_.href -match "$NewVersion.*64\.exe`$"} | 
              Select-Object -ExpandProperty href

   $LTRversion = ($download_page.Links | 
                    Where-Object {
                       ($_.href -match "QGIS.*x86\.exe`$") -and 
                       ($_.href -notmatch "$newversion")
                    } | Select-Object -ExpandProperty href
                 ) -replace ".*?-([0-9.]+)-.*",'$1'

   return @{ 
      Version    = $NewVersion
      LTRVersion = $LTRversion
      URL32      = $url32
      URL64      = $url64
   }
}


function global:au_SearchReplace {
   @{
      "tools\chocolateyInstall.ps1" = @{
         "(^[$]LTRversion = )('.*')"     = "`$1'$($Latest.LTRversion)'"
         "(^   url\s*=\s*)('.*')"        = "`$1'$($Latest.URL32)'"
         "(^   url64bit\s*=\s*)('.*')"   = "`$1'$($Latest.URL64)'"
         "(^   Checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum32)'"
         "(^   Checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
      }
   }
}

Update-Package -NoCheckUrl