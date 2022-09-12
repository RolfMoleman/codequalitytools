<!-- MegaLinter -->
# MegaLinter #

[![Home][Home_Image]][Code Quality]

> Mega-Linter is an 100% Open-Source tool for CI/CD workflows that analyzes consistency and quality of 48 languages, 22 formats, 19 tooling formats , abusive copy-pastes and spelling mistakes in your repository sources, generates various reports, and can even apply formatting and auto-fixes, to ensure all your projects sources are clean, whatever IDE/toolbox are used by their developers.
>
> Ready to use out of the box as a GitHub Action or any CI system, highly configurable and free for all uses

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

- [MegaLinter](#megalinter)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [The stage template](#the-stage-template)

## Prerequisites ##

---
**Note:** Megalinter can take quite a long time to run due to the sheer number of languages it works with. As such please ensure you only enable the linters you require via the config file. You may also wish to look at the console output as Megalinter has a concept of flavours and will suggest a flavour that may give better performance

---

Megalinter relies on the `.mega-linter.yml` config file at the root of the Repo. this is currently configured to run APPLY_FIXES, PRINT_ALL_FILES, PRINT_ALPACA, SHOW_ELAPSED_TIME, TAP_REPORTER (important for test results publishing), TAP_REPORTER_SUB_FOLDER, TEXT_REPORTER

## The stage template ##

The [Mega_Linter.yml] Stage template looks as follows:

 ```yaml
steps:
  - script: |
      docker pull oxsecurity/megalinter:latest
      docker run \
      --env MEGALINTER_CONFIG='/repo_template/config/.mega-linter.yml' \
      --volume $(pwd):/tmp/lint oxsecurity/megalinter:latest
    condition: succeededOrFailed()
    displayName: "Code Scan using Mega-Linter"
    enabled: true
    name: "Code_Scan_using_MegaLinter"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Create work items to review failures
  - task: CreateWorkItem@1
    condition: failed()
    displayName: 'Create work item'
    enabled: true
    inputs:
      #teamProject: # Optional
      workItemType: 'Product Backlog Item'
      title: 'Review Megalinter failures for $(project_repo) repository'
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
      attachmentsFolder: "$(System.DefaultWorkingDirectory)/Report/" # Optional
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

  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter Report"
    enabled: true
    name: "Publish_MegaLinter_Report"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/report/"
      ArtifactName: MegaLinterReport-$(environment_tag)

  #copy sarif files to sarif directory to avoid polluting CodeAnalysisLogs
  - task: Powershell@2
    condition: succeededOrFailed()
    displayName: "Copy Sarif Files"
    enabled: true
    inputs:
      targetType: 'inline'
      script: |
        cd $(System.DefaultWorkingDirectory)/report
        $files = dir -R -a
        mkdir sarif
        ForEach($file in $files)
        {
          if($file.extension.Contains("sarif"))
          {
              Copy-Item -Path $file.FullName -Destination $(System.DefaultWorkingDirectory)/report/sarif -Force
          }
          else
          {
              Write-output $file.FullName "does not need moving"
          }      
        }
      showWarnings: true
      pwsh: true
      workingDirectory: '$(System.DefaultWorkingDirectory)'

 #publish Megalinter Scan
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish Megalinter Scan"
    enabled: true
    name: "Publish_megalinter_scan"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/report/sarif"
      ArtifactName: "CodeAnalysisLogs"
      publishLocation: "container"

  - script: |
      npm install -g tap-junit
      mkdir megalinter-reports_converted/
      cd ./report/tap
      for report in *; do
      ReportName=$(echo $report | sed -n "s/mega-linter-\s*\(\S*\).tap$/\1/p")
      # workaround for https://github.com/dhershman1/tap-junit/issues/30#issuecomment-744462006
        'sed -i "s/message: \*\+/message: /g" $report'
      # Some message got comments with # which are ignored by tap-junit, so we escape it
        'sed -i -E "s/(^|[ ]+)(#)[a-zA-Z]*/\1\/\//g" $report'
      ## Converting TAP files into xml files with JUnit5 format
      #  cat $report | tap-junit -p -s "mega-linter" > ../../megalinter-reports_converted/${report}.xml
      #Carls method
        cat $report | tap-junit --pretty --suite $ReportName --input ${report} > ../../megalinter-reports_converted/${ReportName}.xml
      # Remove escaping on newlines for readability
        sed -i 's/\\n/\n/g' ../../megalinter-reports_converted/${report}.xml
      # Replace ANSI colors as they are illegal characters
        sed -i 's/\x1b\[[0-9;]*m//g' ../../megalinter-reports_converted/${report}.xml
      done
    condition: succeededOrFailed()
    displayName: "Convert tap reports to junit"
    enabled: true
    name: "Convert_tap_reports_to_junit"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  - script: |
      cd ./megalinter-reports_converted
      ls -la
      echo "Appending environment to file name"
      ls -a 
      for f in *;do mv -v "$f" "${f%.*}-$(environment_tag).${f##*.}";done
      ls -la
    condition: succeededOrFailed()
    displayName: "rename reports"
    enabled: true
    name: "rename_reports"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish renamed MegaLinter Reports"
    enabled: true
    name: "Publish_renamed_MegaLinter_Reports"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      ArtifactName: "MegaLinter JUnit-Reports-$(environment_tag)"

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - ARM_TTK Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "ARM_ARM_TTK-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - ARM"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - JSON_ESLINT Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "JSON_ESLINT_PLUGIN_JSONC-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - JSON_ESLINT"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - JSON_JSONLINT Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "JSON_JSONLINT-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - JSON_JSONLINT"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - JSON_PRETTIER Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "JSON_PRETTIER-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - JSON_PRETTIER"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - JSON_V8R Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "JSON_V8R-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - JSON_V8R"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - MARKDOWN_LINK_CHECK Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "MARKDOWN_MARKDOWN_LINK_CHECK-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - MARKDOWN_LINK_CHECK"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - MARKDOWN_TABLE_FORMATTER Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "MARKDOWN_MARKDOWN_TABLE_FORMATTER-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - MARKDOWN_TABLE_FORMATTER"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - MARKDOWNLINT Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "MARKDOWN_MARKDOWNLINT-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - MARKDOWNLINT"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - CSPELL Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "SPELL_CSPELL-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - CSPELL"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - MISSPELL Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "SPELL_MISSPELL-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - MISSPELL"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - CHECKOV Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "terraform_CHECKOV-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - CHECKOV"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - KICS Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "terraform_KICS-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - KICS"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - terraform_FMT Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "terraform_terraform_FMT-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - terraform_FMT"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - TFLINT Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "terraform_TFLINT-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - TFLINT"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - YAML_PRETTIER Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "YAML_PRETTIER-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - YAML_PRETTIER"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - YAML_V8R Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "YAML_V8R-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - YAML_V8R"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: "Publish MegaLinter - YAMLLINT Results"
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "YAML_YAMLLINT-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/megalinter-reports_converted/"
      testRunTitle: "MegaLinter - YAMLLINT"
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "oxsecurity/megalinter:latest" -f | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
    name: "Remove_terraform_Quality_Check_Docker_Images"
    workingDirectory: "$(System.DefaultWorkingDirectory)"
        
  ```

As you can see the stage does the following:

- Pulls the latest official megalinter docker image from Dockerhub
- Performs a scan of `$(System.DefaultWorkingDirectory)` scanning directories recursively and outputs the results:
  - to a log file called `mega-linter.log`
  - as a separate log file per language prefixed with error or success e.g. `ERROR-ARM_ARM_TTK.log`
  - as a separate tap file per language e.g. `mega-linter-ARM_ARM_TTK.tap`
- exports the auto-fixed files to an `updated sources` directory

Once the scan has been ran the following steps are then also ran:

- The entire megalinter output is published as an artifact called `MegaLinterReport-$(environment_tag)`
- The tap formatted reports are converted to junit xml files
- the Junit files are published as an artifact called `MegaLinter JUnit-Reports-$(environment_tag)`
- Copies the sarif files to `$(System.DefaultWorkingDirectory)/report/sarif`
- Publishes the sarif files as an artifact called `CodeAnalysisLogs` which adds any files with the Sarif extension to the scan tab of the pipeline run
- The test results are published as a test run per language called `MegaLinter - Language` e.g. `MegaLinter - ARM`

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
