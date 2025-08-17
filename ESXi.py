# ESXi.py version 1.12 12-May 2025
import datetime
import os
import sys
from pyVim import connect
import logging
import lsfunctions as lsf

sys.path.append('/vpodrepo/2026-Labs/2601')
import functions.hol_functions as hol

# default logging level is WARNING (other levels are DEBUG, INFO, ERROR and CRITICAL)
logging.basicConfig(level=logging.WARNING)

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

###
# Testing that vESXi hosts are online: all hosts must respond before continuing
esx_hosts = []
if 'ESXiHosts' in lsf.config['RESOURCES'].keys():
    esx_hosts = lsf.config.get('RESOURCES', 'ESXiHosts').split('\n')

if esx_hosts:
    lsf.write_vpodprogress('Checking ESXi hosts', 'GOOD-3', color=color)
    for entry in esx_hosts:
        (host, mm) = entry.split(':')
        while True:
            if lsf.labtype == "HOL":
                if lsf.test_ping(host):  # just ping because VCF.py will verify
                    break # go on to the next host
                else:
                    lsf.write_output(f'Unable to test {host}. FAIL')
                    lsf.write_vpodprogress(f'{host} TIMEOUT', 'TIMEOUT', color=color)
            else:
                if lsf.test_ping(host):
                    break # go on to the next host
                else:
                    lsf.write_output(f'Unable to test {host}. FAIL')
                    lsf.write_vpodprogress(f'{host} TIMEOUT', 'TIMEOUT', color=color)

########################################################
#  26xx - Set Advanced ESXi setting /Mem/AllocGuestLargePage = 1
########################################################

pwd = lsf.password

if lsf.LMC: 
    if not lsf.labcheck:
        lsf.write_vpodprogress('Setting Advanced Host settings', 'GOOD-2', color=color)
        lsf.write_output(f"TASK: Setting Advanced Host settings", logfile=lsf.logfile)
        try:
            if len(esx_hosts) > 0:
                for entry in esx_hosts:
                    (host, mm) = entry.split(':')
                    username = 'root'
                    password = pwd
                    if hol.isReachable(host, port=22):
                        lsf.write_output(f"INFO: Setting /Mem/AllocGuestLargePage = 1 on '{host}'", logfile=lsf.logfile)
                        lsf.ssh(f'esxcli system settings advanced set -o /Mem/AllocGuestLargePage -i 1', f'{username}@{host}', pwd)
                    else:
                        lsf.write_output(f"INFO: {host} not reachable...", logfile=lsf.logfile)
        except Exception as e:
            lsf.write_output(f"ERROR: {e}", logfile=lsf.logfile)

        finally:
            lsf.write_output("INFO: Advanced Host Settings - COMPLETED", logfile=lsf.logfile)
