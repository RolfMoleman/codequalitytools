
[![Home][Home_Image]][Code Quality]

<!-- Template Updater -->
# Template Updater #

This template has been written by Carl Dawson - Platform and Automation Engineer - [![Chat with me on Teams][teams-icon]](https://teams.microsoft.com/l/chat/0/0?users=carl.dawson@bca.com) - carl.dawson@bca.com

the idea behind this is to enable the pipeline to programmatically pull in any newly created templates from the Repo_template repository in the BCA.Operations.Utilities Azure Devops project. This is to ensure that all product teams always have the latest versions of the templates available to them but without overriding any custom configurations that they have put in place.

---
**NOTE:** This template is a work in progress and you use it at your own risk. I accept no responsibility for incorrectly managed merge conflicts which may result in misconfigured pipelines, incorrect wikis or readmes.

---

## Prerequisites ##

In order to use the [template_updater.yml] Stage template you will need the following

* you must have a user and email specified in your global git config

### The stage template ###

The [template_updater.yml] Stage template looks as follows:

 ```yaml
steps:
  - script: |
      echo "set git config to build service user"
      git config --global user.email "build.service@bca.com"
      git config --global user.name "build service"

      echo "add repo_template remote and fetch it"
      git remote add -f repo_template https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template

      echo "create a pipeline update branch"
      git checkout -b 'repo_template-master_updates'

      echo "merge in BCA.Operations.Utilities/repo_template main branch but keep our changes"
      git merge --allow-unrelated-histories -s ours repo_template/main 

      echo "get updates just for code_quality_templates directory"
      git read-tree --prefix=build/pipelines/code_quality_templates/ -u repo_template/main:build/pipelines/code_quality_templates

      echo "Adding new files from repo_template in build/pipelines/code_quality_templates that dont exist here"
      git commit -m 'Adding new files from repo_template in build/pipelines/code_quality_templates directory'

      echo "fetch "
      git fetch repo_template main

      echo "get updates just for code_quality_templates directory"
      git read-tree --prefix=docs/code_quality/ -u repo_template/main:docs/code_quality

      echo "Adding new files from repo_template in docs/code_quality/ that dont exist here"
      git commit -m 'Adding new files from repo_template in docs/code_quality/ directory'

      echo "push updates branch"
      git push -u origin repo_template-master_updates

      echo "Remove repo_template remote"
      git remote remove repo_template
    condition: succeededOrFailed()
    displayName: "pull in updates to repo_template"
    enabled: true
    name: "pipeline_updater"

  - task: CreatePullRequest@1
    condition: succeededOrFailed()
    displayName: "pr to pull changes to repo_template master branch"
    enabled: true
    name: "repo_template_pr"
    inputs:
      repoType: 'Azure DevOps'
      repositorySelector: 'currentBuild'
      sourceBranch: 'repo_template-master_updates'
      targetBranch: '$(Build.SourceBranch)'
      title: 'repo_template updates'
      description: 'Merge in repo_template updates'
      reviewers: ''
      tags: ''
      isDraft: false
      passPullRequestIdBackToADO: true
  ```

What this template does is:

* add a new git remote called repo_template pointed to the repo_template repository under the Azure Devops project called BCA.Operations.Utilities and fetches from it
* create a new branch called `repo_template-master_updates`
* perform a git merge allowing unrelated histories from the master branch of the repo_template repository using the merge strategy `ours` to keep the changes in this Repo
* perform a git read-tree to see what is different between the contents of `build/pipelines/code_quality_templates/` in this Repo and in the repo_template Repo
* Adds in the new files
* perform a fetch from the repo_template
* perform a git read-tree to see what is different between the contents of `docs/code_quality/` in this Repo and in the repo_template Repo
* adds int eh new files
* to push this to your repository on a branch named `repo_template-master_updates`
* to remove the repo_template remote
* to create a pull request called `repo_template updates` pulling the changes from the `repo_template-master_updates` into your current branch branch

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
