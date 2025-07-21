from datetime import datetime
import os
import base64
import requests
import urllib3
import re
import json
import subprocess


urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


import lsfunctions as lsf

debug = False
retryCount = 1

########################################################
#  GitLab Health Check
########################################################

def isGitlabHealthy(inFqdn, verify):

    if debug:    
        print(f"Function: isGitlabHealthy")
        print(f"FQDN: {inFqdn}")
        print(f"sslVerify: {verify}")

    try:

        print(f"2501: Gitlab Health Check '{inFqdn}'")
        lsf.write_output(f'2501: Gitlab Health Check: {inFqdn}', logfile=lsf.logfile)

        url = f"https://{inFqdn}/-/health"
            
        headers = {}
        
        payload = {}
    
        session = requests.Session()
        session.trust_env = False

        response = session.get(url=url, data=payload, headers=headers, verify=verify, proxies=None)
        response.raise_for_status()

        if not (response.status_code < 200 or response.status_code >= 300):
            return True
        else:
            return False
              
    except requests.exceptions.HTTPError as e:
        print(f"2501: HTTP - {e}")
        lsf.write_output(f'2501: HTTP Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.ConnectionError as e:
        print(f"2501: CONNECT - {e}")
        lsf.write_output(f'2501: Connection Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.Timeout:
        print(f"2501: TIMEOUT - {e}")
        lsf.write_output(f'2501: Timeout Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.RequestException as e:
        print(f"2501: REQUEST - {e}")
        lsf.write_output(f'2501: Request Error - {e}', logfile=lsf.logfile)

########################################################
# GitLab Readiness Check
########################################################

def isGitlabReady(inFqdn, verify):

    if debug:    
        print(f"Function: isGitlabReady")
        print(f"FQDN: {inFqdn}")
        print(f"sslVerify: {verify}")

    try:
        print(f"2501: Gitlab Readiness Check '{inFqdn}'")
        lsf.write_output(f'2501: Gitlab Readiness Check: {inFqdn}', logfile=lsf.logfile)

        url = f"https://{inFqdn}/-/readiness?all=1"
            
        headers = {}
        
        payload = {}
        
        session = requests.Session()
        session.trust_env = False

        response = session.get(url=url, data=payload, headers=headers, verify=verify, proxies=None )
        response.raise_for_status()

        if not (response.status_code < 200 or response.status_code >= 300):
            jResponse = response.json()
            if jResponse['status'] == "ok":
                for key, value in jResponse.items():
                    if isinstance(value, list):
                        for item in value:
                            if item['status'] != 'ok':
                                return False
                return True   
        else:
            return False                             
              
    except requests.exceptions.HTTPError as e:
        print(f"2501: HTTP -  {e}")
        lsf.write_output(f'2501: HTTP Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.ConnectionError as e:
        print(f"2501: CONNECT -  {e}")
        lsf.write_output(f'2501: Connection Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.Timeout:
        print(f"2501: TIMEOUT - {e}")
        lsf.write_output(f'2501: Timeout Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.RequestException as e:
        print(f"2501: REQUEST - {e}")
        lsf.write_output(f'2501: Request Error - {e}', logfile=lsf.logfile)

########################################################
# GitLab Liveness Check
########################################################

def isGitlabLive(inFqdn, verify):

    if debug:    
        print(f"Function: isGitlabLive")
        print(f"FQDN: {inFqdn}")
        print(f"sslVerify: {verify}")

    try:
        print(f"2501: Gitlab Liveness Check '{inFqdn}'")
        lsf.write_output(f'2501: Gitlab Liveness Check: {inFqdn}', logfile=lsf.logfile)

        url = f"https://{inFqdn}/-/liveness"
            
        headers = {}
        
        payload = {}
        
        session = requests.Session()
        session.trust_env = False

        response = session.get(url=url, data=payload, headers=headers, verify=verify, proxies=None )
        response.raise_for_status()

        if not (response.status_code < 200 or response.status_code >= 300):
            jResponse = response.json()
            if jResponse['status'] != "ok":
                return False  
            return True
              
    except requests.exceptions.HTTPError as e:
        print(f"2501: HTTP -  {e}")
        lsf.write_output(f'2501: HTTP Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.ConnectionError as e:
        print(f"2501: CONNECT -  {e}")
        lsf.write_output(f'2501: Connection Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.Timeout:
        print(f"2501: TIMEOUT - {e}")
        lsf.write_output(f'2501: Timeout Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.RequestException as e:
        print(f"2501: REQUEST - {e}")
        lsf.write_output(f'2501: Request Error - {e}', logfile=lsf.logfile)

########################################################
# 2501 - GUID Check
########################################################

def isGuid(testString):

    if debug:    
        print(f"Function: isGuid")
        print(f"String: {testString}")


    guidPattern = r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

    try:
        match = re.search(guidPattern, testString)
        if match:
            return True
        else:
            return False
        
    except Exception as e:
        print(f"2501: Pattern Match Error - Provided string is not a vmid (UUID)")
        lsf.write_output(f'2501: Pattern Match Error - Provided string is not a vmid (UUID)', logfile=lsf.logfile)
    
########################################################
# 2601 - Check Folder Exists?
########################################################

def checkFolder(folder):
    try:
        print(f"TASK: Create Folder: {folder}")
        if os.path.exists(folder):
            lsf.write_output(f'INFO: Folder: {folder} does exist.', logfile=lsf.logfile)
            print(f"INFO: Folder: {folder} already exists." )
            return True 
        else:
            print(f"INFO: Folder: {folder} does not exist." )
            lsf.write_output(f'INFO: Folder: {folder} does not exist.', logfile=lsf.logfile)
            return False
    except Exception as e:
        lsf.write_output(f'{e}', logfile=lsf.logfile)
        print(f'2501: {e}')  

########################################################
# 2601 - Delete Folder
########################################################

def deleteFolder(folder): 
    try:
        print(f"TASK: Delete Folder: {folder}")
        if os.path.exists(folder):
            lsf.write_output(f'INFO: Deleting Folder: {folder}', logfile=lsf.logfile)
            print(f"INFO: Deleting Folder: {folder}.")
            os.rmdir(folder)
        else:
            print(f"INFO: Folder: {folder} does not exist.")
            lsf.write_output(f'INFO: Folder: {folder} does not exist.', logfile=lsf.logfile)
    except Exception as e:
        lsf.write_output(f'INFO: {e}', logfile=lsf.logfile)
        print(f'INFO: {e}')



########################################################
# 2601 - Create Folder
########################################################

def createFolder(folder):
    try:
        if not os.path.exists(folder):
            os.makedirs(folder)
            print(f"INFO: Folder {folder} created successfully.")
            lsf.write_output(f'INFO: Folder {folder} created successfully.', logfile=lsf.logfile)
        else:
            print(f"INFO: Folder: {folder} already exists.")
            lsf.write_output(f'INFO: Folder: {folder} already exists.', logfile=lsf.logfile)
    except Exception as e:
        lsf.write_output(f'INFO: {e}', logfile=lsf.logfile)
        print(f'INFO: {e}')
