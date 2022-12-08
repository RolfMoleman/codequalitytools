# Usage Guide #

[![Home][Home_Image]][Readme]

[![name][logo-image]](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template)

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

- [Usage Guide](#usage-guide)
  - [Table of Contents](#table-of-contents)
  - [Getting Started](#getting-started)
  - [Maintaining the subtree](#maintaining-the-subtree)
    - [Prerequisites](#prerequisites)
  - [Author Recommendations](#author-recommendations)
  - [Usage](#usage)
  - [Contributing](#contributing)
  - [License](#license)
  - [Contact](#contact)

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

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- Maintaining the subtree -->
## Maintaining the subtree ##

1. Fetch:

   ```console
   git fetch repo_template <sha, tag, branch>
   ```

   Example:

   ```console
   git fetch repo_template cleanup
   ```

2. Pull:

   ```console
   git subtree pull --prefix=repo_template repo_template <sha, tag, branch> --message 'updating repo_template to <sha, tag, branch>'
   ```

   example:

   ```console
   git subtree pull --prefix=repo_template repo_template cleanup --message 'updating repo_template to cleanup branch'
   ```

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

### Prerequisites ###

**Before using:** _in order for the pipelines to be useable we assume you have already had this project bootstrapped._

_You will also need to update the `.\repo_template\build\pipelines\iac_templates\variables.yml` section for `project_repo` replacing `repo_template` with the name of your repository_

_please take a look at `.\repo_template\docs\code_quality.md` to gain additional understanding of the code quality tools that are shipped with this Repo and update accordingly should you add any of your own._

**To use OWASP** _if you wish to use the ZAP steps you will need to update the tokens to point to your urls and enable the step_

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- Author Recommendations -->
## Author Recommendations ##

Although not entirely necessary i strongly recommend installing the following tools locally to get the fullest of out this project

- Chocolatey

  ```console
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  ```

- Python

  ```console
  choco install python
  ```  

- Checkov

  ```pip
  pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org checkov
  ```

- Infracost

  ```console
  choco install infracost
  ```

- terraform

  ```console
  choco install terraform
  ```

- [Sonarlint](https://www.sonarlint.org/) - this will link to sonar cloud and allow you to fix issues before committing them

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

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- USAGE EXAMPLES -->
## Usage ##

please use this Repo as a template to keep a uniform structure across all our repos. doing so enables developers to to pick things up quicker should they switch teams.

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- CONTRIBUTING -->
## Contributing ##

This repo is an in-house opensource project, any staff member can contribute and any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please clone the Repo, create a feature branch and create a pull request.
Thanks again!

1. Clone the Repo (`git clone https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template`)
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Alternatively you can contribute from your subtree in your local repo by using the following command

```console
git subtree push --prefix=repo_template repo_template <sha, tag, branch>
```

Example:

```console
git subtree push --prefix=repo_template repo_template feature
```

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- LICENSE -->
## License ##

We don't currently distribute our products. However, there is an included license placeholder in this repo should this change. See [LICENSE] for more information.

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
[Usage_Guide.md]: ./docs/usage_guide.md

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
