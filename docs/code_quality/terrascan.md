<!-- Terrascan -->
# Terrascan #

[![Home][Home_Image]][Code Quality]

> is a static code analyzer for Infrastructure as Code. Terrascan allows you to:
>
> * Seamlessly scan infrastructure as code for misconfigurations.
> * Monitor provisioned cloud infrastructure for configuration changes that introduce posture drift, and enables reverting to * a secure posture.
> * Detect security vulnerabilities and compliance violations.
> * Mitigate risks before provisioning cloud native infrastructure.
> * Offers flexibility to run locally or integrate with your CI\CD.

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

* [Terrascan](#terrascan)
  * [Table of Contents](#table-of-contents)
  * [The stage templates](#the-stage-templates)

## The stage templates ##

The [Terrascan.yml] Stage template looks as follows:

```yaml
steps:
  # install terrascan docker image, run scan and generate report in human,junit and sarif formats
  - script: |
      mkdir terrascanreports
      docker pull tenable/terrascan:latest
      outputTypes=("human" "json" "junit-xml" "sarif" "yaml")
      
      for str in ${outputTypes[@]}; do
        
      if [[ "$str" == "human" ]]; then
        docker run \
          --volume "$(pwd)"/:/Repo \
          --volume $(pwd)/terrascanreports:/reports \
          --workdir /Repo \
          tenable/terrascan:latest \
          scan \
          --verbose \
          --show-passed \
          --log-output-dir /reports \
          --output $str 
      elif [[ "$str" == "json" ]]; then
        docker run \
          --volume "$(pwd)"/:/Repo \
          --volume $(pwd)/terrascanreports:/reports \
          --workdir /Repo \
          tenable/terrascan:latest \
          scan \
          --verbose \
          --show-passed \
          --log-output-dir /reports \
          --output $str 
      elif [[ "$str" == "junit-xml" ]]; then
        docker run \
          --volume "$(pwd)"/:/Repo \
          --volume $(pwd)/terrascanreports:/reports \
          --workdir /Repo \
          tenable/terrascan:latest \
          scan \
          --verbose \
          --show-passed \
          --log-output-dir /reports \
          --output $str 
      elif [[ "$str" == "sarif" ]]; then
        docker run \
          --volume "$(pwd)"/:/Repo \
          --volume $(pwd)/terrascanreports:/reports \
          --workdir /Repo \
          tenable/terrascan:latest \
          scan \
          --verbose \
          --show-passed \
          --log-output-dir /reports \
          --output $str 
      elif [[ "$str" == "xml" ]]; then
        docker run \
          --volume "$(pwd)"/:/Repo \
          --volume $(pwd)/terrascanreports:/reports \
          --workdir /Repo \
          tenable/terrascan:latest \
          scan \
          --verbose \
          --show-passed \
          --log-output-dir /reports \
          --output $str 
      elif [[ "$str" == "yaml" ]]; then
        docker run \
          --volume "$(pwd)"/:/Repo \
          --volume $(pwd)/terrascanreports:/reports \
          --workdir /Repo \
          tenable/terrascan:latest \
          scan \
          --verbose \
          --show-passed \
          --log-output-dir /reports \
          --output $str 
      else
        echo "output type not known"
      fi
      done
    condition: succeededOrFailed()
    displayName: "tenable TerraScan Code Analysis"
    enabled: true
    name: "tenable_TerraScan_Code_Analysis"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: failed()
    displayName: 'Create work item'
    enabled: true
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review TerraScan failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/terrascanreports/" # Optional
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

  # Publish the TerraScan report as an artifact to Azure Pipelines
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish Terrascan Reports"
    enabled: true
    name: "Publish_Terrascan_Reports"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/terrascanreports"
      ArtifactName: TerrascanReport-$(environment_tag)

  #copy sarif files to sarif directory to avoid polluting CodeAnalysisLogs
  - task: Powershell@2
    condition: succeededOrFailed()
    displayName: "Copy Sarif Files"
    enabled: true
    inputs:
      targetType: 'inline'
      script: |
        cd $(System.DefaultWorkingDirectory)/terrascanreports
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

 #publish Terrascan Scan
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish Terrascan Scan"
    enabled: true
    name: "Publish_Terrascan_scan"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/terrascanreports/sarif"
      ArtifactName: "CodeAnalysisLogs"
      publishLocation: "container"

  # publish the test results
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish Terrascan Test Results"
    enabled: true
    name: "Publish_Terrascan_Test_Results"
    inputs:
      testResultsFormat: "JUnit" # Options JUnit, NUnit, VSTest, xUnit, cTest
      testResultsFiles: "**/*TerraScan-Report-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/terrascanreports"
      mergeTestResults: false
      testRunTitle: "Terrascan Scan"
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "tenable/terrascan:latest" -f | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
    name: "Remove_terraform_Quality_Check_Docker_Images"
    workingDirectory: "$(System.DefaultWorkingDirectory)"
    
```

As you can see the stage does the following:

* Creates a directory called *"terrascanreports"*
* Pulls the latest official Terrascan docker image from Dockerhub
* Performs a scan of `$(System.DefaultWorkingDirectory)` **(Does not scan recursively)** and outputs the results in Junit and sarif format
* The results are piped out to the created *"terrascanreports"* directory with the file called `TerraScan-Report-$(environment_tag)`

Terrascan differs from the other tools, in that because it doesn't like directory names to have a leading `.` it is set to mount `$(System.DefaultWorkingDirectory)/build/` as a volume called `/Repo/build`as opposed to just `$(System.DefaultWorkingDirectory)` as it does not seem to like scanning recursively beneath folders prefixed with a dot, and will fail or give a false positive if no .tf files are found. Doing this enables it to scan for all its supported languages from the root of the Repo bu giving `build` an alias of `build`

Once the scan has been ran the following steps are then also ran:

* If the scan has any failures a work item is created called `Review TerraScan failures for $(project_repo) repository` in the default iteration path, and default area path of the project with the following additional options
  * Pull requests are linked to the work item
  * All output from the scan is attached
* The reports and log are published as an artifact called `terrascanreports-$(environment_tag)`
* Copies the sarif files to `$(System.DefaultWorkingDirectory)/terrascanreports/sarif`
* Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
* The test results are published as a test run called `TerraScan Scan`
* the docker image is removed

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
[Megalinter]: ./docs/code_quality/megalinter.md
[Mend_Bolt]: ./docs/code_quality/mend_bolt.md
[OWASP]: ./docs/code_quality/owasp.md
[Sonar_Cloud]: ./docs/code_quality/sonar_cloud.md
[Template_updater]: ./docs/code_quality/template_updater.md
[terraform_Compliance]: ./docs/code_quality/terraform_compliance.md
[Terrascan]: ./docs/code_quality/terrascan.md
[TerraScan]: ./docs/code_quality/TerraScan.md
[TFSec]: ./docs/code_quality/tfsec.md

<!-- CODE QUALITY TEMPLATE LINKS -->
[Checkmarx_KICS.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/checkmarx_kics.yml
[Checkov.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/checkov.yml
[Checkov_baseline_creator.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/checkov_baseline_creator.yml
[GitHub_Super_Linter.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/github_super_linter.yml
[Mega_Linter.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/mega_linter.yml
[OWASP.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/owasp.yml
[TFComplianceCheck.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/tfcompliancecheck.yml
[template_updater.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/template_updater.yml
[Terrascan.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/terrascan.yml
[TerraScan.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/TerraScan.yml
[TFSec.yml]: /repo_template/build/pipelines/repo_template/build/code_quality_templates/tfsec.yml

<!-- IAC TEMPLATE LINKS-->
[terraform_apply.yml]: /repo_template/build/pipelines/repo_template/build/iac_templates/terraform_apply.yml
[terraform_plan.yml]: /repo_template/build/pipelines/repo_template/build/iac_templates/terraform_plan.yml
[variables.yml]: /repo_template/build/pipelines/repo_template/build/iac_templates/variables.yml

<!-- PIPELINE LINKS -->
[infrastructure.yml]: /repo_template/build/pipelines/infrastructure.yml
[code_quality.yml]: /repo_template/build/pipelines/code_quality.yml
