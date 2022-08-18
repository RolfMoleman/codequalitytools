<!-- Tflint -->
# Tflint #

[![Home][Home_Image]][Code Quality]

> TFLint is a framework and each feature is provided by plugins, the key features are as follows:
>
> * Find possible errors (like illegal instance types) for Major Cloud providers (AWS/Azure/GCP).
> * Warn about deprecated syntax, unused declarations.
> * Enforce best practices, naming conventions.

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

* [Tflint](#tflint)
  * [Table of Contents](#table-of-contents)
  * [Prerequisites](#prerequisites)
    * [The stage templates](#the-stage-templates)

## Prerequisites ##

TFLint relies on the `.tflint.hcl` config file in the directory where the terraform files reside. In this folder structure it is located at `./build/terraform`

### The stage templates ###

The [TFLint.yml] Stage template looks as follows:

```yaml
steps:
  # TFLint is a framework that finds possible errors (like illegal instance types) for major cloud providers (AWS/Azure/GCP), warn about deprecated syntax, unused declarations, and enforce best practices, naming conventions.
  - task: qetza.replacetokens.replacetokens-task.replacetokens@5
    condition: succeededOrFailed()
    displayName: "Replace variablised versions in terraform"
    enabled: true
    name: "Terraform_Version_replacement"
    inputs:
        rootDirectory: '$(System.DefaultWorkingDirectory)/repo_template/build/terraform'
        targetFiles: '**/*.tf'
        encoding: 'auto'
        tokenPattern: 'rm'
        writeBOM: true
        escapeType: 'none'
        actionOnMissing: 'fail'
        keepToken: true
        actionOnNoFiles: 'warn'
        enableTransforms: false
        enableRecursion: false
        useLegacyPattern: false
        enableTelemetry: true
  - script: |
      mkdir TFLintReport
      docker pull ghcr.io/terraform-linters/tflint-bundle:latest
      outputTypes=("default" "json" "checkstyle" "junit" "compact" "sarif")
      
            for str in ${outputTypes[@]}; do
        
        if [[ "$str" == "default" ]]; then
          docker run \
            --volume $(pwd)/repo_template/build/terraform:/data \
            ghcr.io/terraform-linters/tflint-bundle:latest \
            --color \
            --format $str > $(System.DefaultWorkingDirectory)/TFLintReport/TFLint-$str-report-$(environment_tag).txt

        elif [[ "$str" == "json" ]]; then
          docker run \
            --volume $(pwd)/repo_template/build/terraform:/data \
            ghcr.io/terraform-linters/tflint-bundle:latest \
            --color \
            --format $str > $(System.DefaultWorkingDirectory)/TFLintReport/TFLint-$str-report-$(environment_tag).json
        elif [[ "$str" == "checkstyle" ]]; then
            docker run \
            --volume $(pwd)/repo_template/build/terraform:/data \
            ghcr.io/terraform-linters/tflint-bundle:latest \
            --color \
            --format $str > $(System.DefaultWorkingDirectory)/TFLintReport/TFLint-$str-report-$(environment_tag).txt
        elif [[ "$str" == "junit" ]]; then
            docker run \
            --volume $(pwd)/repo_template/build/terraform:/data \
            ghcr.io/terraform-linters/tflint-bundle:latest \
            --color \
            --format $str > $(System.DefaultWorkingDirectory)/TFLintReport/TFLint-$str-report-$(environment_tag).xml
        elif [[ "$str" == "compact" ]]; then
            docker run \
            --volume $(pwd)/repo_template/build/terraform:/data \
            ghcr.io/terraform-linters/tflint-bundle:latest \
            --color \
            --format $str > $(System.DefaultWorkingDirectory)/TFLintReport/TFLint-$str-report-$(environment_tag).txt
        elif [[ "$str" == "sarif" ]]; then
          docker run \
            --volume $(pwd)/repo_template/build/terraform:/data \
            ghcr.io/terraform-linters/tflint-bundle:latest \
            --color \
            --format $str > $(System.DefaultWorkingDirectory)/TFLintReport/TFLint-$str-report-$(environment_tag).sarif
      else
          echo "output type not known"
      fi
      done
    condition: succeededOrFailed()
    displayName: "TFLint Static Code Analysis"
    enabled: true
    name: "TFLint_Scan"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: failed()
    displayName: 'Create work item'
    enabled: true
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review TFLint failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/TFLintReport/" # Optional
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

  # Publish the TFLint report as an artifact to Azure Pipelines
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish TFLint Report"
    enabled: true
    name: "Publish_TFLint_Report"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/TFLintReport"
      ArtifactName: TFLintReport-$(environment_tag)

  #copy sarif files to sarif directory to avoid polluting CodeAnalysisLogs
  - task: Powershell@2
    condition: succeededOrFailed()
    displayName: "Copy Sarif Files"
    enabled: true
    inputs:
      targetType: 'inline'
      script: |
        cd $(System.DefaultWorkingDirectory)/TFLintReport
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

  #publish tflint Scan
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish tflint Scan"
    enabled: true
    name: "Publish_tflint_scan"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/TFLintReport/sarif"
      ArtifactName: "CodeAnalysisLogs"
      publishLocation: "container"

  # Publish the results of the TFLint analysis as Test Results to the pipeline
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish TFLint Test Results"
    enabled: true
    name: "Publish_TFLint_Test_Results"
    inputs:
      testResultsFormat: "JUnit" # Options JUnit, NUnit, VSTest, xUnit, cTest
      testResultsFiles: "**/*TFLint-junit-report-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/TFLintReport"
      mergeTestResults: false
      testRunTitle: "TFLint Scan"
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "ghcr.io/terraform-linters/tflint-bundle:latest" -f | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
    name: "Remove_terraform_Quality_Check_Docker_Images"
    workingDirectory: "$(System.DefaultWorkingDirectory)"
    
```

As you can see the stage does the following:

* Creates a directory called *"TFLintReport"*
* Pulls the latest official TFLint-bundle docker image from Dockerhub (The tflint-bundle image contains all the latest plugins for the different cloud providers, else these have to be mounted separately)
* Performs a scan of `$(System.DefaultWorkingDirectory)/repo_template/build/terraform` **(Does not scan recursively)** and outputs the results in Junit format
* The results are piped out to the created *"TFLintReport"* directory with the file called `TFLint-Report-$(environment_tag).xml`
* A secondary scan is ran to output the results in Sarif format
* The results are piped out to the created *"TFLintReport"* directory with the file called `TFLint-Report-$(environment_tag).Sarif`
* A third scan is then ran to publish the results to the console - (this could always be removed).

Once the scan has been ran the following steps are then also ran:

* If the scan has any failures a work item is created called `Review TFLint failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
  * Pull requests are linked to the work item
  * All output from the scan is attached
* The reports and log are published as an artifact called `TFLintReport-$(environment_tag)`
* Copies the sarif files to `$(System.DefaultWorkingDirectory)/TFLintReport/sarif`
* Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
* The test results are published as a test run called `TFLint Scan`
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
