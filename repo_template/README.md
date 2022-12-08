# BCA Repository Template #

<!-- AZURE DEVOPS PIPELINE BADGES -->
<!--
*** below badges are examples, please replace the badges with the badges for your pipelines and repos
-->

[![Build Status](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_apis/build/status/repo_template%20-%20Code%20Quality%20Checks?branchName=main&label=repo_template%20-%20Code%20Quality%20Checks)](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_build/latest?definitionId=3061&branchName=main) [![Build Status](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_apis/build/status/repo_template%20-%20Infrastructure%20Quality%20Checks?branchName=main&label=repo_template%20-%20Infrastructure%20Quality%20Checks)](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_build/latest?definitionId=3062&branchName=main)

<!-- Made With Badges -->
<!--
*** replace with badges relevant to your repo
-->
[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![made-with-Markdown](https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg)](http://commonmark.org)

<!-- included tool versions -->
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/bridgecrewio/checkov?label=Checkov%20Version)](https://github.com/bridgecrewio/checkov/releases)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/github/super-linter?label=GitHub%20Super-linter%20Version)](https://github.com/github/super-linter/releases)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/infracost/infracost?label=Infracost%20Version)](https://github.com/infracost/infracost/releases)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/oxsecurity/megalinter?label=Megalinter%20Version)](https://github.com/oxsecurity/megalinter/releases)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/dependency-check/azuredevops?label=OWASP%20Dependency%20Check%20Version)](https://github.com/dependency-check/azuredevops/releases)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/terraform-compliance/cli?label=Terraform%20Compliance%20Version)](https://github.com/terraform-compliance/cli/releases)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tenable/terrascan?label=Terrascan%20Version)](https://github.com/tenable/terrascan/releases)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/tag/terraform-linters/tflint-bundle?label=TFLint%20Version)](https://github.com/terraform-linters/tflint-bundle/tags)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/aquasecurity/tfsec?label=TFSec%20Version)](https://github.com/aquasecurity/tfsec/releases)

<!-- Sonar Cloud Badges -->
<!--
*** replace 3f795ff4-4328-4347-80b1-3348dd374401 with your Azure Devops Repo ID to get your badges
-->
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=sqale_rating&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=security_rating&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Bugs](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=bugs&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=vulnerabilities&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=duplicated_lines_density&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=reliability_rating&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=alert_status&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=sqale_index&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Coverage](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=coverage&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=ncloc&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401) [![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=3f795ff4-4328-4347-80b1-3348dd374401&metric=code_smells&token=728eebeb7cb500a638c8c001fcebb9191f1cbc02)](https://sonarcloud.io/summary/new_code?id=3f795ff4-4328-4347-80b1-3348dd374401)

<!-- Azure Devops Navigation -->

||||||||||
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|||||[![name][logo-image]](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template)|||||
|||||[**README**](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/README.md&version=GBmaster&_a=preview)|||||
|||||[**DOCUMENTS**](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/docs&version=GBmaster)|||||
|[Checkov Baseline](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/config/.checkov.baseline)|[Cspell config file](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/config/.cspell.json)|[Gitversion config](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/GitVersion.yml)|[JSCPD config](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/config/.jspcd.json)|[KICS config file](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/kics.config&version=GBmaster)|[License file](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/LICENSE.md)|[Megalinter config file](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/.mega-linter.yml)|[Readme Template](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/BLANK_README.md)|[tflint config file](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/build/terraform/.tflint.hcl)|

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

- [BCA Repository Template](#bca-repository-template)
  - [Table of Contents](#table-of-contents)
  - [About The Project](#about-the-project)
    - [Built With](#built-with)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
  - [Usage](#usage)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [License](#license)
  - [Contact](#contact)
  - [Acknowledgments](#acknowledgments)

<!-- ABOUT THE PROJECT -->
## About The Project ##

[![project_name Screen Shot][product-screenshot]](https://www.bca.co.uk/)

A versioned template to be used to ship a standard set of:

- Code quality tools
- Directories
- Images
- ASCII art
- Markdown based documentation (Wiki)
- Configuration files
- Base terraform files
- Centralised version management from an included variables.yaml file

for new and exiting projects.
This repository is just a framework to get you started.

---
**NOTE:** Please ensure you follow the [Usage_Guide.md] closely to integrate this with your repository new or old. If you need assistance please contact a member of the Platform and Automations Team using the contact details further down the page.

---

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

### Built With ###

- [ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [Best README template](https://github.com/othneildrew/Best-README-Template/)
- [Checkmarx KICS](https://checkmarx.com/product/opensource/kics-open-source-infrastructure-as-code-project/)
- [Checkov](https://www.checkov.io/)
- [GitHub Super Linter](https://github.com/github/super-linter/)
- [Gitversion](https://gitversion.net/)
- [Infracost](https://www.infracost.io/)
- [Mega Linter](https://megalinter.github.io/latest/)
- [Mend Bolt](https://www.mend.io/free-developer-tools/bolt/)
- [OWASP Dependency Track GitHub](https://github.com/DependencyTrack/dependency-track)
- [OWASP Zed k Proxy (ZAP) Scanner](https://www.zaproxy.org/)
- [Sonar Cloud](https://sonarcloud.io/)
- [Terraform](https://www.terraform.io/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terraform Compliance](https://terraform-compliance.com//)
- [Terrascan](https://runterrascan.io/)
- [TFLint](https://github.com/terraform-linters/tflint/)
- [TFSec](https://aquasecurity.github.io/tfsec/)

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- GETTING STARTED -->
## Getting Started ##

To get started do the following:

1. Add this Repo as a subtree to your repository using:
   1. add the remote:

   ```console
   git remote add -f repo_template https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template
   ```

   2. Add the subtree:

   ```console
   git subtree add --prefix=repo_template repo_template <sha, tag, branch> --message 'Adding repo_template'
   ```

   example:

   ```console
   git subtree add --prefix=repo_template repo_template cleanup --message 'Adding repo_template'
   ```

2. _Optional:_ if you wish to use the included readme template:
   1. copy BLANK_README.md to the root of your repo
   2. rename the copied BLANK_README.md to README.md
   3. In the new `README.md` do the following:
      1. Replace `repo_name` with your repository name e.g. repo_template
      2. Replace `project_name` with your Azure DevOps project name e.g. `BCA.Operations.Utilities`
      3. Replace `email_address` with your email address e.g. `carl.dawson@bca.com`
      4. Replace or remove `linkedin_username` as appropriate
      5. Replace `project_title` with what you want to call the project e.g. `BCA Repository Template`
      6. Replace `project_description` with some details about the project
      7. Replace `your_name` with your name e.g. `Carl Dawson`
      8. Replace `3f795ff4-4328-4347-80b1-3348dd374401` with the id of your repo which you can get here `https://dev.azure.com/bcagroup/project_name/_apis/git/repositories/repo_name?api-version=6.0`
3. Add your terraform files to the `.\repo_template\build\terraform` folder
4. In the `variables.yaml` replace `3f795ff4-4328-4347-80b1-3348dd374401` with the id of your repo which you can get here `https://dev.azure.com/bcagroup/project_name/_apis/git/repositories/repo_name?api-version=6.0`
5. Amend the terraform variables used in `.\repo_template\build\pipelines\iac_templates\terraform_apply.yml` and `.\repo_template\build\pipelines\iac_templates\terraform_plan.yml`
6. setup `repo_template\build\pipelines\infrastructure.yml` as a pipeline in azure devops _Note: please give it a meaningful name_
7. setup `repo_template\build\pipelines\infrastructure_pull_request.yml` as a pipeline in azure devops _Note: please give it a meaningful name_
8. setup `repo_template\build\pipelines\infrastructure_quality.yml` as a pipeline in azure devops _Note: please give it a meaningful name_
9. setup `repo_template\build\pipelines\code_quality.yml` as a pipeline in azure devops _Note: please give it a meaningful name_
10. Replace the `.\repo_template\repo_template-images\screenshot.png` with a screenshot of your product
11. Replace the `.\repo_template\repo_template-images\pipeline-screenshot.png` with a screenshot of your `repo_template\build\pipelines\code_quality.yml` pipeline once you have configured it
12. Create an awesome project!

### Prerequisites ###

---
**Before using:** _in order for the pipelines to be useable we assume you have already had this project bootstrapped._

_You will also need to update the `repo_template\build\pipelines\iac_templates\variables.yml` section for `project_repo` replacing `repo_template` with the name of your repository_

_please take a look at `.\docs\code_quality.md` to gain additional understanding of the code quality tools that are shipped with this Repo and update accordingly should you add any of your own._

---

---
**To use Bridgecrew** _if you wish to use the bridgecrew integration you will need to add a secret to your terraform keyvault and library group called `bridgecrewkey` that contains your bridgecrew api key._

---

---
**To use OWASP** _if you wish to use the bridgecrew integration you will need to add a secret to your terraform keyvault and library group called `bridgecrewkey` that contains your bridgecrew api key._

---

Below is a list of how to get all tools used for this Repo for local use.

- Chocolatey

  ```console
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  ```

- Python

  ```console
  choco install python
  ```  

- GO programming language

  ```console
  choco install go
  ```

- Checkmarx KICS

  ```docker
  docker pull checkmarx/kics:latest
  docker run -v {​​​​path_to_host_folder_to_scan}​​​​:/path checkmarx/kics scan -p "/path" -o "/path/"
  ```

- Checkov

  ```pip
  pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org checkov
  ```

- MegaLinter

  ```npx
  npx mega-linter-runner --install
  ```

- GitHub Super-Linter

  ```console
  docker pull github/super-linter:latest
  ```  

- Infracost

  ```console
  choco install infracost
  ```

- terraform

  ```console
  choco install terraform
  ```

- terraform-compliance

  ```pip
  pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org terraform-compliance
  ```

- terrascan

  ```console
  docker pull accurics/terrascan:latest
  ```

- tflint

  ```console
  choco install tflint
  ```  

- tfsec

  ```console
  choco install tfsec
  ```

- VSCode

  ```console
  choco install vscode
  ```

<!-- USAGE EXAMPLES -->
## Usage ##

please use this Repo as a template to keep a uniform structure across all our repos. doing so enables developers to to pick things up quicker should they switch teams.

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- ROADMAP -->
## Roadmap ##

- [x] Add back to top links
- [x] Add Gitversion for SemVer compliance
- [ ] Add Additional Templates w/ Examples

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- CONTRIBUTING -->
## Contributing ##

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please clone the Repo and create a pull request.
Thanks again!

1. Clone the Repo (`git clone https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template`)
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---
**NOTE:** This repo has tagged release where the version number is generated by gitversion. You can increment the release version by additing to your commit messgae as foollows:

Adding +semver: breaking or +semver: major will cause the major version to be increased, +semver: feature or +semver: minor will bump minor and +semver: patch or +semver: fix will bump the patch.
[source][gitversion_website]

---

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- LICENSE -->
## License ##

We don't currently distribute our products. however, there is an included license placeholder in the Repo should this change. See [License] for more information.

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- CONTACT -->
## Contact ##

Carl Dawson - [![Chat with me on Teams][teams-icon]](https://teams.microsoft.com/l/chat/0/0?users=carl.dawson@bca.com) - Platform and Automation Engineer - _initial author_

Dan Berns - [![Chat with me on Teams][teams-icon]](https://teams.microsoft.com/l/chat/0/0?users=daniel.berns@bca.com) - Platform and Automation Engineer

Jason Donnelly - [![Chat with me on Teams][teams-icon]](https://teams.microsoft.com/l/chat/0/0?users=jason.donnelly@bca.com) - Head of Platform and Automation team

Matt Silvester - [![Chat with me on Teams][teams-icon]](https://teams.microsoft.com/l/chat/0/0?users=matthew.silvester@bca.com) - Platform and Automation Engineer

Project Link: [https://dev.azure.com/bcagroup/BCA.Operations.Utilities/](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/)

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments ##

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

- [ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [Best README template](https://github.com/othneildrew/Best-README-Template/)
- [Checkmarx KICS](https://checkmarx.com/product/opensource/kics-open-source-infrastructure-as-code-project/)
- [Checkov](https://www.checkov.io/)
- [CycloneDX](https://cyclonedx.org/)
- [CycloneDX GitHub](https://github.com/CycloneDX)
- [GitHub Super Linter](https://github.com/github/super-linter/)
- [Mega Linter](https://megalinter.github.io/latest/)
- [OWASP](https://owasp.org/)
- [OWASP Dependency Track](https://owasp.org/www-project-dependency-track/)
- [OWASP Dependency Track GitHub](https://github.com/DependencyTrack/dependency-track)
- [Terraform](https://www.terraform.io/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terraform Compliance](https://terraform-compliance.com//)
- [Terrascan](https://runterrascan.io/)
- [TFLint](https://github.com/terraform-linters/tflint/)
- [TFSec](https://aquasecurity.github.io/tfsec/)

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
[Home_Image]: /repo_template-images/home.png
[logo-image]: /repo_template-images/logo.png
[pipeline-screenshot]: /repo_template-images/pipeline-screenshot.png
[product-screenshot]: /repo_template-images/screenshot.png
[teams-icon]: /repo_template-images/teams.png

<!-- MARKDOWN DOCUMENT LINKS -->
[Blank Readme]: /BLANK_README.md
[Code Quality]: /docs/code_quality.md
[Bridgecrew_Checkov]: /docs/code_quality/bridgecrew_checkov.md
[Checkmarx_KICS]: /docs/code_quality/checkmarx_kics.md
[GitHub_Super_Linter]: /docs/code_quality/github_super_linter.md
[Infracost]: /docs/code_quality/Infracost.md
[License]: /license.md
[Megalinter]: /docs/code_quality/megalinter.md
[Mend_Bolt]: /docs/code_quality/mend_bolt.md
[OWASP]: /docs/code_quality/owasp.md
[Readme]: /README.md
[Sonar_Cloud]: /docs/code_quality/sonar_cloud.md
[Template_updater]: /docs/code_quality/template_updater.md
[terraform_Compliance]: /docs/code_quality/terraform_compliance.md
[Terrascan]: /docs/code_quality/terrascan.md
[TFLint]: /docs/code_quality/tflint.md
[TFSec]: /docs/code_quality/tfsec.md
[Usage_Guide.md]: /docs/usage_guide.md

<!-- CODE QUALITY TEMPLATE LINKS -->
[Checkmarx_KICS.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/checkmarx_kics.yml
[Checkov.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/checkov.yml
[Checkov_baseline_creator.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/checkov_baseline_creator.yml
[GitHub_Super_Linter.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/github_super_linter.yml
[Infracost.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/Infracost.yml
[Mega_Linter.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/mega_linter.yml
[OWASP.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/owasp.yml
[TFComplianceCheck.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/tfcompliancecheck.yml
[template_updater.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/template_updater.yml
[Terrascan.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/terrascan.yml
[TFLint.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/tflint.yml
[TFSec.yml]: /build/pipelines/repo_template/build/pipelines/code_quality_templates/tfsec.yml

<!-- IAC TEMPLATE LINKS-->
[terraform_apply.yml]: /build/pipelines/repo_template/build/pipelines/iac_templates/terraform_apply.yml
[terraform_plan.yml]: /build/pipelines/repo_template/build/pipelines/iac_templates/terraform_plan.yml
[variables.yml]: /build/pipelines/repo_template/build/pipelines/iac_templates/variables.yml

<!-- PIPELINE LINKS -->
[infrastructure.yml]: /build/pipelines/infrastructure.yml
[code_quality.yml]: /build/pipelines/code_quality.yml

<!-- Other links -->
[gitversion_website]: https://gitversion.net/docs/reference/version-increments

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
