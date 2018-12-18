# Requirements
* Hardware
  * 12GB free RAM
  * 150GB free disk space
* Software
  * Vagrant
  * Vagrant reload
  * Packer
  * Oracle VirtualBox

Run in PowerShell:
```PowerShell
Set-ExecutionPolicy Bypass -Force;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y packer
choco install -y vagrant --version 2.2.0
```
Then reboot for finishing insalling Vagrant and continue with the following snippet:
```PowerShell
vagrant plugin install vagrant-reload
```

### Removing Hyper-V
```
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

### Installing VirtualBox on Windows
```
choco install -y virtualbox
```

# Creating a development environment

## PowerShell
`cd` to `images` directory and run `.\preparevmimages.ps1 win2016-ad,win2016-sql2016dbrs-dynamics-code`
`cd` to `stacks/dev-ad-sql2016dbrsdynamics90code` directory

If PowerShell scripts are allowed on the machine, run `..\localdeploy.ps1`. Otherwise run `vagrant up`.

Run `vagrant rdp DBDYN01` or RDP to `127.0.0.1:13391`
account: `sosalarm\_crmadmin`
pass: `c0mp1Expa~~`

## Resetting SQL and SP machine

```
vagrant destroy DBDYN01 --force
vagrant up
```

`vagrant rdp DBDYN01`
account: `sosalarm\_crmadmin`
pass: `c0mp1Expa~~`

# Cleaning up
`cd` to stack directory and run `vagrant destroy --force`
`cd` to `images` directory and run `removevmimages.ps1 win2016-ad,win2016-sql2016dbrs-dynamics-code`

Consider also removing downloaded ISO files:

`rm images/packer_cache/*`