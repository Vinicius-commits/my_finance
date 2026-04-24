# Nativo Windows
$nativo = (Measure-Command { Get-ChildItem 'h:\Backup Fedora\Projetos' -Recurse | Out-Null }).TotalMilliseconds

# Dart script
$dart = (Measure-Command { dart run lib/createdirectory.dart | Out-Null }).TotalMilliseconds

# Dart exe
$exe = (Measure-Command { .\viewdir.exe | Out-Null }).TotalMilliseconds

[pscustomobject]@{
  Método = 'Nativo | Dart Script | Dart Exe'
  TempoMs = "$nativo | $dart | $exe"
}


1..10 | ForEach-Object {
  [pscustomobject]@{
    Iter = $_
    Nativo = (Measure-Command { Get-ChildItem 'h:\Backup Fedora\Projetos' -Recurse | Out-Null }).TotalMilliseconds
    Dart = (Measure-Command { dart run lib/createdirectory.dart | Out-Null }).TotalMilliseconds
    Exe = (Measure-Command { .\viewdir.exe | Out-Null }).TotalMilliseconds
  }
} | Tee-Object -Variable Results | Format-Table -AutoSize

"== Estatísticas =="
$Results | Measure-Object -Property Nativo,Dart,Exe -Average,Min,Max | Format-Table -AutoSize