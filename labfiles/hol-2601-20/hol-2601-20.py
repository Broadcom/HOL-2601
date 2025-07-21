import functions.gitlab_functions as gf
import functions.vm_functions as vmf
import functions.file_functions as file
import sys
import time
import json
import os

#Constants
debug = False

# Function Definitions

# Main Execution

# Variables
GITLAB_URL = 'https://gitlab.site-a.vcf.lab'
ACCESS_TOKEN = input("Enter your GitLab Access Token: ").strip()


if not ACCESS_TOKEN:
    print("ERROR: Access Token is required")
    sys.exit(1)

rootFolder = os.path.dirname(__file__)

try:
    
    start = time.time()
    print(f"START: {time.strftime('%H:%M:%S', time.localtime(start))}")
    
    with open('projects.json', 'r') as f:
        project_data = json.load(f)

    

    gf.list_projects(GITLAB_URL, ACCESS_TOKEN)
    gf.list_users(GITLAB_URL, ACCESS_TOKEN)
    gf.list_groups(GITLAB_URL, ACCESS_TOKEN)

    for group in project_data.get('groups', []):

        if group.get('name') is not None:

            try:
                groupName = group['name'].strip()
                visibility = group['visibility'] if 'visibility' in group else 'private'
                description = group['description']

                if debug:
                    print(f"INFO: Processing group: '{groupName}' with visibility: '{visibility}' and description: '{description}'")

                groupId = gf.get_group_id(GITLAB_URL, ACCESS_TOKEN, groupName)
                if debug:
                    print(f"INFO: Group ID for '{groupName}': {groupId}")

                if not groupId:
                    print(f"INFO: Creating group '{groupName}'")
                    groupId = gf.new_group(GITLAB_URL, ACCESS_TOKEN, groupName, visibility, description)
                else:
                    print(f"INFO: Group '{groupName}' already exists with ID: {groupId}")

                for project in group.get('projects', []):
                    if debug:
                        print(f"INFO: Processing project: '{project['name']}' in group: '{groupName}'")

                    projectName = project['name'].replace(' ', '-').strip()
                    visibility = project['visibility'] if 'visibility' in project else group['visibility']

                    print(f"INFO: Creating project '{projectName}' in group '{groupName}'")

                    projectId = gf.get_project_id(GITLAB_URL, ACCESS_TOKEN, projectName)

                    if projectId:
                        print(f"INFO: Project '{projectName}' already exists with ID: {projectId}")
                    else:
                        print(f"INFO: Project '{projectName}' does not exist. Creating new project.")
                        projectId = gf.new_project(GITLAB_URL, ACCESS_TOKEN, projectName, groupId, visibility)

                    time.sleep(5)  # To avoid hitting API rate limits

                    for member in project.get('members', []):
                        username = member['username']
                        access_level = gf.get_access_level(member['access_level'])
                        if debug:
                            print(f"INFO: Adding user '{username}' with access level '{access_level}' to project '{projectName}'")

                        if not gf.is_project_member(GITLAB_URL, ACCESS_TOKEN, username, projectName, groupName):
                            gf.add_project_member(GITLAB_URL, ACCESS_TOKEN, username, projectName, access_level, groupName)
                        else:
                            print(f"INFO: User '{username}' is already a member of project '{projectName}'")
                    
                    for branch in project.get('branches', []):
                        branchName = branch['name']
                        sourceBranch = branch.get('sourceBranch', 'main')
                        protected = branch['protected']

                        aFile = gf.new_readme(GITLAB_URL, ACCESS_TOKEN, projectName, groupName, branchName, rootFolder)

                        if gf.is_project_branch(GITLAB_URL, ACCESS_TOKEN, projectName, groupName, branchName):
                            print(f"INFO: Branch '{branchName}' already exists in project '{projectName}'")
                        else:
                            print(f"INFO: Creating branch '{branchName}' from '{sourceBranch}' in project '{projectName}'")
                            gf.new_branch(GITLAB_URL, ACCESS_TOKEN, projectName, groupName, branchName, sourceBranch, protected)

                        time.sleep(5)  # To avoid hitting API rate limits

                        for commit in branch.get('commits', []):
                            commitMessage = commit['message']

                            for action in commit.get('actions', []):
                                if debug:
                                    print(f"Action: {action['action']}, File Path: {action['file_path']}, Content: {action['content']}")
                                commitAction = action['action']
                                if action['action'] == 'create':
                                    filePath = action['file_path']
                                    fileContent = open(aFile, 'r').read()
                                elif action['action'] == 'update':
                                    filePath = action['file_path']
                                    fileContent = open(aFile, 'r').read()
                                elif action['action'] == 'delete':
                                    filePath = action['file_path']
                                    fileContent = None
                                                    
                            print(f"INFO: Creating commit in branch '{branchName}' of project '{projectName}'")
                            gf.new_commit(GITLAB_URL, ACCESS_TOKEN, projectName, groupName, branchName, commitMessage, commitAction, filePath, fileContent)

            except Exception as e:
                print(f"ERROR: {e}")

    vcFqdn = "vc-mgmt-a.site-a.vcf.lab"
    vcUsername =  "administrator@vsphere.local"
    vcPassword = file.readFile('/home/holuser/Desktop/PASSWORD.txt')
    dcName = "dc-a"
    clusterName = "cluster-mgmt-01a"
    vmFolderName = 'Workloads'
    datastoreName = 'vsan-mgmt-01a'
    templateName = 'ubuntu-24-04-base'
    vmName = 'gitlab'

    if not vmf.vmExists(vcFqdn, vcUsername, vcPassword, vmName):
        vmf.new_vm(vcFqdn, vcUsername, vcPassword, vmName, dcName, clusterName, vmFolderName, datastoreName, templateName)
    else:
        print(f"INFO: Virtual Machine '{vmName}' already exists.")
except Exception as e:
    print(f"ERROR: {e}")

finally:

    for group in project_data.get('groups', []):
        for project in group.get('projects', []):
            projectName = project['name'].replace(' ', '-').strip()
            file.deleteFile(f"{rootFolder}/{projectName}/README.md")
            file.deleteFolder(f"{rootFolder}/{projectName}")

    finish = time.time()
    print(f"END: {time.strftime('%H:%M:%S', time.localtime(finish))}")

    elapsed = finish - start
    print(f"ELAPSED: {time.strftime('%H:%M:%S', time.gmtime(elapsed))}")