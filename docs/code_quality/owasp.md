<!-- OWASP -->
# OWASP #

[![Home][Home_Image]][Code Quality]

>The Open Web Application Security Project® (OWASP) is a nonprofit foundation that works to improve the security of software. Through community-led open-source software projects, hundreds of local chapters worldwide, tens of thousands of members, and leading educational and training conferences, the OWASP Foundation is the source for developers and technologists to secure the web.

This template makes use of 3 OWASP azure devops extensions as follows:
*[OWASP Dependency Check](https://marketplace.visualstudio.com/items?itemName=dependency-check.dependencycheck)
*[OWASP Zed Attack Proxy Scan](https://marketplace.visualstudio.com/items?itemName=kasunkodagoda.owasp-zap-scan)
*[OWASP ZAP Scanner](https://marketplace.visualstudio.com/items?itemName=CSE-DevOps.zap-scanner)

---
**Note:** "OWASP ZapScan" and "OWASP Zed Attack Proxy Scan" are disabled by default as they requires some urls be passed to them in order to use them

---

The OWASP template is intended to perform a Software Composition Analysis (SCA) check against the root of the repository, publish the results in multiple file formats and finally publish the junit file as test results.

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

- [OWASP](#owasp)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
    - [The stage template](#the-stage-template)
      - [The OWASP Dependency Check](#the-owasp-dependency-check)
      - [The OWASP ZED Attack Proxy Scanner extension](#the-owasp-zed-attack-proxy-scanner-extension)
      - [The OWASP ZAP Scanner extension](#the-owasp-zap-scanner-extension)

## Prerequisites ##

In order to use the [OWASP.yml] Stage template you will need to set the following variables

- `$(project_repo)` - this is set via [variables.yml] and needs to be updated to match your repository name

### The stage template ###

The [OWASP.yml] Stage template looks as follows:

```yaml
steps:
  # Run OWASP Dependency check
    - task: dependency-check-build-task@6
      condition: succeededOrFailed()
      displayName: "OWASP Dependency Check"
      enabled: true
      inputs:
        projectName: '$(project_repo)' #The name of the project being scanned
        scanPath: '$(System.DefaultWorkingDirectory)' #The path to scan. Supports Ant style paths (e.g. 'directory/**/*.jar').
        #excludePath: '' #The path patterns to exclude from the scan. Supports Ant style path patterns (e.g. /exclude/).
        format: 'ALL' #The output format to write to (XML, HTML, CSV, JSON, JUNIT, ALL). Multiple formats can be selected. The default is HTML.
        #failOnCVSS: '0' #CVSS Failure Threshold. Threshold between 0 and 10 that will cause Dependency Check will return the exit code if a vulnerability with a CVSS score equal to or higher was identified.
        suppressionPath: '' #The file path to the suppression XML file used to suppress false positives. This can be specified more than once to utilize multiple suppression files. The argument can be a local file path, a URL to a suppression file, or even a reference to a file on the class path.
        reportsDirectory: '$(System.DefaultWorkingDirectory)/OWASP_Report' #Report output directory. On-prem build agents can specify a local directory to override the default location. The default location is the $COMMON_TESTRESULTSDIRECTORY\dependency-check directory.
        #reportFilename: 'OWASP-report-$(environment_tag)' #Report output filename. Will set the report output name in 'reportsDirectory' to specified filename. Will not work if format is ALL, or multiple formats are supplied to the 'format' parameter. Filename must have an extension or dependency-check will assume it is a path.
        warnOnCVSSViolation: true #Will only warn for found violations above the CVSS failure threshold instead of throwing an error. This build step will then succeed with issues instead of failing.
        enableExperimental: true #Enable the experimental analyzers.
        enableRetired: true #Enable the retired analyzers.
        enableVerbose: true #Enable verbose logging.
        #additionalArguments: '' #Pass additional command line arguments to the Dependency Check command line interface.
        #localInstallPath: '' #The local path to the dependency-check installation directory (on-prem build agents only). Setting this field will run Dependency Check locally instead of downloading the installer onto the build agent.
        #customRepo: '' #By default, the build task downloads the installer from the Dependency Check GitHub releases. Entering a value for this field will pull the installer package from a custom endpoint.
        #dataMirror: '' #The https path to the compressed Dependency Check data directory (containing the odc.mv.db and jsrepository.JSON files).

    # Create work items to review failures
    - task: CreateWorkItem@1
      condition: failed()
      displayName: 'Create work item'
      enabled: true
      inputs:
        #teamProject: # Optional
        workItemType: 'Product Backlog Item'
        title: 'Review OWASP Dependency Check failures for $(project_repo) repository'
        #assignedTo: # Optional
        #areaPath: # Optional
        #iterationPath: # Optional
        fieldMappings: "Description=Please review the attached files and linked build" # Optional; Required if your process defines additional required work item fields
        associate: true # Optional
        associationType: 'foundinbuild' # Optional; Valid values: build, integratedInBuild, foundInBuild
        # ===== Linking Inputs =====
        #linkWorkItems: false # Optional
        #linkType: # Required if linkWorkItems = true
        #linkTarget: id # Optional; Valid values: id, wiql
        #targetId: # Required if linkWorkItems = true and linkTarget = id
        #targetWiql: # Required if linkWorkItems = true and linkTarget = wiql
        limitWorkItemLinksToSameProject: true # Optional
        linkPR: true # Optional
        #linkCode: true # Optional
        #commitsAndChangesets: # Required if linkCode = true
        # ===== Attachments Inputs =====
        addAttachments: true # Optional
        attachmentsFolder: "$(System.DefaultWorkingDirectory)/OWASP_Report/" # Optional
        attachments: '*.*' # Required if addAttachments = true
        # ===== Duplicate Inputs =====
        #preventDuplicates: false # Optional
        #keyFields: # Required if preventDuplicates = true
        #updateDuplicates: false # Optional
        #updateRules: # Optional
        # ===== Outputs Inputs =====
        #createOutputs: false # Optional
        #outputVariables: # Required if createOutputs = true
        # ===== Advanced Inputs =====
        #authToken: #Optional
        #allowRedirectDowngrade: false # Optional  

    - task: owaspzap@1
      condition: succeededOrFailed()
      displayName: "OWASP ZAP Scan"
      enabled: false    
      inputs:
        aggressivemode: true #If unchecked a baseline-zap scan will be used. Aggressive mode is not recommended for continuous integration
        #threshold: '50' #Sets the minimum threshold for a passing zap scan. Defaults to 50
        #scantype: 'targetedScan' #Scan target type.Options are Targeted scan or scan on agent. Omit Scantype altogether for "Scan on agent"
        #url: '' # required if "scantype: 'targetedScan'" enabled Root URL to begin crawling. URL beginning with http:// or https:// is required for the scanner to initialize.
        provideCustomContext: false # Allows passing a custom ZAP context file into the scanner
        contextPath: '' #required if "provideCustomContext: true" enabled. Path to your custom context file from working directory
        port: '443' #Port to scan on the target. Scans port 80 by default.

    - task: OwaspZapScan@2
      condition: succeededOrFailed()
      displayName: "OWASP Zed Attack Proxy Scan"
      enabled: false
      inputs:
        ZapApiUrl: 'zap_url'
        ZapApiKey: 'API_key'
        TargetUrl: 'Target_url'
        ExecuteActiveScan: true
        EnableVerifications: false
        ReportFileDestination: '$(System.DefaultWorkingDirectory)/OWASP_Report'
    
    # Publish the OWASP reports as an artifact to Azure Pipelines
    - task: PublishBuildArtifacts@1
      condition: succeededOrFailed()
      displayName: "Publish OWASP Reports"
      enabled: true
      inputs:
        PathtoPublish: "$(System.DefaultWorkingDirectory)/OWASP_Report"
        ArtifactName: OWASPReports-$(environment_tag)

  #copy sarif files to sarif directory to avoid polluting CodeAnalysisLogs
  - task: Powershell@2
    condition: succeededOrFailed()
    displayName: "Copy Sarif Files"
    enabled: true
    inputs:
      targetType: 'inline'
      script: |
        cd $(System.DefaultWorkingDirectory)/OWASP_Report
        $files = dir
        mkdir sarif
        ForEach($file in $files)
        {
          if($file.extension.Contains("sarif"))
          {
              Copy-Item -Path $file.FullName -Destination sarif -Force
          }
          else
          {
              Write-output $file.FullName "does not need moving"
          }      
        }
      showWarnings: true
      pwsh: true
      workingDirectory: '$(System.DefaultWorkingDirectory)'

    #publish owasp Scan
    - task: PublishBuildArtifacts@1
      condition: succeededOrFailed()
      displayName: "Publish owasp Scan"
      enabled: true
      name: "Publish_owasp_scan"
      inputs:
        PathtoPublish: "$(System.DefaultWorkingDirectory)/OWASP_Report/sarif"
        ArtifactName: "CodeAnalysisLogs"
        publishLocation: "container"

    # publish the test results
    - task: PublishTestResults@2
      displayName: "Publish OWASP Test Results"
      condition: succeededOrFailed()
      inputs:
        testResultsFormat: "JUnit" # Options JUnit, NUnit, VSTest, xUnit, cTest
        testResultsFiles: |
          **/*OWASP-report-$(environment_tag).xml
          **/*junit.xml
        searchFolder: "$(System.DefaultWorkingDirectory)/OWASP_Report"
        mergeTestResults: false
        testRunTitle: "OWASP Dependency Check"
        failTaskOnFailedTests: false
        publishRunAttachments: true
```

As you can see the stage does the following:

- Runs OWASP Dependency Check against the root of the repository
- Outputs results in `ALL` available formats:
  - XML
  - HTML
  - CSV
  - JSON
  - JUNIT
- The results are pushed to the OWASP_Report directory
- If the scan has any failures a work item is created called `Review OWASP failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
  - Pull requests are linked to the work item
  - All output from the scan is attached
- If enabled the OWASP Zap Scan is ran
- If enabled the OWASP Zed Attack Proxy Scan is ran
- The reports and log are published as an artifact called `OWASPReports-$(environment_tag)`
- Copies the sarif files to `$(System.DefaultWorkingDirectory)/OWASP_Report/sarif`
- Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
- The test results are published as a test run called `OWASP Scan`

the steps are preconfigured as follows

#### The OWASP Dependency Check ####

Is preconfigured as follows:

- **projectName:** '$(project_repo)' - The name of the project being scanned. This is currently set to a Repo named repo_template under the Azure DevOps project.
- **scanPath:** '`$(System.DefaultWorkingDirectory)`' - The path to scan. Supports Ant style paths (e.g. 'directory/**/*.jar'). This is set to `$(System.DefaultWorkingDirectory)` to scan the root of the Repo
- **excludePath:**'' - The path patterns to exclude from the scan. Supports Ant style path patterns (e.g. /exclude/). This is set to blank as we do not wish to exclude any paths from the scan.
- **format:** 'ALL' - The output format to write to (XML, HTML, CSV, JSON, JUNIT, ALL). Multiple formats can be selected. The default is HTML. This is set to ALL to provide he reports in all formats to increase human and machine readability.
- **failOnCVSS:** '0' - CVSS Failure Threshold. Threshold between 0 and 10 that will cause Dependency Check will return the exit code if a vulnerability with a CVSS score equal to or higher was identified. This is commented out as we are not using it.
- **suppressionPath:** '' - The file path to the suppression XML file used to suppress false positives. This can be specified more than once to utilize multiple suppression files. The argument can be a local file path, a URL to a suppression file, or even a reference to a file on the class path. This is set to blank as we are not using it.
- **reportsDirectory:** '$(System.DefaultWorkingDirectory)/OWASP_Report' - Report output directory. On-prem build agents can specify a local directory to override the default location. The default location is the $COMMON_TESTRESULTSDIRECTORY\dependency-check directory.
- **reportFilename:** 'OWASP-report-$(environment_tag)' - Report output filename. Will set the report output name in 'reportsDirectory' to specified filename. Will not work if format is ALL, or multiple formats are supplied to the 'format' parameter. Filename must have an extension or dependency-check will assume it is a path.
- **warnOnCVSSViolation:** true - Will only warn for found violations above the CVSS failure threshold instead of throwing an error. This build step will then succeed with issues instead of failing.
- **enableExperimental:** true - Enable the experimental analyzers. This is set to true to include as many analysers as possible.
- **enableRetired:** true - Enable the retired analyzers. This is set to true to include as many analysers as possible.
- **enableVerbose:** true - Enable verbose logging. This is set to true as additional logging is always helpful
- **additionalArguments:** '' - Pass additional command line arguments to the Dependency Check command line interface. This is set to blank as we are not passing in any additional arguments.
- **localInstallPath:** '' - The local path to the dependency-check installation directory (on-prem build agents only). Setting this field will run Dependency Check locally instead of downloading the installer onto the build agent. This is set to blank as we are not changing the install location.
- **customRepo:** '' - By default, the build task downloads the installer from the Dependency Check GitHub releases. Entering a value for this field will pull the installer package from a custom endpoint. This is set to blank as we are not changing the source Repo.
- **dataMirror:** '' - The https path to the compressed Dependency Check data directory (containing the odc.mv.db and jsrepository.JSON files). This is set to blank as we are not using it.

Additionally we have also included the ZED Attack Proxy Scan and ZAP scanner extensions to make use of if applicable.

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

#### The OWASP ZED Attack Proxy Scanner extension ####

Requires that you have ZED Attack Proxy installed on a machine. Documentation about this can be found about this on the link above.
This step of the pipeline has some self explanatory placeholder markers that you can replace once you have ZED Attack Proxy installed as follows:

- `zap_url` - this is the URL for ZED Attack Proxy (The fully qualified domain name (FQDN) with out the protocol)
- `API_key` - The API key for ZAP. Details about obtaining the API can be found on the [Official Documentation](https://www.zaproxy.org/faq/why-is-an-api-key-required-by-default/)
- `Target_url` - Target URL where the active scan is performed against

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

#### The OWASP ZAP Scanner extension ####

Runs the same process as the OWASP ZED Attack Proxy Scanner extension. However, it pulls in a Docker image that contains ZED Attack Proxy and uses this to perform the scan.
This step of the pipeline has been preconfigured with some options as follows:

- **aggressivemode:** true - If set as false a baseline-zap scan will be used. Aggressive mode is not recommended for continuous integration as it can take a long time and does perform attacks but is useful for release gates
- **threshold:** '50' - Sets the minimum threshold for a passing zap scan. Defaults to 50.
- **scantype:** 'targetedScan' - Scan target type.Options are Targeted scan or scan on agent. Omit Scantype altogether for "Scan on agent". This si commented out to force the scan to be ran on the agent.
- **url:** '' - required if scantype is set to 'targetedScan' is the Root URL to begin crawling. URL beginning with http:// or https:// is required for the scanner to initialize.
- **provideCustomContext:** false - Allows passing a custom ZAP context file into the scanner. We do not use this currently.
- **contextPath:** '' - required if "provideCustomContext: true" enabled. Path to your custom context file from working directory. We do not use this so it is set as blank.
- **port:** '80' - Port to scan on the target. Scans port 80 by default.

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- Azure Devops Links -->

<!-- BADGES AND SHIELDS -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge

<!-- GITHUB LINKS -->
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.md
[linkedin-url]: https://linkedin.com/in/othneildrew
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers

<!-- IMAGES AND ICONS -->
[Home_Image]: ./repo_template-images/home.png
[logo-image]: ./repo_template-images/logo.png
[pipeline-screenshot]: ./repo_template-images/pipeline-screenshot.png
[product-screenshot]: ./repo_template-images/screenshot.png
[teams-icon]: ./repo_template-images/teams.png

<!-- MARKDOWN DOCUMENT LINKS -->
[Blank Readme]: ./BLANK_README.md
[Code Quality]: ./docs/code_quality.md
[Bridgecrew_Checkov]: ./docs/code_quality/bridgecrew_checkov.md
[Checkmarx_KICS]: ./docs/code_quality/checkmarx_kics.md
[GitHub_Super_Linter]: ./docs/code_quality/github_super_linter.md
[Infracost]: ./docs/code_quality/Infracost.md
[License]: ./license.md
[Megalinter]: ./docs/code_quality/megalinter.md
[Mend_Bolt]: ./docs/code_quality/mend_bolt.md
[OWASP]: ./docs/code_quality/owasp.md
[Readme]: ./README.md
[Sonar_Cloud]: ./docs/code_quality/sonar_cloud.md
[Template_updater]: ./docs/code_quality/template_updater.md
[terraform_Compliance]: ./docs/code_quality/terraform_compliance.md
[Terrascan]: ./docs/code_quality/terrascan.md
[TFLint]: ./docs/code_quality/tflint.md
[TFSec]: ./docs/code_quality/tfsec.md
[Usage_Guide.md]: ./docs/usage_guide.md

<!-- CODE QUALITY TEMPLATE LINKS -->
[Checkmarx_KICS.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/checkmarx_kics.yml
[Checkov.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/checkov.yml
[Checkov_baseline_creator.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/checkov_baseline_creator.yml
[GitHub_Super_Linter.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/github_super_linter.yml
[Infracost.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/Infracost.yml
[Mega_Linter.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/mega_linter.yml
[OWASP.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/owasp.yml
[TFComplianceCheck.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/tfcompliancecheck.yml
[template_updater.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/template_updater.yml
[Terrascan.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/terrascan.yml
[TFLint.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/tflint.yml
[TFSec.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/tfsec.yml

<!-- IAC TEMPLATE LINKS-->
[terraform_apply.yml]: /repo_template/build/pipelines/repo_template/build/iac_templates/terraform_apply.yml
[terraform_plan.yml]: /repo_template/build/pipelines/repo_template/build/iac_templates/terraform_plan.yml
[variables.yml]: /repo_template/build/pipelines/repo_template/build/iac_templates/variables.yml

<!-- PIPELINE LINKS -->
[infrastructure.yml]: /repo_template/build/pipelines/infrastructure.yml
[code_quality.yml]: /repo_template/build/pipelines/code_quality.yml

<!-- GitHub stuff-->
<!--
***
*** this is all the github stuff that currently isn't relevant to BCA 
***
-->

<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the Repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
<!--
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]
-->
