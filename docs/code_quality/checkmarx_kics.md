<!-- Checkmarx KICS -->
# Checkmarx KICS #

[![Home][Home_Image]][Code Quality]

> Find security vulnerabilities, compliance issues, and infrastructure misconfigurations early in the development cycle of your infrastructure-as-code with KICS by Checkmarx.
>
> **KICS** stands for Keeping Infrastructure as Code Secure, it is open source and is a must-have for any cloud native project.
>
> **Supported Platforms**
>
> * Ansible
> * ARM
> * AWS Cloud Development Kit
> * AWS CloudFormation
> * Docker
> * Docker compose
> * GDM
> * gRPC
> * HELM
> * Kubernetes
> * OpenAPI
> * SAM

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

* [Checkmarx KICS](#checkmarx-kics)
  * [Table of Contents](#table-of-contents)
  * [Prerequisites](#prerequisites)
    * [The stage template](#the-stage-template)

## Prerequisites ##

KICS relies on the `KICS.config` config file at the root of the Repo

### The stage template ###

The [checkmarx_kics.yml] Stage template looks as follows:

 ```yaml
  - script: |
      mkdir KICSReports
      docker pull checkmarx/kics:latest
      docker run \
      --volume "$(pwd)":/Repo \
      --volume "$(pwd)/repo_template/config":/config \
      --volume $(System.DefaultWorkingDirectory)/KICSReports:/reports \
      --name kics \
      checkmarx/kics:latest scan \
      -m \
      --config /config/kics.config \
      --output-name kics-report-$(environment_tag) \
      --output-path /reports \
      --log-path /reports/kics.log
    condition: succeededOrFailed()
    displayName: Run Checkmarx KICS
    enabled: true
    name: "KICS_Scan"
    workingDirectory: "$(System.DefaultWorkingDirectory)"
  ```

As you can see the script step does the following:

* Creates a directory called *"KICSReports"*
* Pulls the latest official KICS docker image from Dockerhub
* Performs a scan of `$(System.DefaultWorkingDirectory)` scanning directories recursively and outputs the results in the following formats
  * asff
  * codeclimate
  * csv
  * cyclonedx
  * glsast
  * html
  * JSON
  * junit
  * pdf
  * Sarif
  * Sonarqube
The results are piped out to the created *"KICSReports"* directory with the files called `kics-Report-$(environment_tag).extension`

Once the scan has been ran the following steps are then also ran:

 ```yaml
  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: failed()
    displayName: 'Create work item'
    enabled: true
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review Checkmarx KICS failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/KICSReports/" # Optional
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

  #publish reports
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish KICS Reports"
    enabled: true
    name: "Publish_KICS_Reports"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/KICSReports"
      ArtifactName: "CheckmarxKICS-$(environment_tag)"
      publishLocation: "container"

  #copy sarif files to sarif directory to avoid polluting CodeAnalysisLogs
  - task: Powershell@2
    condition: succeededOrFailed()
    displayName: "Copy Sarif Files"
    enabled: true
    inputs:
      targetType: 'inline'
      script: |
        cd $(System.DefaultWorkingDirectory)/KICSReports
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

 #publish KICS Scan
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish KICS Scan"
    enabled: true
    name: "Publish_KICS_scan"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/KICSReports/sarif"
      ArtifactName: "CodeAnalysisLogs"
      publishLocation: "container"

  # Publish test results
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish KICS Test Results"
    enabled: true
    name: "Publish_KICS_Test_Results"
    inputs:
      testResultsFormat: "JUnit" # Options JUnit, NUnit, VSTest, xUnit, cTest
      testResultsFiles: "**/*junit-kics-report-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/KICSReports"
      mergeTestResults: false
      testRunTitle: "Checkmarx KICS Scan"
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "checkmarx/kics:latest" -f | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
    name: "Remove_terraform_Quality_Check_Docker_Images"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  ```

* If the scan has any failures a work item is created called `Review Checkmarx KICS failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
  * Pull requests are linked to the work item
  * All output from the scan is attached
* The reports and log are published as an artifact called `CheckmarxKICS-$(environment_tag)`
* Copies the sarif files to `$(System.DefaultWorkingDirectory)/KICSReports/sarif`
* Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
* The test results are published as a test run called `Checkmarx KICS Scan`
* the docker image is removed

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
[Checkmarx_KICS.yml]: ./build/pipelines/code_quality_templates/checkmarx_kics.yml
[Checkov.yml]: ./build/pipelines/code_quality_templates/checkov.yml
[Checkov_baseline_creator.yml]: ./build/pipelines/code_quality_templates/checkov_baseline_creator.yml
[GitHub_Super_Linter.yml]: ./build/pipelines/code_quality_templates/github_super_linter.yml
[Infracost.yml]: ./build/pipelines/code_quality_templates/Infracost.yml
[Mega_Linter.yml]: ./build/pipelines/code_quality_templates/mega_linter.yml
[OWASP.yml]: ./build/pipelines/code_quality_templates/owasp.yml
[TFComplianceCheck.yml]: ./build/pipelines/code_quality_templates/tfcompliancecheck.yml
[template_updater.yml]: ./build/pipelines/code_quality_templates/template_updater.yml
[Terrascan.yml]: ./build/pipelines/code_quality_templates/terrascan.yml
[TFLint.yml]: ./build/pipelines/code_quality_templates/tflint.yml
[TFSec.yml]: ./build/pipelines/code_quality_templates/tfsec.yml

<!-- IAC TEMPLATE LINKS-->
[terraform_apply.yml]: ./build/pipelines/iac_templates/terraform_apply.yml
[terraform_plan.yml]: ./build/pipelines/iac_templates/terraform_plan.yml
[variables.yml]: ./build/pipelines/iac_templates/variables.yml

<!-- PIPELINE LINKS -->
[infrastructure.yml]: ./build/pipelines/infrastructure.yml
[code_quality.yml]: ./build/pipelines/code_quality.yml

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
