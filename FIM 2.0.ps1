Write-Host "FIM running..."
#Write-Host "Hello, Choose from below options: "
#Write-Host ""
#Write-Host "   A.  Collect new baseline"
#Write-Host "   B.  Monitor files with saved baseline"

#$response = Read-Host -Prompt " Enter 'A' or 'B'"

Write-Host ""
Write-Host "Enter Email-Id to send notifications to: "
$To = Read-Host -Prompt "Enter E-Mail ID "

Function SendMailCreated($c){

if($c -eq 1)
{
    # send email alert

    $MyEmail = “ENTER-EMAIL-ID”
    
    $Subject = “ALERT: UNKNOWN NEW FILE CREATED”
    $Body = “An unknown and new file has been created in the folder”
    $password = ConvertTo-SecureString "ENTER-YOUR-PASSWORD" -AsPlainText -Force
    $Creds = $mycreds = New-Object System.Management.Automation.PSCredential($MyEmail, $password)
    $SMTP= “smtp.gmail.com”
Start-Sleep 1
Send-MailMessage -To $to -From $MyEmail -Subject $Subject -Body $Body -SmtpServer $SMTP -Credential $Creds -UseSsl -Port 587
}

}
Function SendMailTampered($t){

      if($t -eq 2){
      
    # send email alert

    $MyEmail = “ENTER-EMAIL-ID”
    
    $Subject = “ALERT: FILE TAMPERED”
    $Body = “A file has been tampared with in the folder”
    $password = ConvertTo-SecureString "ENTER-YOUR-PASSWORD" -AsPlainText -Force
    $Creds = $mycreds = New-Object System.Management.Automation.PSCredential($MyEmail, $password)
    $SMTP= “smtp.gmail.com”
Start-Sleep 1
Send-MailMessage -To $to -From $MyEmail -Subject $Subject -Body $Body -SmtpServer $SMTP -Credential $Creds -UseSsl -Port 587
}

}
Function SendMailDeleted($d){

      if($d -eq 3)
      {
    # send email alert

    $MyEmail = “ENTER-EMAIL-ID”
    
    $Subject = “ALERT: FILE DELETED”
    $Body = “A file has been deleted from the folder"
    $password = ConvertTo-SecureString "ENTER-YOUR-PASSWORD" -AsPlainText -Force
    $Creds = $mycreds = New-Object System.Management.Automation.PSCredential($MyEmail, $password)
    $SMTP= “smtp.gmail.com”
Start-Sleep 1
Send-MailMessage -To $to -From $MyEmail -Subject $Subject -Body $Body -SmtpServer $SMTP -Credential $Creds -UseSsl -Port 587
}

}

Function Calculate-File-Hash($filepath)
{
 $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
 return $filehash
}


Function Erase-Baseline-If-Already-Exists()
{
 $baselineExists = Test-Path -Path .\baseline.txt

 if ($baselineExists)
 {
  Remove-Item -Path .\baseline.txt
 }
}

#if ($response -eq "A".ToUpper()){
 # deleting baseline if it already exists

 Erase-Baseline-If-Already-Exists
 #calculate hash from file and store in baseline.txt
 # Write-Host "Calculate hashes, create baseline.txt" -ForegroundColor Yellow

 # collect all files in target folder
 $files = Get-ChildItem -Path .\files
 


 # for file, calculate the hash and write to baseline.txt

 foreach($f in $files)
 {
  $hash = Calculate-File-Hash $f.FullName 
  "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
 }


#}
#elseif ($response -eq "B".ToUpper()){
   $fileHashDictionary =@{}
  # load file and hash from baseline.txt and store them in a dictionary
  $filePathsAndHashes = Get-Content -Path .\baseline.txt  

  foreach ($f in $filePathsAndHashes)
  {
    $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    
  }

  $fileHashDictionary.Values

  # begin continuously monitoring files with saved baseline


 do
  {
  $created=0
  $deleted=0
  $tampered=0

  
  Start-Sleep -Seconds 1
  
  $files = Get-ChildItem -Path .\files

 # for file, calculate the hash and write to baseline.txt

 foreach($f in $files)
 {
  $hash = Calculate-File-Hash $f.FullName 
  # "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append


  #Notify if a new file has been created
  if ($fileHashDictionary[$hash.Path] -eq $null)
  { 
   #a new file has been created.
    Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
    $created=1
  }

  else{

  #Notify if file has been changed
  if($fileHashDictionary[$hash.Path] -eq $hash.Hash)
  {
   #file not changed
  }

  else {
    #file has been tampered. notify user
     Write-Host "$($hash.Path) has been tampered!" -ForegroundColor Yellow
     $tampered=2
   }

}

foreach ($key in $fileHashDictionary.Keys)
{
 $baselineFileStillExists = Test-Path -Path $key
 if (-Not $baselineFileStillExists){
 # some file has been deleted due to its missing baseline, notify user
 Write-Host "$($key) has been deleted!" -ForegroundColor Red
 $deleted=3
 }
 
}

 }
 
 SendMailCreated($created)
 SendMailTampered($tampered)
 SendMailDeleted($deleted)
 Start-Sleep -Seconds 10
  }while($true)

  # $fileHashDictionary.Values
  # $fileHashDictionary["path"]


#}



