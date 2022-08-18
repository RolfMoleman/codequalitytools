<!-- GitHub Super Linter -->
# GitHub Super Linter #

[![Home][Home_Image]][Code Quality]

> The end goal of this tool:
>
> * Prevent broken code from being uploaded to the default branch (Usually master or main)
> * Help establish coding best practices across multiple languages
> * Build guidelines for code layout and format
> * Automate the process to help streamline code reviews

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

* [GitHub Super Linter](#github-super-linter)
  * [Table of Contents](#table-of-contents)
  * [Prerequisutes](#prerequisutes)
    * [The stage template](#the-stage-template)

## Prerequisutes ##

---
**Note:** The GitHub team have removed the tap report writer, tap can be converted to junit. Without this we cannot publish the test results so this step is commented out and not used.

---

### The stage template ###

The [GitHub_Super_Linter.yml] Stage template looks as follows:

 ```yaml
  - script: |
      mkdir GHLinterReports
      docker pull github/super-linter:latest
      docker run --tty \
        --entrypoint="" \
        -e RUN_LOCAL=true \
        -e LOG_FILE=super-linter-$(environment_tag).log \
        #-e OUTPUT_DETAILS=detailed \
        #-e OUTPUT_FORMAT=tap \
        --volume $(pwd):/tmp/lint \
        github/super-linter:latest /bin/sh -c "/action/lib/linter.sh;linterSuccess=\$?;chown -R $(id -u):$(id -g) /tmp/lint;ls -la /tmp/lint;exit \$linterSuccess"
      linterSuccess=$?
      #ls -la $(pwd)/super-linter.report
      docker cp $(pwd)/super-linter.report/*.tap $(System.DefaultWorkingDirectory)/GHLinterReports
      #ls -la $(System.DefaultWorkingDirectory)/GHLinterReports
      exit $linterSuccess
    condition: succeededOrFailed()
    displayName: "GitHub Super-Linter Code Scan"
    enabled: true
    name: "superlinter_Scan"
    workingDirectory: "$(System.DefaultWorkingDirectory)"
    # NOTE: You can add the following ENV variable to filter the directory to scan: -e FILTER_REGEX_INCLUDE=".*terraform/.*" \

  # Publish everything from GitHub Linter
  - task: PublishPipelineArtifact@1
    displayName: "Publish Pipeline Artifact: GH Linter Report"
    inputs:
      targetPath: "$(System.DefaultWorkingDirectory)"
      artifact: "GHLinter-output"
      publishLocation: "pipeline"

  - script: |
      echo "making log folder"
      mkdir $(System.DefaultWorkingDirectory)/GHLinterLogs

      echo "copy log"
      cp $(System.DefaultWorkingDirectory)/super-linter*.log $(System.DefaultWorkingDirectory)/GHLinterLogs
      echo "list contents of GHLinterLogs"
      ls -la $(System.DefaultWorkingDirectory)/GHLinterLogs

      echo "Appending environment to report name"
      cd  $(System.DefaultWorkingDirectory)/GHLinterReports
      ls -all
      for f in *;do mv -v "$f" "${f%.*}-$(environment_tag).${f##*.}";done
      ls -la
    condition: succeededOrFailed()
    displayName: rename reports and logs
    enabled: true
    name: "rename_logs"
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Publish the GitHub Linter reports as an artifact to Azure Pipelines
  - task: PublishPipelineArtifact@1
    condition: succeededOrFailed()
    displayName: "Publish Pipeline Artifact: GH Linter Report"
    enabled: true
    inputs:
      targetPath: "$(System.DefaultWorkingDirectory)/GHLinterReports"
      artifact: "GHLinter-Reports-$(environment_tag)"
      publishLocation: "pipeline"

  - task: PublishPipelineArtifact@1
    condition: succeededOrFailed()
    displayName: "Publish GH Linter Log"
    enabled: true
    inputs:
      targetPath: "$(System.DefaultWorkingDirectory)/GHLinterLogs"
      artifact: "GHLinter-Log-$(environment_tag)"
      publishLocation: "pipeline"

  # This script converts the GitHub Linter report (from TAP format), to a format that is supported for consumption in Azure Pipelines (ie. JUnit).
  # Referenced documentation: https://r2devops.io/jobs/static_tests/super_linter
  # The SED commands do the following (in order):
  # Extract the name of the report from the file (ie. "super-linter-terraform_TERRASCAN.tap" results in 'terraform_TERRASCAN')
  # Reads the .TAP report file and pipes it to TAP-JUNIT for conversion into XML
  - script: |
      sudo npm install -g tap-junit
      mkdir GHLinterReports-Converted
      cd super-linter.report
      for report in *; do
          ReportName=$(echo $report | sed -n "s/super-linter-\s*\(\S*\).tap$/\1/p")
          # Example: echo "super-linter-terraform_TERRASCAN.tap" | sed -n "s/^.*-\s*\(\S*\).tap$/\1/p" returns 'terraform_TERRASCAN'
          # SED command breakdown:
            # -n      suppress printing
            # s       substitute
            # ^.*     anything at the beginning
            # -       up until the dash
            # \s*     any space characters (any whitespace character)
            # \(      start capture group
            # \S*     any non-space characters
            # \)      end capture group
            # .*$     anything at the end
            # \1      substitute 1st capture group for everything on line
            # p       print it
          echo "Processing $ReportName TAP file"
          cat $report | tap-junit --pretty --suite $ReportName --input ${report} > ../GHLinterReports-Converted/${ReportName}.xml
      done
      cd ../GHLinterReports-Converted
      echo "GHLinterReports-Converted DIR Content:"
      ls -la
    condition: succeededOrFailed()
    displayName: Convert TAP to JUNIT XML
    enabled: true
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  - script: |
      cd ./GHLinterReports-Converted
      ls -la
      echo "Appending environment to file name"
      ls -all 
      for f in *;do mv -v "$f" "${f%.*}-$(environment_tag).${f##*.}";done
      ls -la
    condition: succeededOrFailed()
    displayName: rename JUnit reports
    enabled: true
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  - task: PublishPipelineArtifact@1
    condition: succeededOrFailed()
    displayName: "Publish Converted Reports"
    enabled: true
    inputs:
      targetPath: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted"
      artifact: "GHLinter-ConvertedReports-$(environment_tag)"
      publishLocation: "pipeline"

  # Publish the results of the GitHub Super-Linter analysis as Test Results to the pipeline
  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - BASH Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "BASH-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - BASH
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - BASH_EXEC Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "BASH_EXEC-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - BASH_EXEC
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - CSHARP Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "CSHARP-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - CSHARP
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - CSS Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "CSS-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - CSS
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - DOCKERFILE Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "DOCKERFILE-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - DOCKERFILE
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - DOCKERFILE_HADOLINT Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "DOCKERFILE_HADOLINT-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - DOCKERFILE_HADOLINT
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - ENV Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "ENV-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - ENV
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - GHERKIN Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "GHERKIN-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - GHERKIN
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - JAVASCRIPT_ES Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "JAVASCRIPT_ES-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - JAVASCRIPT_ES
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - JAVASCRIPT_STANDARD Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "JAVASCRIPT_STANDARD-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - JAVASCRIPT_STANDARD
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - JSCPD Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "JSCPD-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - JSCPD (Copy/Paste Detection)
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - JSON Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "JSON-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - JSON
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - MARKDOWN Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "MARKDOWN-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - MARKDOWN
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PHP_BUILTIN Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PHP_BUILTIN-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PHP_BUILTIN
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PHP_PHPCS Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PHP_PHPCS-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PHP_PHPCS
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PHP_PHPSTAN Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PHP_PHPSTAN-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PHP_PHPSTAN
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PHP_PSALM Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PHP_PSALM-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PHP_PSALM
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - POWERSHELL Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "POWERSHELL-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - POWERSHELL
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PYTHON_BLACK Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PYTHON_BLACK-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PYTHON_BLACK
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PYTHON_FLAKE8 Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PYTHON_FLAKE8-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PYTHON_FLAKE8
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PYTHON_ISORT Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PYTHON_ISORT-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PYTHON_ISORT
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PYTHON_MYPY Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PYTHON_MYPY-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PYTHON_MYPY
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - PYTHON_PYLINT Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "PYTHON_PYLINT-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - PYTHON_PYLINT
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - STATES Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "STATES-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - STATES
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - TFLINT Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "terraform-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - TFLINT
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - terraform_TERRASCAN Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "terraform_TERRASCAN-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - terraform_TERRASCAN
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    displayName: Publish GHSL - YAML Results
    enabled: true
    inputs:
      testResultsFormat: "JUnit"
      testResultsFiles: "YAML-$(environment_tag).xml"
      searchFolder: "$(System.DefaultWorkingDirectory)/GHLinterReports-Converted/"
      testRunTitle: GitHub Super-Linter - YAML
      mergeTestResults: false
      failTaskOnFailedTests: false
      publishRunAttachments: true

  # Clean up any of the containers / images that were used for quality checks
  - bash: |
      docker rmi "github/super-linter:latest" -f | true
    condition: succeededOrFailed()
    displayName: "Remove terraform Quality Check Docker Images"
    enabled: true
  ```

As you can see the [GitHub_Super_Linter.yml] stage template does the following:

* Creates a directory called *"GHLinterReports"*
* Pulls the latest official superlinter docker image from Dockerhub
* Performs a scan of `$(System.DefaultWorkingDirectory)` scanning directories recursively and outputs the results to a log file called `super-linter-$(environment_tag).log`

Once the scan has been ran the following steps are then also ran:

* The log is published as an artifact called `GHLinter-Log-$(environment_tag)`
* The reports are published as an artifact called `GHLinter-Reports-$(environment_tag)`
* The tap formatted reports are converted to junit xml files
* the Junit files are published as an artifact called `GHLinter-ConvertedReports-$(environment_tag)`
* The test results are published as a test run per language called `GitHub Super-Linter - Language` e.g. `GitHub Super-Linter - BASH_EXEC`

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
