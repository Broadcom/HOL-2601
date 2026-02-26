      _   _  ___  _         ____   __    ___  _     __  ____  __
     | | | |/ _ \| |       |___ \ / /_  / _ \/ |    \ \/ /\ \/ /
     | |_| | | | | |   _____ __) | '_ \| | | | |_____\  /  \  / 
     |  _  | |_| | |__|_____/ __/| (_) | |_| | |_____/  \  /  \ 
     |_| |_|\___/|_____|   |_____|\___/ \___/|_|    /_/\_\/_/\_\

#####################################################################
###               VMware Cloud Foundation (VCF) 9.0.0             ###
#####################################################################

Overview
========

The 2601 labs provide an overview of What is New in VMware Cloud Foundation (VCF) v9.0.

Contents
============

HOL-2601-01 - 
===========

- Module 1 - VMware Cloud Foundation Overview
- Module 2 - Deploying VMware Cloud Foundation
- Module 3 - Increase Productivity with Virtual Private Clouds (VPCs)

HOL 2601-02
===========

- Module 1 - Provider Management & Administration
- Module 2 - Organization Management & Governance
- Module 3 - Deploying Modern Applications
  
HOL-2601-03
===========

- Module 1 - Monitoring Private Cloud Infrastructure with Diagnostics Findings and VCF Health
- Module 2 - Monitoring Network Operations in the Private Cloud
- Module 3 - Monitoring Storage Operations in the Private Cloud
- Module 4 - Monitoring Security Operations in the Private Cloud
- Module 5 - Chargeback


Pod Information
===============

Virtual Machine Images:

+----------------------------------+---------------------------+-----------------+-----------------------------+
|  Virtual Machine Images          |           FQDN            |    Type         |          Username           |
+----------------------------------+---------------------------+-----------------+-----------------------------+
| Ubuntu 24.04                     |                           | local           | root                        |
|                                  |                           | local           | holuser                     |
+----------------------------------+---------------------------+-----------------+-----------------------------+

Applications/Services:

+----------------------------------+----------------------------+----------------+-----------------------------+
|  Application/Service/VMs         |           FQDN             |    Type        |          Username           |
+----------------------------------+----------------------------+----------------+-----------------------------+
| VCF Operations                   | ops-a.site-a.vcf.lab       | local          | admin                       |
|                                  |                            | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+
| VCF Operations for logs          | opslogs-a.site-a.vcf.lab   | local          | admin                       |
|                                  |                            | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+
| VCF Operations for networks      | opsnet-01a.site-a.vcf.lab  | local          | admin@local                 |
|                                  |                            | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+
| VCF Operations orchestrator      | o11n-01a.site-a.vcf.lab    | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+
| VCF Automation - Provider Portal | auto-a.site-a.vcf.lab      | Provider Admin | admin                       |
| VCF Automation - hol-all-apps    |                            | Org Admin      | admin                       |
| VCF Automation - hol-vm-apps     |                            | Org Admin      | admin                       |
|                                  |                            | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+
| Management Domain vCenter        | vc-mgmt-a.site-a.vcf.lab   | local          | administrator@vsphere.local |
|                                  |                            | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+
| Management Domain NSX Manager    | nsx-mgmt-a.site-a.vcf.lab  | local          | admin                       |
|                                  |                            | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+
| Workload Domain vCenter          | vc-wld-01a.site-a.vcf.lab  | local.         | administrator@wld.sso       |
|                                  |                            | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+
| Workload Domain NSX Manager      | nsx-wld01-a.site-a.vcf.lab | local          | admin                       |
|                                  |                            | appliance      | root                        |
+----------------------------------+----------------------------+----------------+-----------------------------+


