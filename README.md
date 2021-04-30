# Salesforce App

This guide helps IATA Salesforce Developers to understand the git flow, generate deployable packages, configure Bitbucket Pipelines, and deploy to their own environments effortlessly.

On this guide you can find:

* [Part 1: Repository configuration](#markdown-part-1-repository-configuration)  
  * [Production-Master](#production-master)

  * [Forked-Repository](#forked-repository)

  * [Pull Requests (package)](#pull-requests-package)
  
* [Part 2: Pipeline Configuration](#part-2-pipeline-configuration)
  * [Repository Variables](#repository-variables)

  * [Run Pipelines](#run-pipelines)
  
* [Part 3: Sandbox Configuration](#part-3-sandbox-configuration)

  

In case of questions, please contact the Release Manager: Rúben Nunes: nunesr@iata.org


## Part 1: Repository configuration

For every Salesforce Project, the Bitbucket repository will always be the source of truth and a fork is generated from the Production-Master repository.

The source code is in the metadata format, due to this format we recommend using [VSCode](https://code.visualstudio.com/) with [ForceCode](https://marketplace.visualstudio.com/items?itemName=JohnAaronNelson.ForceCode) Extension

The developer locally on its computer should have in the same folder of the cloned repository the salesforce project (forceCode). This is the only way to capture the changes to commit.

As a developer, you should always commit only the changes in the files modified by you and you should leave a clear commit message, including the jira User Story you're working on.

#### Production-Master

Production-Master repository have always 4 branches:

**SIT** -  Represents the content of SIT, a developer sandbox environment, and is used to test deployments, check apex test regressions and coverage percentage.

**PREPROD** - Represents the content of PREPROD, a full copy sandbox, is used for post deployments rehearsals, end to end testing, and UATs.

**PROD-RELEASE** - Is the staging branch to Production. When a package is ready to be deployed to production a Pull Request is created to this branch and will be merged with the master once the deployment is completed.

**master** -  Represents the current content of Production environment

#### Forked Repository

The forked repository should always have its master branch synced with the Production-Master repository. It is the responsibility of the Dev team to synchronize it using the Sync button in the Source tab in Bitbucket.

![Scheme](readmeimages\sync.png)



A forked repository should contain:

feature/ branches -  Should contain the developments related to a specific Jira User Story
release/ branches - All the feature branches merged to create a branch with all the content for a specific release (creation of the release package)

#### Pull Requests (package)

To send the new developments to the Production, 3 identical Pull Requests must be created, containing the same content, to the correspondent branches following the bellow naming convention:

ProjNameorDevName-SprintNRorTicketNR-Environment 

The branches should be created locally using the feature/release branch as base and merging them into the one it should be sent. Then the PR should be created to the correspondent branch..

SFProj-JIRASP-00001-SIT

SFProj-JIRASP-00001-PREPROD

SFProj-JIRASP-00001-PRODRELEASE

To create the right branch follow these 3 simple steps (the example below was done using [Source Tree](https://sourcetreeapp.com/?utm_source=bitbucket&utm_medium=tutorial_repo_link&utm_campaign=sourcetree-text) git client, you can use whatever tool fits you):

*1- Checkout the end point branch:*

![Scheme](readmeimages\checkout.png)

*2 - Merge the feature/release branch into the checkout branch*:



![Scheme](readmeimages\mergeinto.png)



*3 - Push the branch to the Bitbucket repository and create the Pull Request to the correspondent branch*



<u>Before creating the Pull Request, the developer should make sure he is aware of all the included changes, the classes have at least 85% coverage and they will not cause any deployment failure.</u>

The description of the PR, should contain:

- A brief description of the content
- All Jira User Stories related
- A list of all the test classes which cover the changes (which cover all the new changes and keep the class with 85%)




## Part 2: Pipeline Configuration

To run the pipelines defined in the YML file first you need to configure the bellow Repository variables in your fork.

#### Repository Variables

**Variables use for Deployment jobs (mandatory)**:

**sfUsername_BRANCHNAME** -  the var should be created replacing the '**BRANCHNAME**' with branch name of the branch which will be used to run the pipelines. Its value should be filled with the sandbox username you want to deploy

**sfPassword_BRANCHNAME** - the var should be created replacing the '**BRANCHNAME**' with branch name of the branch which will be used to run the pipelines. Its value should be filled with the sandbox username password you want to deploy (don't forget to set it as Secured to hide it)

**GIT_DIFFRANGE** - variable to check the range the system should check for commits (used in the "Deploy latest commits" pipeline). Ex. 1_hour_ago; 3_hour_ago; 1_day_ago; 3_day_ago

**Variables use for Retrieve jobs (optional):**
**GIT_USERNAME** - Bitbucket username

**GIT_PASSWORD** - Bitbucket password

**GIT_REPONAME** - Bitbucket repository

**GIT_EMAIL** - Bitbucket user email

**GIT_MESSAGE** - Static commit message

**GIT_BRANCHNAME** - Branch name to receive the retrieve changes



#### Run Pipelines

To Run a pipeline, you should navigate to the branch section, select the 3 dots of the branch you want to run the pipeline and select the option "Run pipeline for a branch":

![Scheme](readmeimages\runpipeline.png)



 

You will find the options:

**Full Deploy** : 

Deploy the whole repository in a Sandbox. The deployment is done in a sequence of 7 steps. If it happens one of the steps fail, you should fix it and re-run the job. If there is any component that should be added, please contact the release manager.

Its recommended to run this on weekly basis.

Find below the components deployed in every step

| Step | Metadata                                                     |
| ---- | ------------------------------------------------------------ |
| 1    | translations,labels,objectTranslations                       |
| 2    | globalValueSets,documents,groups,staticresources,queues      |
| 3    | standardValueSets,objects,workflows,email,approvalProcesses,customPermissions |
| 4    | classes,components,pages,triggers                            |
| 5    | aura,flexipages,lwc,quickActions                             |
| 6    | layouts,tabs,applications,customMetadata                     |
| 7    | flows, datacategorygroups, sharingRules                      |

**Quick Deploy** : 

Deploy all the commits in the branch defined by the repository variable **GIT_DIFFRANGE**

Its recommended to run it daily.



**Run Tests**:

Run all tests in the environment, it takes 8 hours to fully execute them. The test results are available in the deployment status page of the sandbox.

Its recommended to run them daily and overnight.



## Part 3: Sandbox Configuration

Community Configuration:

CS Portal: 

| Steps                                            | Value                                                        |
| ------------------------------------------------ | ------------------------------------------------------------ |
| Custom Label CSP_PortalPath                      | /csportal/s/                                                 |
| Custom Setting: CSP_PortalBaseURL                | https://preprod-customer-portal-iata.cs129.force.com (use the SB current domain) |
| Export CSPortal assets from PP                   | CSP Builder: workspace -> Administration -> Pages -> Go to Site.com -> Export Assets |
| Go to Community in the refreshed sandbox Import  | Import Assets                                                |
| Pencil Button in the Builder and edit Global CSS | -Replace the import line [@import url("https://preprod-customer-portal-iata.cs129.force.com/csportal/s/sfsites/c/resource/CSP_Stylesheet");](https://preprod-customer-portal-iata.cs129.force.com/csportal/s/sfsites/c/resource/CSP_Stylesheet"))(use the SB current domain)<br />- Find all the URL's importing lines and replace the beginning (/s/) with new path /csportal/s/<br /> |

