# final.py - version v1.7 - 2026-06-29
import sys
import lsfunctions as lsf
import os
import shutil
import datetime
import requests
import logging
from pathlib import Path

sys.path.append('/vpodrepo/2026-Labs/2601')
# default logging level is WARNING (other levels are DEBUG, INFO, ERROR and CRITICAL)
logging.basicConfig(level=logging.DEBUG)

# read the /hol/config.ini
lsf.init(router=False)

color = 'red'
if len(sys.argv) > 1:
    lsf.start_time = datetime.datetime.now() - datetime.timedelta(seconds=int(sys.argv[1]))
    if sys.argv[2] == "True":
        lsf.labcheck = True
        color = 'green'
        lsf.write_output(f'{sys.argv[0]}: labcheck is {lsf.labcheck}')   
    else:
        lsf.labcheck = False
 
lsf.write_output(f'Running {sys.argv[0]}')
if lsf.labcheck == False:
    lsf.write_vpodprogress('Final Checks', 'GOOD-8', color=color)

# prevent update manager from showing window for updates if LMC
if lsf.LMC and lsf.labtype == 'HOL':
    try:
        lsf.write_output('Making sure updates are not showing on console...')
        lsf.ssh(f'pkill update-manager;pkill update-notifier 2>&1', 'holuser@console', lsf.password)
    except Exception as e:
        lsf.write_output(f'exception: {e}')


# add any code you want to run at the end of the startup before final "Ready"
#lsf.write_output("This is final.py output")

if lsf.lab_sku == "VCF9-VKS-D":
    import subprocess
    repo_dest = "/vpodrepo/2027-labs/2788"
    try:
        lsf.write_output("Cloning HOL-2788 repo...")
        if os.path.exists(repo_dest):
            shutil.rmtree(repo_dest)
        subprocess.run(
            ["git", "clone", "https://github.com/Broadcom/HOL-2788", repo_dest],
            check=True
        )
        lsf.write_output("Starting Lab updates")
        lsf.run_command("chmod +x /vpodrepo/2027-labs/2788/lab-update.sh")
        lsf.run_command("/bin/bash /vpodrepo/2027-labs/2788/lab-update.sh")
        lsf.write_output("Finished Lab updates")
    except Exception as e:
        lsf.write_output(f"HOL-2788 setup failed: {e}")
        lsf.labfail("HOL-2788 clone/copy failed")
        exit(1)

# #######################################################
#  26xx - PVC Fixes for VKS
# #######################################################
pwd = lsf.password

if lsf.LMC: 
    if not lsf.labcheck:
        lsf.write_vpodprogress('Running VKS PVC Fix', 'GOOD-2', color=color)
        lsf.write_output(f"TASK: Running VKS PVC Fix", logfile=lsf.logfile)
        try:
            lsf.run_command('bash /vpodrepo/2026-labs/2601/labfiles/pvc_fix.sh')
        except Exception as e:
            lsf.write_output(f'INFO: {e}', logfile=lsf.logfile)
            print(f'INFO: {e}')

########################################################
#  26xx - Create Security Audit Events using PowerShell
########################################################
pwd = lsf.password
lsf.write_vpodprogress('Running HOL-26xx Startup Scripts', 'GOOD-2', color=color)
cmd = 'pwsh /vpodrepo/2026-labs/2601/AuditEvents.ps1'

if lsf.LMC: 
    if not lsf.labcheck:
        lsf.write_vpodprogress('Creating Security Audit Events using PowerShell', 'GOOD-2', color=color)
        lsf.write_vpodprogress('Creating Security Audit Events using PowerShell', 'GOOD-2', color=color)
        lsf.write_output(f"TASK: Creating Security Audit Events using PowerShell", logfile=lsf.logfile)
        try:
            lsf.run_command(cmd)
        except Exception as e:
            lsf.write_output(f'INFO: {e}', logfile=lsf.logfile)
            print(f'INFO: {e}')


########################################################
#  26xx - Update Gitlab Repository
########################################################
# gitFqdn = "gitlab.site-a.vcf.lab"
# sslVerify = False
# pwd = lsf.password

pwd = lsf.password
cmd = 'bash /vpodrepo/2026-labs/2601/gitlab.sh'

if lsf.LMC: 
    if not lsf.labcheck:
        lsf.write_vpodprogress('Updating Gitlab Repositories', 'GOOD-2', color=color)
        lsf.write_vpodprogress('Updating Gitlab Repositories', 'GOOD-2', color=color)
        lsf.write_output(f"TASK: Updating Gitlab Repositories", logfile=lsf.logfile)
        try:
            lsf.run_command(cmd)
        except Exception as e:
            lsf.write_output(f'INFO: {e}', logfile=lsf.logfile)
            print(f'INFO: {e}')


########################################################
#  26xx - Update Gitlab 
########################################################
# gitFqdn = "gitlab.site-a.vcf.lab"
# sslVerify = False
# pwd = lsf.password

# if lsf.LMC:
#   if not lsf.labcheck:
#     lsf.write_output(f"TASK: Checking Gitlab Status...", logfile=lsf.logfile)
#     lsf.write_vpodprogress(f'Checking Gitlab Status...', 'GOOD-8', color=color)
#     while True:
#         if hol.isGitlabReady(gitFqdn, sslVerify) and hol.isGitlabLive(gitFqdn, sslVerify) and hol.isGitlabHealthy(gitFqdn, sslVerify):
#             lsf.write_output(f'INFO: Gitlab {gitFqdn} is in a Ready state!', logfile=lsf.logfile)
#             break
#         else:
#             lsf.write_output(f'INFO: Gitlab {gitFqdn} is not Ready!', logfile=lsf.logfile)
#             lsf.labstartup_sleep(30)

# fail like this
#lsf.labfail('FINAL ISSUE')
#exit(1)

lsf.write_output('Finished Final Checks')
lsf.write_vpodprogress('Finished Final Checks', 'GOOD-9', color=color)
