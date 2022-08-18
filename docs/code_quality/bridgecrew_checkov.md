
[![Home][Home_Image]][Code Quality]

<!-- Checkov -->
# Checkov #

> Is a static code analysis tool for infrastructure-as-code.
>
> It scans cloud infrastructure provisioned using terraform, terraform plan, Cloudformation, AWS SAM, Kubernetes, Helm charts,Kustomize, Dockerfile, Serverless, Bicep, OpenAPI or ARM Templates and detects security and compliance misconfigurations using graph-based scanning.
>
> Checkov also powers Bridgecrew, the developer-first platform that codifies and streamlines cloud security throughout the development lifecycle. Bridgecrew identifies, fixes, and prevents misconfigurations in cloud resources and infrastructure-as-code files.

## Prerequisites ##

In order to use with Bridgecrew or Prismacloud you will need to set the following variables

* `$(bridgecrewkey)` - this needs to be set via your library group/keyvault that is picked up by the [variables.yml] You will need to obtain an api key from bridgecrew or alternatively obtain an access key and secret key from Prismacloud. This must be in the format `<accesskey>::<secretkey>` as specified in their documentation
* `$(project_repo)` - this is set via [variables.yml] and needs to be updated to match your repository name
* `$(repo_branch)` - this is set via [variables.yml]
* `$(prisma_api_url)` - this is set via [variables.yml]

### The stage templates ###

There are two different Checkov stage templates. these are:

* [Checkov.yml]
* [Checkov_baseline_creator.yml]

The only difference between these is that [Checkov_baseline_creator.yml] adds the `--create-baseline` flag which combined with the `git commit -m "Adding or updating baseline [skip ci]"` command adds a `.checkov.baseline` file to the root of the Repo. This enables the use of the `--baseline` flag in subsequent scans to compare current results with a the baseline. The output report will then only include failed checks that are new with respect to the provided baseline.

As such this is not currently setup in the [code_quality.yml] pipeline.

The [Checkov.yml] Stage template looks as follows:

 ```yml
steps:
  # Checkov is a static code analysis tool for infrastructure-as-code.
  # It scans cloud infrastructure provisioned using terraform, Cloudformation, Kubernetes, Serverless and ARM Templates and detects security and compliance misconfigurations.
  # Documentation: https://github.com/bridgecrewio/checkov
  # NOTE: If you want to skip a specific check from the analysis, include it in the command-line as follows: --skip-check CKV_AWS_70,CKV_AWS_52,CKV_AWS_21,CKV_AWS_18,CKV_AWS_19
  - script: |
      mkdir CheckovReports
      docker pull bridgecrew/checkov:latest
      echo "bridgecrewkey variable is set so running checkov with bridgecrew integration"
      echo "Output bridgecrew variables"
      echo "--Repo-id: $(project_repo)"
      echo "--branch: $(repo_branch)"
      echo "--prisma-api-url: $(prisma_api_url)"
      docker run \
      --volume "$(pwd)":/Repo \
      --volume $(System.DefaultWorkingDirectory)/CheckovReports:/reports \
      --name bridgecrew \
      bridgecrew/checkov:latest \
      --bc-api-key $(bridgecrewkey) \
      --branch "$(repo_branch)" \
      --directory /Repo \
      --include-all-checkov-policies \
      --output cli \
      --output cyclonedx \
      --output json \
      --output junitxml \
      --output sarif \
      --output-file-path /reports \
      --prisma-api-url $(prisma_api_url) \
      --Repo-id "$(project_repo)"
    condition: ne(variables['BRIDGECREWKEY'], '')
    displayName: "Bridgecrew Static Code Analysis"
    enabled: false
    name: "Bridgecrew_Scan"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  - script: |
      mkdir CheckovReports
      docker pull bridgecrew/checkov:latest
      echo "bridgecrewkey variable is not set so running normal checkov"
      docker run \
      --volume "$(pwd)":/Repo \
      --volume $(System.DefaultWorkingDirectory)/CheckovReports:/reports \
      --name checkov \
      bridgecrew/checkov:latest \
      --directory /Repo \
      --include-all-checkov-policies \
      --output cli \
      --output cyclonedx \
      --output json \
      --output junitxml \
      --output sarif \
      --output-file-path /reports
    #condition: eq(variables['BRIDGECREWKEY'], '')
    condition: succeededOrFailed()
    displayName: "Checkov Static Code Analysis"
    enabled: true
    name: "Checkov_Scan"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  #give reports a more unique name
  - bash: |
      cd CheckovReports
      for file in results_*; do
        echo "Processing $File"
        mv "$file" "${file/results_/Checkov-Report-$(environment_tag)-}"
      done
      echo "CheckovReports DIR Content:"
      ls -la
    condition: succeededOrFailed()
    displayName: "Rename Checkov Reports"
    enabled: true
    name: "Rename_Checkov_Reports"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: and(failed(), ne(variables['BRIDGECREWKEY'], ''))
    displayName: 'Create work item'
    enabled: false
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review Bridgecrew failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/CheckovReports/" # Optional
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

  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: failed()
    #condition: and(failed(), eq(variables['BRIDGECREWKEY'], ''))
    displayName: 'Create work item'
    enabled: true
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review Checkov failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/CheckovReports/" # Optional
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

  # Publish the Checkov report as an artifact to Azure Pipelines
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish Artifact: Checkov Report"
    enabled: true
    name: "Publish_checkov_report"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/CheckovReports"
      ArtifactName: CheckovReport-$(environment_tag)

  #copy sarif files to sarif directory to avoid polluting CodeAnalysisLogs
  - task: Powershell@2
    condition: succeededOrFailed()
    displayName: "Copy Sarif Files"
    enabled: true
    inputs:
      targetType: 'inline'
      script: |
        cd $(System.DefaultWorkingDirectory)/CheckovReports
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

  #publish checkov Scan
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish checkov Scan"
    enabled: true
    name: "Publish_checkov_scan"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/CheckovReports/sarif"
      ArtifactName: "CodeAnalysisLogs"
      publishLocation: "container"

  # Publish the results of the Checkov analysis as Test Results to the pipeline
  # NOTE: There is a current issue with the produced XML that fails to publish the test results correctly. Work-around is to include the Script step to remove the last 2 lines from the file before processing.
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish Checkov Test Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit" # Options JUnit, NUnit, VSTest, xUnit, cTest
      testResultsFiles: "**/*Checkov-Report-$(environment_tag)-junitxml.xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/CheckovReports"
      mergeTestResults: false
      testRunTitle: Checkov Scan
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "bridgecrew/checkov:latest" -f | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
    name: "Remove_terraform_Quality_Check_Docker_Images"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  ```

