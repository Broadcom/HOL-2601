import requests
import urllib3
import lsfunctions as lsf

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

debug = False

########################################################
#  GitLab Health Check
########################################################

def isGitlabHealthy(inFqdn, verify):

    if debug:    
        print(f"Function: isGitlabHealthy")
        print(f"FQDN: {inFqdn}")
        print(f"sslVerify: {verify}")

    try:

        print(f"INFO: Gitlab Health Check '{inFqdn}'")
        lsf.write_output(f'INFO: Gitlab Health Check: {inFqdn}', logfile=lsf.logfile)

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
        print(f"ERROR: HTTP - {e}")
        lsf.write_output(f'ERROR: HTTP Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.ConnectionError as e:
        print(f"ERROR: CONNECT - {e}")
        lsf.write_output(f'ERROR: Connection Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.Timeout:
        print(f"ERROR: TIMEOUT - {e}")
        lsf.write_output(f'ERROR: Timeout Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.RequestException as e:
        print(f"ERROR: REQUEST - {e}")
        lsf.write_output(f'ERROR: Request Error - {e}', logfile=lsf.logfile)

########################################################
# GitLab Readiness Check
########################################################

def isGitlabReady(inFqdn, verify):

    if debug:    
        print(f"Function: isGitlabReady")
        print(f"FQDN: {inFqdn}")
        print(f"sslVerify: {verify}")

    try:
        print(f"INFO: Gitlab Readiness Check '{inFqdn}'")
        lsf.write_output(f'INFO: Gitlab Readiness Check: {inFqdn}', logfile=lsf.logfile)

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
        print(f"ERROR: HTTP -  {e}")
        lsf.write_output(f'ERROR: HTTP Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.ConnectionError as e:
        print(f"ERROR: CONNECT -  {e}")
        lsf.write_output(f'ERROR: Connection Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.Timeout:
        print(f"ERROR: TIMEOUT - {e}")
        lsf.write_output(f'ERROR: Timeout Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.RequestException as e:
        print(f"ERROR: REQUEST - {e}")
        lsf.write_output(f'ERROR: Request Error - {e}', logfile=lsf.logfile)

########################################################
# GitLab Liveness Check
########################################################

def isGitlabLive(inFqdn, verify):

    if debug:    
        print(f"Function: isGitlabLive")
        print(f"FQDN: {inFqdn}")
        print(f"sslVerify: {verify}")

    try:
        print(f"INFO: Gitlab Liveness Check '{inFqdn}'")
        lsf.write_output(f'INFO: Gitlab Liveness Check: {inFqdn}', logfile=lsf.logfile)

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
        print(f"ERROR: HTTP -  {e}")
        lsf.write_output(f'ERROR: HTTP Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.ConnectionError as e:
        print(f"ERROR: CONNECT -  {e}")
        lsf.write_output(f'ERROR: Connection Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.Timeout:
        print(f"ERROR: TIMEOUT - {e}")
        lsf.write_output(f'ERROR: Timeout Error - {e}', logfile=lsf.logfile)
    except requests.exceptions.RequestException as e:
        print(f"ERROR: REQUEST - {e}")
        lsf.write_output(f'ERROR: Request Error - {e}', logfile=lsf.logfile)
