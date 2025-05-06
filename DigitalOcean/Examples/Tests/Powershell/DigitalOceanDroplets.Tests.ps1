Describe 'Digital Ocean Terraform Test' {
  Context 'Droplets Tests' {
    BeforeAll {
      Get-ChildItem C:\Temp\Terraform*.txt | Remove-Item -Force
      
      $TerraformPath = "C:\Users\Itamartz\Documents\GithubRepos\Terraform\DigitalOcean\Examples\Droplet"
      Set-Location $TerraformPath

    }
    <#    
        AfterAll {
        $TerraformCommand = "destroy"
        $Process = Start-Process -Wait -NoNewWindow -PassThru -FilePath 'terraform' -ArgumentList "$($TerraformCommand) -auto-approve -json" -RedirectStandardOutput "C:\Temp\Terraform$($TerraformCommand)Output.txt"
        }
    #>
    
    It "We in the currect path [$($TerraformPath)]"{
      (Get-Location).Path | Should be $TerraformPath
    }
    
    It "Terraform validate" {
      $TerraformCommand = "validate"
      $Process = Start-Process -Wait -NoNewWindow -PassThru -FilePath 'terraform' -ArgumentList "$($TerraformCommand) -no-color" -RedirectStandardOutput "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $TerraformCommandOutput = Get-Content -Path "C:\Temp\Terraform$($TerraformCommand)Output.txt" -Raw
      $TerraformCommandOutput.Contains('The configuration is valid') | Should be $true
    }
    
    It "Terraform init"{
      $TerraformCommand = "init"
      $Process = Start-Process -Wait -NoNewWindow -PassThru -FilePath 'terraform' -ArgumentList "$($TerraformCommand) -no-color" -RedirectStandardOutput "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $TerraformCommandOutput = Get-Content -Path "C:\Temp\Terraform$($TerraformCommand)Output.txt" -Raw
      $TerraformCommandOutput.Contains('Terraform has been successfully initialized!') | Should be $true
    }
    
    It "Terraform Plan"{
      $TerraformCommand = "plan"
      $Process = Start-Process -Wait -NoNewWindow -PassThru -FilePath 'terraform' -ArgumentList "$($TerraformCommand) -json" -RedirectStandardOutput "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $TerraformCommandOutput = Get-Content -Path "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $AllPlanObjects = $TerraformCommandOutput | Convertfrom-Json
      $change_summary = $AllPlanObjects | where {$_.Type -eq 'change_summary'}
      $change_summary.changes | Export-Clixml "C:\Temp\Terraform$($TerraformCommand)Clixml.xml"
      Test-Path "C:\Temp\Terraform$($TerraformCommand)Clixml.xml" | Should be $true  
    }
    
    It "Terraform apply"{
      $TerraformCommand = "apply"
      $Process = Start-Process -Wait -NoNewWindow -PassThru -FilePath 'terraform' -ArgumentList "$($TerraformCommand) -auto-approve -json" -RedirectStandardOutput "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $TerraformCommandOutput = Get-Content -Path "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $AllPlanObjects = $TerraformCommandOutput | Convertfrom-Json
      $change_summary = $AllPlanObjects | where {$_.Type -eq 'change_summary' -and $_.changes.operation -eq 'apply'}
      $DifferenceObject = $change_summary.changes            
      $Clixml = Import-Clixml "C:\Temp\TerraformplanClixml.xml"
      $CompareObject = Compare-Object -ReferenceObject $Clixml -DifferenceObject $DifferenceObject -IncludeEqual
      $CompareObject.SideIndicator -eq '==' | Should Be $true
    }
    
    It "Droplet should open port 8000" {
      
      $TerraformCommand = "output"
      $Process = Start-Process -Wait -NoNewWindow -PassThru -FilePath 'terraform' -ArgumentList "$($TerraformCommand) -no-color -json" -RedirectStandardOutput "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $TerraformCommandOutput = Get-Content -Path "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $AllOutputObjects = $TerraformCommandOutput | Convertfrom-Json
      
      $AllOutputsVaribles = $AllOutputObjects.psobject.Properties | where {$_.Name.StartsWith('digitalocean') }
      
      $ipv4_address = $AllOutputObjects.$($AllOutputsVaribles[0].Name).value.digitalocean_droplet.ipv4_address
      $maxAttempts = 100
      $attempt = 0
      $retry_wait_time_Seconds = 5 
      while ($attempt -lt $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "http://$($ipv4_address):8000"
            break  # Success, exit the loop
        } catch {
            $attempt++
            if ($attempt -ge $maxAttempts) {
                throw  # Rethrow the last error after max attempts
            }
            
            # Wait before retrying
            Start-Sleep -Seconds $retry_wait_time_Seconds
        }
      }
      $Response.StatusCode -eq 200 | should be $true
    }
    
    It "Terraform destroy" {
      $TerraformCommand = "destroy"
      $Process = Start-Process -Wait -NoNewWindow -PassThru -FilePath 'terraform' -ArgumentList "$($TerraformCommand) -auto-approve -json" -RedirectStandardOutput "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $TerraformCommandOutput = Get-Content -Path "C:\Temp\Terraform$($TerraformCommand)Output.txt"
      $AllPlanObjects = $TerraformCommandOutput | Convertfrom-Json
      $change_summary = $AllPlanObjects | where {$_.Type -eq 'change_summary' -and $_.changes.operation -eq 'destroy'}
      $ReferenceObject = $change_summary.changes
      $Clixml = Import-Clixml "C:\Temp\TerraformplanClixml.xml"
      
      $Clixml.add -eq $ReferenceObject.remove | Should Be $true
    }
  }
}