As you can see the stage does the following:

* If the `$(bridgecrewkey)` variable is set
  * Runs a scan called `"Bridgecrew Static Code Analysis"`
  * Creates a directory called *"CheckovReports"*
  * Pulls the latest official Checkov docker image from Dockerhub
  * Outputs the values of `$(project_repo)` `$(repo_branch)` and `$(prisma_api_url)`
  * Performs a scan of `$(System.DefaultWorkingDirectory)` scanning directories recursively and outputs the results in cli, cyclonedx, json, junitxml and sarif formats
  * The results are piped out to the created *"CheckovReports"* directory with the naming convention `Checkov-Report-$(environment_tag).extension`
  * The results are uploaded to bridgecrew
  * If the scan has any failures a work item is created called `Review Bridgecrew failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
    * Pull requests are linked to the work item
    * All output from the scan is attached
  * The reports and log are published as an artifact called `CheckovReport-$(environment_tag)`
  * Copies the sarif files to `$(System.DefaultWorkingDirectory)/CheckovReports/sarif`
  * Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
  * The test results are published as a test run called `Checkov Scan`
  * the docker image is removed

* If the `$(bridgecrewkey)` variable is **not** set
  * Pulls the latest official Checkov docker image from Dockerhub
  * Performs a scan of `$(System.DefaultWorkingDirectory)` scanning directories recursively and outputs the results in cli, cyclonedx, json, junitxml and sarif formats
  * The results are piped out to the created *"CheckovReports"* directory with the naming convention `Checkov-Report-$(environment_tag).extension`
  * If the scan has any failures a work item is created called `Review Checkov failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
    * Pull requests are linked to the work item
    * All output from the scan is attached
  * The reports and log are published as an artifact called `CheckovReport-$(environment_tag)`
  * Copies the sarif files to `$(System.DefaultWorkingDirectory)/CheckovReports/sarif`
  * Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
  * The test results are published as a test run called `Checkov Scan`
  * the docker image is removed

#### Options ####

there are also some additional options that can be added to the Checkov scan that you may find of use. The main ones are:

* The `--bc-api-key` flag which enables the checkov scan to integrate with Bridgecrew via the Bridgecrew api key. You can also Pass in the Prisma Cloud api key via the same flag
* The `--create-baseline` flag which creates a `.checkov.baseline` baseline file. However, please note if you use the baseline as part of any future scans it will ignore any violated policies that were violated int eh baseline and will instead only report on any new violations.
* The `--baseline` flag which is used to declare the location fo the baseline file as part of a scan once it has been created.
* The `--output-bc-ids` flag can be used to output the Bridgecrew platform policy ids as opposed to the Checkov ones
* The `--Repo-id` flag allows you to include an identifying string for the repository to match that in Bridgecrew
* The `-b` or `--branch` flag allows you to target a specific branch of the Repo

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

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
[logo-image]: ../repo_template-images/logo.png
[pipeline-screenshot]: ../repo_template-images/pipeline-screenshot.png
[product-screenshot]: ../repo_template-images/screenshot.png
[teams-icon]: ../repo_template-images/teams.png

<!-- MARKDOWN DOCUMENT LINKS -->
[Code Quality]: ./docs/code_quality.md
[Bridgecrew_Checkov]: ./docs/code_quality/bridgecrew_checkov.md
[Checkmarx_KICS]: ./docs/code_quality/checkmarx_kics.md
[GitHub_Super_Linter]: ./docs/code_quality/github_super_linter.md
[Infracost]: ./docs/code_quality/Infracost.md
[Megalinter]: ./docs/code_quality/megalinter.md
[Mend_Bolt]: ./docs/code_quality/mend_bolt.md
[OWASP]: ./docs/code_quality/owasp.md
[Sonar_Cloud]: ./docs/code_quality/sonar_cloud.md
[Template_updater]: ./docs/code_quality/template_updater.md
[terraform_Compliance]: ./docs/code_quality/terraform_compliance.md
[Terrascan]: ./docs/code_quality/terrascan.md
[TFLint]: ./docs/code_quality/tflint.md
[TFSec]: ./docs/code_quality/tfsec.md

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
