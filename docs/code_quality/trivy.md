<!-- Trivy -->
# Trivy #

[![Home][Home_Image]][Code Quality]

> Trivy (tri pronounced like trigger, vy pronounced like envy) is a comprehensive security scanner. It is reliable, fast, extremely easy to use, and it works wherever you need it.
>
> Trivy is an Aqua Security open source project.
>
> Trivy has different scanners that look for different security issues, and different targets where it can find those issues.
>
> Targets:
>
> - Container Image
> - Filesystem
> - Git repository (remote)
> - Kubernetes cluster or resource
>
> Scanners:
>
> - OS packages and software dependencies in use (SBOM)
> - Known vulnerabilities (CVEs)
> - IaC misconfigurations
> - Sensitive information and secrets
>
> Read more in the [Trivy Documentation](https://aquasecurity.github.io/trivy/v0.32/)

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

- [Trivy](#trivy)
  - [Table of Contents](#table-of-contents)
    - [The stage templates](#the-stage-templates)

### The stage templates ###

The [trivy.yml] Stage template looks as follows:

```yaml
steps:

  - task: Cache@2
    inputs:
      key: docker | "aquasec/trivy:latest"
      path: $(Pipeline.Workspace)/docker
      cacheHitVar: DOCKER_CACHE_HIT
    condition: succeededOrFailed()
    displayName: Cache Docker images
    enabled: true
    name: "cache_docker"

  - script: |
              docker load -i $(Pipeline.Workspace)/docker/cache.tar
    condition: and(not(canceled()), eq(variables.DOCKER_CACHE_HIT, 'true'))
    continueOnError: true
    displayName: Restore Docker image
    enabled: true
    name: "load_dockercache"

  - script: |
      mkdir TrivyScanReport
      chmod a+w TrivyScanReport
      outputTypes=("default" "html" "json" "junit" "sarif" "screen" "table")
      
      for str in ${outputTypes[@]}; do
        
        if [[ "$str" == "default" ]]; then
        echo "Performing Trivy scan with output type of: ${str} "
          docker run \
          --volume $(pwd):/repo \
          --volume $(System.DefaultWorkingDirectory)/TrivyScanReport:/reports \
          --volume /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy:latest filesystem \
          --output /reports/Trivy-Report-$(environment_tag).txt \
          --security-checks vuln,config,secret,license \
          --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
          --vuln-type os,library \
          --license-full \
          /repo

        elif [[ "$str" == "html" ]]; then
          echo "Performing Trivy scan with output type of: ${str} "
          docker run \
          --volume $(pwd):/repo \
          --volume $(System.DefaultWorkingDirectory)/TrivyScanReport:/reports \
          --volume /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy:latest filesystem \
          --format template \
          --template "@contrib/html.tpl" \
          --output /reports/Trivy-Report-$(environment_tag).xml \
          --list-all-pkgs \
          --security-checks vuln,config,secret,license \
          --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
          --vuln-type os,library \
          --license-full \
          /repo

        elif [[ "$str" == "json" ]]; then
          echo "Performing Trivy scan with output type of: ${str} "
          docker run \
          --volume $(pwd):/repo \
          --volume $(System.DefaultWorkingDirectory)/TrivyScanReport:/reports \
          --volume /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy:latest filesystem \
          --format $str \
          --output /reports/Trivy-Report-$(environment_tag).json \
          --list-all-pkgs \
          --security-checks vuln,config,secret,license \
          --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
          --vuln-type os,library \
          --license-full \
          /repo

        elif [[ "$str" == "junit" ]]; then
          echo "Performing Trivy scan with output type of: ${str} "
          docker run \
          --volume $(pwd):/repo \
          --volume $(System.DefaultWorkingDirectory)/TrivyScanReport:/reports \
          --volume /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy:latest filesystem \
          --format template \
          --template "@contrib/junit.tpl" \
          --output /reports/Trivy-Report-$(environment_tag).xml \
          --list-all-pkgs \
          --security-checks vuln,config,secret,license \
          --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
          --vuln-type os,library \
          --license-full \
          /repo

        elif [[ "$str" == "sarif" ]]; then
          echo "Performing Trivy scan with output type of: ${str} "
          docker run \
          --volume $(pwd):/repo \
          --volume $(System.DefaultWorkingDirectory)/TrivyScanReport:/reports \
          --volume /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy:latest filesystem \
          --format $str \
          --output /reports/Trivy-Report-$(environment_tag).sarif \
          --list-all-pkgs \
          --security-checks vuln,config,secret,license \
          --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
          --vuln-type os,library \
          --license-full \
          /repo
          
        elif [[ "$str" == "screen" ]]; then
          echo "Performing Trivy scan with output type of: ${str} "
          docker run \
          --volume $(pwd):/repo \
          --volume $(System.DefaultWorkingDirectory)/TrivyScanReport:/reports \
          --volume /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy:latest filesystem \
          --security-checks vuln,config,secret,license \
          --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
          --vuln-type os,library \
          --license-full \
          /repo

        elif [[ "$str" == "table" ]]; then
          echo "Performing Trivy scan with output type of: ${str} "
          docker run \
          --volume $(pwd):/repo \
          --volume $(System.DefaultWorkingDirectory)/TrivyScanReport:/reports \
          --volume /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy:latest filesystem \
          --format $str \
          --output /reports/Trivy-Report-table-$(environment_tag).txt \
          --security-checks vuln,config,secret,license \
          --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
          --vuln-type os,library \
          --license-full \
          /repo
          
      else
          echo "output type not known"
      fi
      done
    condition: succeededOrFailed()
    displayName: "Trivy Scan Report"
    enabled: true
    name: "Trivy_Scan"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  - script: |
      Write-Host ("##vso[task.setvariable variable=task.Trivy_Scan.status]failure")             
    condition: failed()
    continueOnError: true
    displayName: Trivy failure check
    enabled: true
    name: "if_trivyfail"

  - script: |
      mkdir -p $(Pipeline.Workspace)/docker
      docker save --output $(Pipeline.Workspace)/docker/cache.tar aquasec/trivy:latest              
    condition: and(not(canceled()), or(failed(), ne(variables.DOCKER_CACHE_HIT, 'true')))
    continueOnError: true
    displayName: Save Docker image
    enabled: true
    name: "save_dockerimage"

  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: and(eq(variables['task.Trivy_Scan.status'], 'failure'), succeededOrFailed())
    displayName: 'Create work item'
    enabled: true
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review Trivy failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/TrivyScanReport/" # Optional
      attachments: '*.*' # Required if addAttachments = true
      # ===== Duplicate Inputs =====
      preventDuplicates: true
      keyFields: |
        System.AreaPath
        System.IterationPath
        System.Title 
      updateDuplicates: true # Optional
      #updateRules: # Optional
      # ===== Outputs Inputs =====
      createOutputs: true # Optional
      outputVariables: 'workItemId=ID' # Required if createOutputs = true
      # ===== Advanced Inputs =====
      #authToken: #Optional
      #allowRedirectDowngrade: false # Optional

#publish trivy Scan
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish Trivy Scan"
    enabled: true
    name: "Publish_trivy_report"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/TrivyScanReport/"
      ArtifactName: "TrivyReport-$(environment_tag)"
      publishLocation: "container"

  #copy sarif files to sarif directory to avoid polluting CodeAnalysisLogs
  - task: Powershell@2
    condition: succeededOrFailed()
    displayName: "Copy Sarif Files"
    enabled: true
    inputs:
      targetType: 'inline'
      script: |
        cd $(System.DefaultWorkingDirectory)/TrivyScanReport
        $files = dir
        mkdir sarif
        ForEach($file in $files)
        {
          if($file.extension.Contains("sarif"))
          {
              Copy-Item -Path $file.FullName -Destination sarif -force
          }
          else
          {
              Write-output $file.FullName "does not need moving"
          }      
        }
      showWarnings: true
      pwsh: true
      workingDirectory: '$(System.DefaultWorkingDirectory)'

  #publish trivy Scan Results
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish Trivy Scan"
    enabled: true
    name: "Publish_trivy_scan"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/TrivyScanReport/sarif"
      ArtifactName: "CodeAnalysisLogs"
      publishLocation: "container"

  # Publish the results of the Trivy analysis as Test Results to the pipeline
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish Trivy Test Results"
    enabled: true
    name: "Publish_trivy_Test_Results"
    inputs:
      testResultsFormat: "junit" # Options JUnit, NUnit, VSTest, xUnit, cTest
      testResultsFiles: "**/*Trivy-Report-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/TrivyScanReport"
      testRunTitle: "Trivy Scan"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "aquasec/trivy:latest" --format | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
    name: "Remove_terraform_Quality_Check_Docker_Images"
    workingDirectory: "$(System.DefaultWorkingDirectory)"
     
```

As you can see the stage does the following:

- Caches the latest Trivy docker image
- Attempts to load the latest Trivy docker image from cache
- Creates a directory called *"TrivyScanReport"*
- Performs a scan of `$(System.DefaultWorkingDirectory)` recursively and outputs the results in default, json, table, junit, Sarif and screen formats
- The results are piped out to the created *"TrivyScanReport"* directory with the file called `Trivy-Report-$(environment_tag).extension`

Once the scan has been ran the following steps are then also ran:

- If the scan has any failures a work item is created called `Review Trivy failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
  - Pull requests are linked to the work item
  - All output from the scan is attached
- The docker image is saved to the cache to speed up subsequent runs
- The reports and log are published as an artifact called `TrivyReport-$(environment_tag)`
- Copies the sarif files to `$(System.DefaultWorkingDirectory)/TrivyScanReport/sarif`
- Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
- The test results are published as a test run called `Trivy Scan`
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
[Trivy]: ./docs/code_quality/trivy.md
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
[trivy.yml]: /repo_template/build/pipelines/repo_template/build/pipelines/code_quality_templates/trivy.yml

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
