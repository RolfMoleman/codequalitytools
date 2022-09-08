<!-- Sonar Cloud -->
# Sonar Cloud #

[![Home][Home_Image]][Code Quality]

> SonarCloud is a cloud-based code analysis service designed to detect code quality issues in 25 different programming languages, continuously ensuring the maintainability, reliability and security of your code.

## Table of Contents ##

- [Sonar Cloud](#sonar-cloud)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
    - [The stage template](#the-stage-template)

## Prerequisites ##

---
**NOTE:** depending on  your code language, you may need a build step to compile your code before using Sonar Cloud.

---

In order to use the [Sonar_cloud.yml] Stage template you will need to set the following variables

- `$(project_repo)` - this is set via [variables.yml] and needs to be updated to match your repository name
- `$(sonarcloud_cliprojectkey)` - this is the project key obtained from Sonar Cloud and should be set form your tf-env-vars library group
- `$(sonarcloud_organization)`- this is the organization key that can be obtained from sonar cloud and should be set form your tf-env-vars library group

You will also need to setup a service connection to Sonar cloud and name it `Sonar Cloud`

<!-- TABLE OF CONTENTS -->

### The stage template ###

The [Sonar_cloud.yml] Stage template looks as follows:

 ```yaml
steps:
  - task: SonarCloudPrepare@1
    condition: succeededOrFailed()
    displayName: 'Prepare for sonarcloud analysis'
    enabled: true
    inputs:
      SonarCloud: 'Sonar Cloud'
      organization: '$(sonarcloud_organization)'
      scannerMode: 'CLI'
      configMode: 'manual'
      cliProjectKey: '$(sonarcloud_cliprojectkey)'
      cliProjectName: '$(project_repo)'
      cliSources: '.'

  - task: SonarCloudAnalyze@1
    condition: succeededorfailed()
    displayName: 'Run SonarCloud Analysis'
    enabled: true

  - task: SonarCloudPublish@1
    condition: succeededorfailed()
    displayName: 'Publish Sonar Cloud results on build summary'
    enabled: true
    inputs:
      pollingTimeoutSec: '300'
  ```

As you can see this template is very simple. This is because the extension handles all the reporting for us. and the reports can be viewed in the Sonar Cloud dashboard

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
