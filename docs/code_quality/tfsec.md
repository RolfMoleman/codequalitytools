<!-- TFSec -->
# TFSec #

[![Home][Home_Image]][Code Quality]

> tfsec is a static analysis security scanner for your terraform code.
>
> Designed to run locally and in your CI pipelines, developer-friendly output and fully documented checks mean detection and remediation can take place as quickly and efficiently as possible
>
> tfsec takes a developer-first approach to scanning your terraform templates; using static analysis and deep integration with the official HCL parser it ensures that security issues can be detected before your infrastructure changes take effect.
>
> tfsec is an Aqua Security open source project.
> Learn about our open source work and portfolio here.
> Contact us about any matter by opening a GitHub Discussion here
>
> ## Features ##
>
> ☁️ Checks for misconfigurations across all major (and some minor) cloud providers
>
> ⛔ Hundreds of built-in rules
>
> 🪆 Scans modules (local and remote)
>
> ➕ Evaluates HCL expressions as well as literal values
>
> ↪️ Evaluates terraform functions e.g. concat()
>
> 🔗 Evaluates relationships between terraform resources
>
> 🧰 Compatible with the terraform CDK
>
> 🙅 Applies (and embellishes) user-defined Rego policies
>
> 📃 Supports multiple output formats: lovely (default), JSON, SARIF, CSV, CheckStyle, JUnit, text, Gif.
>
> 🛠️ Configurable (via CLI flags and/or config file)
>
> ⚡ Very fast, capable of quickly scanning huge repositories
>
> 🔌 Plugins for popular IDEs available (JetBrains, VSCode and Vim)

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

- [TFSec](#tfsec)
  - [Table of Contents](#table-of-contents)
    - [The stage templates](#the-stage-templates)

### The stage templates ###

The [TFSec.yml] Stage template looks as follows:

```yaml
steps:
  # TFSec uses static analysis of terraform templates to spot potential security issues, and checks for violations of AWS, Azure and GCP security best practice recommendations.
  # NOTE: To disable a specific check from analysis, include it in the command-line as follows: -e GEN001,GCP001,GCP002
  # Documentation: https://github.com/tfsec/tfsec
  - bash: |
      mkdir TFSecReport
      chmod a+w TFSecReport
      docker pull aquasec/tfsec:latest
      docker run \
      --volume $(pwd):/Repo \
      --volume $(System.DefaultWorkingDirectory)/TFSecReport:/reports \
      --name tfsec \
      aquasec/tfsec:latest \
      /Repo \
      --allow-checks-to-panic \
      --force-all-dirs \
      --format default,json,csv,checkstyle,junit,sarif,gif \
      --include-ignored \
      --include-passed \
      --out /reports/tfsec-report-$(environment_tag) \
      --verbose
    condition: succeededOrFailed()
    displayName: "TFSec Static Code Analysis"
    enabled: true
    name: "TFSec_Scan"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: failed()
    displayName: 'Create work item'
    enabled: true
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review TFSec failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/TFSecReport/" # Optional
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

  # Publish the TFSec report as an artifact to Azure Pipelines
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish TFSec Report"
    enabled: true
    name: "Publish_TFSec_Report"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/TFSecReport"
      ArtifactName: TFSecReport-$(environment_tag)

  #copy sarif files to sarif directory to avoid polluting CodeAnalysisLogs
  - task: Powershell@2
    condition: succeededOrFailed()
    displayName: "Copy Sarif Files"
    enabled: true
    inputs:
      targetType: 'inline'
      script: |
        cd $(System.DefaultWorkingDirectory)/TFSecReport
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

  #publish tfsec Scan
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish tfsec Scan"
    enabled: true
    name: "Publish_tfsec_scan"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/TFSecReport/sarif"
      ArtifactName: "CodeAnalysisLogs"
      publishLocation: "container"

  # Publish the results of the TFSec analysis as Test Results to the pipeline
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish TFSecReport Test Results"
    enabled: true
    name: "Publish_TFSec_Test_Results"
    inputs:
      testResultsFormat: "JUnit" # Options JUnit, NUnit, VSTest, xUnit, cTest
      testResultsFiles: "**/*TFSec-Report-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/TFSecReport"
      testRunTitle: "TFSec Scan"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "aquasec/tfsec:latest" -f | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
    name: "Remove_terraform_Quality_Check_Docker_Images"
    workingDirectory: "$(System.DefaultWorkingDirectory)"
     
```

As you can see the stage does the following:

- Creates a directory called *"TFSecReport"*
- Pulls the latest official TFSec docker image from Dockerhub (The tflint-bundle image contains all the latest plugins for the different cloud providers, else these have to be mounted separately)
- Performs a scan of `$(System.DefaultWorkingDirectory)` recursively and outputs the results in default, json, csv, checkstyle, junit and sarif format
- The results are piped out to the created *"TFSecReport"* directory with the file called `TFSec-Report-$(environment_tag).extension`

Once the scan has been ran the following steps are then also ran:

- If the scan has any failures a work item is created called `Review TFSec failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
  - Pull requests are linked to the work item
  - All output from the scan is attached
- The reports and log are published as an artifact called `TFSecReport-$(environment_tag)`
- Copies the sarif files to `$(System.DefaultWorkingDirectory)/TFSecReport/sarif`
- Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
- The test results are published as a test run called `TFSec Scan`
- the docker image is removed

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
[Checkmarx_KICS.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/checkmarx_kics.yml
[Checkov.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/checkov.yml
[Checkov_baseline_creator.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/checkov_baseline_creator.yml
[GitHub_Super_Linter.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/github_super_linter.yml
[Infracost.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/Infracost.yml
[Mega_Linter.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/mega_linter.yml
[OWASP.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/owasp.yml
[TFComplianceCheck.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/tfcompliancecheck.yml
[template_updater.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/template_updater.yml
[Terrascan.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/terrascan.yml
[TFLint.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/tflint.yml
[TFSec.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/tfsec.yml

<!-- IAC TEMPLATE LINKS-->
[terraform_apply.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/iac_templates/terraform_apply.yml
[terraform_plan.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/iac_templates/terraform_plan.yml
[variables.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/iac_templates/variables.yml

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
