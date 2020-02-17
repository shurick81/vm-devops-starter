# Requirements
* Hardware
  * 12GB free RAM
  * 150GB free disk space
* Software
  * Vagrant
  * Vagrant reload
  * Packer
  * Oracle VirtualBox or Hyper-V or Azure Subscription

Run in PowerShell:
```PowerShell
Set-ExecutionPolicy Bypass -Force;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y packer
choco install -y vagrant --version 2.2.7
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

### Azure prerequisites

The only virtualization provider currenlty supported by this project is Azure, so before using this tool, please install necessary components and set variables.

#### Vagrant Azure Provider

In order to install this plugin with the necessary fixes, run

```
vagrant plugin install vagrant-azure
Rename-Item -Path $env:USERPROFILE\.vagrant.d\gems\2.4.4\gems\vagrant-azure-2.2.7 -NewName "vagrant-azure-2.2.7 - Copy";
git clone https://github.com/shurick81/vagrant-azure $env:USERPROFILE\.vagrant.d\gems\2.4.4\gems\vagrant-azure-2.2.7;
```

#### Environmental variables

1. Create application and assign proper roles for managing Azure resources
2. Set values for following environment variables:
* ARM_CLIENT_ID
* ARM_CLIENT_SECRET
* ARM_SUBSCRIPTION_ID
* ARM_TENANT_ID

Use https://www.packer.io/docs/builders/azure-setup.html or https://github.com/Azure/vagrant-azure as a baseline.

# Single-machine environment

## Creating

PowerShell:
`cd` to `images` directory and run `.\preparevmimages.ps1 win2016-ad-dbrs-dynamicssve-code`

In `stacks/dev-addbrsdynamicscode/vagrantfile`, uncomment one provisioning depending on what Dynamics configuration you need to be provisioned:
- dynamicsprovision.ps1 - Installing English Dynamics and provisioning English organization
- dynamicsprovisionsve.ps1 - Installing Swedish Dynamics and provisioning Swedish organization
- dynamicsprovisionsvelp.ps1 - Installing English Dynamics, provisioning English organization, Installing Reporting Extensions, Installing Swedish language pack, provisioning Swedish organization
- dynamicsprovision8.ps1 - Installing English Dynamics 8.2.3 and provisioning English organization
- dynamicsprovisionsve8.ps1 - Installing Swedish Dynamics 8.2.3 and provisioning Swedish organization
- dynamicsprovisionsvelp8.ps1 - Installing English Dynamics 8.2.3, provisioning English organization, Installing Reporting Extensions, Installing Swedish language pack, provisioning Swedish organization

`cd` to `stacks/dev-addbrsdynamicscode` directory.

If PowerShell scripts are allowed on the machine, run `..\localdeploy.ps1`. Otherwise run `vagrant up`.

Run `vagrant rdp ADDBDYN01` or RDP to `127.0.0.1:13390`

account: `contos00\_crmadmin`

pass: `c0mp1Expa~~`

## Resetting

```
vagrant destroy ADDBDYN01 --force
vagrant up
```

## Cleaning up

`cd` to `stacks/dev-addbrsdynamicscode` directory and run `vagrant destroy --force`
`cd` to `images` directory and run `removevmimages.ps1 win2016-ad-dbrs-dynamicssve-code`

Consider also removing downloaded ISO files:

`rm images/packer_cache/*`

# A stack with a separate domain controller

## Creating

PowerShell
`cd` to `images` directory and run `.\preparevmimages.ps1 win2016-ad, win2016-dbrs-dynamicssve-code`

In `stacks/dev-ad-dbrsdynamicssvecode/vagrantfile`, uncomment one provisioning depending on what Dynamics configuration you need to be provisioned:
- dynamicsprovision.ps1 - Installing English Dynamics and provisioning English organization
- dynamicsprovisionsve.ps1 - Installing Swedish Dynamics and provisioning Swedish organization
- dynamicsprovisionsvelp.ps1 - Installing English Dynamics, provisioning English organization, Installing Reporting Extensions, Installing Swedish language pack, provisioning Swedish organization
- dynamicsprovision8.ps1 - Installing English Dynamics 8.2.3 and provisioning English organization
- dynamicsprovisionsve8.ps1 - Installing Swedish Dynamics 8.2.3 and provisioning Swedish organization
- dynamicsprovisionsvelp8.ps1 - Installing English Dynamics 8.2.3, provisioning English organization, Installing Reporting Extensions, Installing Swedish language pack, provisioning Swedish organization

`cd` to `stacks/dev-ad-dbrsdynamicssvecode` directory.

If PowerShell scripts are allowed on the machine, run `..\localdeploy.ps1`. Otherwise run `vagrant up`.

Run `vagrant rdp DBDYN01` or RDP to `127.0.0.1:13391`

account: `contos00\_crmadmin`

pass: `c0mp1Expa~~`

## Resetting

```
vagrant destroy ADDBDYN01 --force
vagrant up
```

## Cleaning up
`cd` to `stacks/dev-ad-dbrsdynamicssvecode` directory and run `vagrant destroy --force`
`cd` to `images` directory and run `removevmimages.ps1 win2016-ad, win2016-ad-dbrs-dynamicssve-code`

Consider also removing downloaded ISO files:

`rm images/packer_cache/*`
