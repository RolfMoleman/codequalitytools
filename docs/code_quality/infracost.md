<!-- Infracost -->
# Infracost #

[![Home][Home_Image]][Code Quality]

> Infracost shows cloud cost estimates for Terraform. It lets DevOps, SRE and engineers see a cost breakdown and understand costs before making changes, either in the terminal or pull requests.

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

- [Infracost](#infracost)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
    - [The stage template](#the-stage-template)

## Prerequisites ##

In order to use Infracost you will need to set the following variables

- `$(Infracost_key)` - this needs to be set via your library group/keyvault that is picked up by the [variables.yml] You will need to obtain an api key from Infracost
- `$(Infracost_api)` - this is set via [variables.yml] and is only needed for a self-hosted api so is commented out
- `$(project_repo)` - this is set via [variables.yml] and needs to be updated to match your repository name
- `$(repo_branch)` - this is set via [variables.yml]
- `$(repo_main_branch)` - this is set via [variables.yml] and needs to be updated to match the main/master branch name for your Repo

### The stage template ###

The [Infracost.yml] Stage template looks as follows:

```yml
steps:
  - task: InfracostSetup@1
    condition: succeededOrFailed()
    displayName: "Infracost Setup"
    enabled: true
    inputs:
      apiKey: '$(Infracost_key)'
      version: '0.10.x'
      currency: 'GBP'
     #pricingApiEndpoint: '$(Infracost_api)'
      enableDashboard: false

  # Clone the base branch of the Repo (e.g. main/master) into a temp directory.
  - bash: |
      git clone $(repo_url) --branch=$(repo_main_branch) --single-branch /tmp/base --config http.extraheader="AUTHORIZATION: bearer $(System.AccessToken)"
    condition: succeededOrFailed()
    displayName: "Checkout $(repo_main_branch) branch"
    enabled: true
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Generate an Infracost cost estimate baseline from the current branch, so that Infracost can compare the cost difference.
  - bash: |
      echo "Set currency to GBP"
      infracost configure set currency GBP
      
      outputTypes=("json" "html" "table")

      for str in ${outputTypes[@]}; do

      echo "Get breakdown for $(repo_main_branch) branch in $str format"
      infracost breakdown --path=$(System.DefaultWorkingDirectory)/repo_template/build/terraform \
      --project-name $(project_repo) \
      --format=json \
      --out-file=/tmp/infracost-$(repo_main_branch)-$(environment_tag).$str

      done
    condition: succeededOrFailed()
    displayName: "Generate Infracost cost estimate baseline"
    enabled: true
    workingDirectory: "$(System.DefaultWorkingDirectory)"

  # Generate an Infracost diff and save it to a JSON file.
  - bash: |
      echo "Set currency to GBP"
      infracost configure set currency GBP
      
      outputTypes=("json" "html" "table")

      for str in ${outputTypes[@]}; do

      echo "Get breakdown for $(repo_branch) branch in $str format"
      infracost breakdown --path=$(System.DefaultWorkingDirectory)/repo_template/build/terraform \
      --project-name $(project_repo) \
      --format=json \
      --out-file=/tmp/infracost-$(repo_main_branch)-$(environment_tag).$str

      done

      echo "Get difference"
      infracost diff --path=$(System.DefaultWorkingDirectory)/repo_template/build/terraform \
                      --project-name $(project_repo) \
                      --format=json \
                      --compare-to=/tmp/infracost-$(repo_main_branch)-$(environment_tag).json \
                      --out-file=/tmp/infracost-difference-$(environment_tag).json
    condition: succeededOrFailed()
    displayName: "Generate Infracost diff"
    enabled: true
    workingDirectory: "$(System.DefaultWorkingDirectory)"


  # Publish the infracost diff as an artifact to Azure Pipelines
  - task: PublishBuildArtifacts@1
    condition: succeededOrFailed()
    displayName: "Publish Infracost Reports"
    enabled: true
    name: "Publish_Infracost_Report"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/tmp/"
      ArtifactName: InfracostReport-$(environment_tag)

  ### Pull request specific run will not work for this application due to the use of templates
  ## Posts a comment to the PR using the 'update' behavior.
  ## This creates a single comment and updates it. The "quietest" option.
  ## The other valid behaviors are:
  ##   delete-and-new - Delete previous comments and create a new one.
  ##   new - Create a new cost estimate comment on every push.
  ## See https://www.infracost.io/docs/features/cli_commands/#comment-on-pull-requests for other options.
  #- bash: |
  #    infracost comment azure-repos --path=/tmp/infracost-$(environment_tag).json \
  #                                  --azure-access-token=$(System.AccessToken) \
  #                                  --pull-request=$(System.PullRequest.PullRequestId) \
  #                                  --Repo-url=$(Build.Repository.Uri) \
  #                                  --behavior=update
  #  condition: succeededOrFailed()
  #  displayName: "Post Infracost comment"
  #  enabled: true
  #  workingDirectory: "$(System.DefaultWorkingDirectory)"

  ```

As you can see the stage does the following:

- Sets up Infracost with the following options:
  - currency: GBP (british pounds)
  - apiKey set using the '$(Infracost_key) variable
  - version set to the latest patch of 0.10
- Clones the main/master branch of the repo into a temporary directory
- Creates an infracost breakdown of the main/master branch and outputs it
- Creates and infracost breakdown fo the current branch and outputs it
- Creates an infracost Diff (comparison) of the costs of the main/master branch andd your current branch
- Publishes the diff and breakdown files as an artifact for you to review

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
