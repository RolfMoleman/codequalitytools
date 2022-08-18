<!-- terraform Compliance -->
# Terraform Compliance #

[![Home][Home_Image]][Code Quality]

>terraform-compliance is a lightweight, security and compliance focused test framework against terraform to enable negative testing capability for your infrastructure-as-code.
>
> * **compliance:** Ensure the implemented code is following security standards, your own custom standards
> * **behaviour driven development:** We have BDD for nearly everything, why not for IaC ?
> * **portable:** just install it from pip or run it via docker. See Installation
> * **pre-deploy:** it validates your code before it is deployed
> * **provider agnostic:** it works with any provider
> * **easy to integrate:** it can run in your pipeline (or in git hooks) to ensure all deployments are validated
> * **segregation of duty:** you can keep your tests in a different repository where a separate team is responsible
> * **why ?:** why not ?

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

* [Terraform Compliance](#terraform-compliance)
  * [Table of Contents](#table-of-contents)
  * [Prerequisites](#prerequisites)
    * [The stage template](#the-stage-template)

## Prerequisites ##

terraform Compliance relies on a terraform plan file in json format.

### The stage template ###

The [TFComplianceCheck.yml] Stage template looks as follows:

```yaml
steps:
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
  
  - task: terraformInstaller@0
    condition: succeededOrFailed()
    displayName: 'Install terraform version 1.2.2'
    enabled: true
    inputs:
      terraformVersion: '$(terraform_installer_version)'

  - script: |
      terraform init \
        -backend-config="resource_group_name=$(resource-group)" \
        -backend-config="storage_account_name=$(storage-account)" \
        -backend-config="container_name=$(container-name)" \
        -backend-config="key=$(state-key)" \
        -backend-config="access_key=$(access-key)"
    condition: succeeded()
    displayName: 'terraform init'
    enabled: true
    workingDirectory: "repo_template/build/terraform"

  - script: |
      terraform validate
    workingDirectory: "repo_template/build/terraform"
    condition: succeeded()
    displayName: "terraform validate"
    enabled: true
    name: "terraform_validate"

  - script: |
      terraform show -json plan_$(environment_tag) > plan_$(environment_tag).json
    workingDirectory: "repo_template/build/terraform"
    condition: succeeded()
    displayName: "terraform plan json"
    enabled: true
    name: "terraform_plan_json"

  # NOTE: have to run scan twice, once to receive the output (which does not show in terminal), and a second time for terminal display
  - script: |
      mkdir terraformComplianceReport
      docker pull eerkunt/terraform-compliance:latest
      docker run \
      --volume $(pwd):/target \
      --name TFComply \
      --interactive eerkunt/terraform-compliance:latest \
      --with-coverage \
      --cover-html TFCompliance-coverage-$(environment_tag).html \
      --cucumber-json TFCompliance-cucumber-$(environment_tag).json \
      --junit-xml TFCompliance-Report-$(environment_tag).xml \
      --features git:https://github.com/terraform-compliance/user-friendly-features.git \
      --planfile plan_$(environment_tag).json
      TFCompSuccess=$?
      docker cp TFComply:/target/TFCompliance-*.* $(System.DefaultWorkingDirectory)/terraformComplianceReport
      exit $TFCompSuccess
    condition: succeededOrFailed()
    displayName: "terraform Compliance Check"
    enabled: true
    name: "terraformCompliance"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: failed()
    displayName: 'Create work item'
    enabled: true
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review terraform Compliance Check failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/terraformComplianceReport/" # Optional
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

  # NOTE: This does not work yet, as the output is not formatted correctly
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish terraformCompliance Test Results"
    enabled: true
    name: "Publish_terraformCompliance_Test_Results"
    inputs:
      testResultsFormat: "JUnit" # Options JUnit, NUnit, VSTest, xUnit, cTest
      testResultsFiles: "**/*TFCompliance-Report-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/terraformComplianceReport"
      mergeTestResults: false
      testRunTitle: terraformCompliance Scan
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # NOTE: Nothing to publish until outputs can be received
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish terraformCompliance Report"
    enabled: true
    name: "Publish_terraformCompliance_Report"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/terraformComplianceReport"
      ArtifactName: terraformComplianceReport-$(environment_tag)

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "eerkunt/terraform-compliance:latest" -f | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
    name: "Remove_terraform_Quality_Check_Docker_Images"
    workingDirectory: "$(System.DefaultWorkingDirectory)"
    
     
```

As you can see the stage does the following:

* Installs a specified version of terraform, at the time of writing this is version `1.2.2`
* Initialises terraform in the `/build/terraform` directory
* Runs a terraform validate
* Runs a terraform show against the plan in order to output the plan as a json file
* Creates a directory called *"terraformComplianceReport"*
* Pulls the latest official terraform-compliance docker image from Dockerhub
* Performs a scan of a plan file called `plan_$(environment_tag).json` outputs the results in Junit format
* The results are piped out to the created *"terraformComplianceReport"* directory with the file called `TFLint-Report-$(environment_tag).xml`
* Al;so outputs a Cucumber json file and a HTML code coverage report to *"terraformComplianceReport"* directory.

Once the scan has been ran the following steps are then also ran:

* If the scan has any failures a work item is created called `Review terraform Compliance Check failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
  * Pull requests are linked to the work item
  * All output from the scan is attached
* The reports and log are published as an artifact called `terraformComplianceReport-$(environment_tag)`
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
