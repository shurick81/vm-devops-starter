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

# Single-machine environment

## Creating

PowerShell
`cd` to `images` directory and run `.\preparevmimages.ps1 win2016-ad-dbrs-dynamics-code`
`cd` to `stacks/dev-addbrsdynamicscode` directory.

If PowerShell scripts are allowed on the machine, run `..\localdeploy.ps1`. Otherwise run `vagrant up`.

Run `vagrant rdp ADDBDYN01` or RDP to `127.0.0.1:13390`

account: `contoso\_crmadmin`

pass: `c0mp1Expa~~`

## Resetting

```
vagrant destroy ADDBDYN01 --force
vagrant up
```

## Cleaning up
`cd` to `stacks/dev-addbrsdynamicscode` directory and run `vagrant destroy --force`
`cd` to `images` directory and run `removevmimages.ps1 win2016-ad-dbrs-dynamics-code`

Consider also removing downloaded ISO files:

`rm images/packer_cache/*`

# A stack with a separate domain controller

## Creating

PowerShell
`cd` to `images` directory and run `.\preparevmimages.ps1 win2016-ad, win2016-dbrs-dynamics-code`
`cd` to `stacks/dev-ad-dbrsdynamicscode` directory.

If PowerShell scripts are allowed on the machine, run `..\localdeploy.ps1`. Otherwise run `vagrant up`.

Run `vagrant rdp DBDYN01` or RDP to `127.0.0.1:13391`

account: `contoso\_crmadmin`

pass: `c0mp1Expa~~`

## Resetting

```
vagrant destroy ADDBDYN01 --force
vagrant up
```

## Cleaning up
`cd` to `stacks/dev-ad-dbrsdynamicscode` directory and run `vagrant destroy --force`
`cd` to `images` directory and run `removevmimages.ps1 win2016-ad, win2016-dbrs-dynamics-code`

Consider also removing downloaded ISO files:

`rm images/packer_cache/*`
