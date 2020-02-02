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
choco install -y vagrant --version 2.2.3
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

PowerShell:
`cd` to `images` directory and run `.\preparevmimages.ps1 win2016-ad, win2016-dbrs-dynamicssve-code, win2012r2-db-sp2013-code`

In `stacks/dev-ad-dbrsdynamicssvecode-dbsp2013code`, uncomment one provisioning depending on what Dynamics configuration you need to be provisioned:
- dynamicsprovision.ps1 - Installing English Dynamics and provisioning English organization
- dynamicsprovisionsve.ps1 - Installing Swedish Dynamics and provisioning Swedish organization
- dynamicsprovisionsvelp.ps1 - Installing English Dynamics, provisioning English organization, Installing Reporting Extensions, Installing Swedish language pack, provisioning Swedish organization
- dynamicsprovision8.ps1 - Installing English Dynamics 8.2.3 and provisioning English organization
- dynamicsprovisionsve8.ps1 - Installing Swedish Dynamics 8.2.3 and provisioning Swedish organization
- dynamicsprovisionsvelp8.ps1 - Installing English Dynamics 8.2.3, provisioning English organization, Installing Reporting Extensions, Installing Swedish language pack, provisioning Swedish organization

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

account: `contoso\_crmadmin`

pass: `c0mp1Expa~~`


## Setting up integration

1. On DBDYN01 box, open

`https://crm.contoso.local/Contoso/tools/documentmanagement/documentmanagement.aspx`

2. Click `Enable Server-Based SharePoint Integration`.
3. Click `Next`.
4. Click `Next`.
5. Enter following URL:

`https://intranet.contoso.local/sites/crmdocuments`

6. Enter SharePoint Realm ID:

`42ba318d-3986-4afb-b13e-85cd3c038150`

7. Click `Next`.
8. Click `Enable`.
9. Set "Open Document Management Settings Wizard" checkbox
10. Click `Finish`.
11. Enter following URL:

`https://intranet.contoso.local/sites/crmdocuments`

12. Click `Next`.
13. Click `Next`.
14. Click `Ok`.
15. Click `Finish`.

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
