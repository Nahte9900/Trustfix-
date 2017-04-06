#TrustFix
#Ethan Caren (NEFEC) and Garrett Crosby (Union County)


#Variables. Change these to suit your environment.
#path to local folder
$path = "C:\trustfix\"
#Name of Powershellx86 and x64 files
$psx86 = "Windows6.1-KB2819745-x86-MultiPkg.msu"
$psx64 = "Windows6.1-KB2819745-x64-MultiPkg.msu"
#Service domain\username and password
$user = "BCSD\TrustFix"
$pass = "FixThatJunk!"
#Name of Install Group and TrustFix Group
$installgrp = "InstallPS"
$trustfixgrp = "FixTrust"
#name of check file and content.
$file = "pie.txt"
$content = "All your base are belong to us!"

function group_move {  
       
        #Add the computer to the FixTrust group in AD
        & net group $trustfixgrp $env:computername$ /add /domain
         #Remove the computer from the InstallPS3 group in AD                      
        & net group $installgrp $env:computername$ /delete /domain 
        #Call create_pie function to create pie.txt
            create_pie  
    }


function create_pie {
        #Create pie.txt file to indicate PS3 or above is installed.
        New-Item -path $path -Name $file -Value $content -ItemType file -force
     }


function install_ps3 {
    #Check if PS version is less than 3
             if ($PSVersionTable.PSVersion.Major -lt 3)
        {
                #check if OS is 32 bit
                 if ([System.IntPtr]::Size -eq 4) 
                {
                    # Path to 32 bit version of PS3. This is path to 32 bit PS4
                    wusa.exe "$path$psx86" /quiet /norestart
                }
                else #if OS not 32 bit, install 64 bit version
                {
                    # Path to 64 bit version of PS3. This is path to 64 bit PS4
                    wusa.exe "$path$psx64" /quiet /norestart          
                       }
                }
    else {
        group_move
        }
    }


function trustfix {
     #Test the Trust Relationship. Repair if broken
             $username = “$user”
             $password = “$pass” | convertto-securestring -asPlainText -Force
             $credentials = new-object -typename System.Management.Automation.PSCredential ($username,$password)
             Test-ComputerSecureChannel -repair -Credential $credentials
    }

function check_group_membership {
              $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
              $objSearcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry
              $objSearcher.Filter = "(&(objectCategory=Computer)(SamAccountname=$($env:COMPUTERNAME)`$))"
              $objSearcher.SearchScope = "Subtree"
              $obj = $objSearcher.FindOne()
              $Computer = $obj.Properties["distinguishedname"]
              $objSearcher.Filter = "(&(objectCategory=group)(SamAccountname=$installgrp))"
              $objSearcher.SearchScope = "Subtree"
              $obj = $objSearcher.FindOne()
              [String[]]$Members = $obj.Properties["member"]
        If ($Members -contains $Computer)
    { 
              #Remove the computer from the InstallPS3 group in AD                      
              & net group $installgrp $env:computername$ /delete /domain
              trustfix
    }
       Else
    { 
              trustfix
    }
                                }

function eat_pie {
            #The script starts here. Look for pie.txt, if exists, run trustfix, if not, test for PS3
    $pie = test-path ("$path$file")

    if ($pie -eq $true) {
                          check_group_membership
                                    }
    else {
          install_ps3
                       }
    }
     
#It starts with eating pie. This is the main function
eat_pie
