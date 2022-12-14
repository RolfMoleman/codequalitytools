# Code Quality Tools #

There are a number of code quality tools included in this repository as templates. Read on to find out what they are and how they can be used

<!-- TABLE OF CONTENTS -->
## Table of Contents ##

- [Code Quality Tools](#code-quality-tools)
  - [Table of Contents](#table-of-contents)
  - [Pipelines](#pipelines)
  - [Existing Templates](#existing-templates)
    - [Pipeline templates](#pipeline-templates)
    - [IAC Templates](#iac-templates)
    - [Code quality, security and linting tool stage templates](#code-quality-security-and-linting-tool-stage-templates)
  - [Flow](#flow)
  - [Tools](#tools)
  - [Language and Tool Support](#language-and-tool-support)
  - [Usage](#usage)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [Contact](#contact)
  - [References](#references)

<!-- Pipelines -->
## Pipelines ##

[![Pipeline screenshot][pipeline-screenshot]](https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template?path=/repo_template-images/pipeline-screenshot.png&version=GBmaster&_a=preview)

The above image shows an example pipeline setup to run against the BCA Azure Front Door.
The pipeline `repo_template\build\pipelines\code_quality.yml` uses a number of stages to run various code quality, security and linting tools for multiple different languages but with a primary focus on Infrastructure as Code (IAC) in particular terraform but also ARM.

Most of the tools included are ran at the root of the Repo namely `$(System.DefaultWorkingDirectory)` However, some do not support recursive scanning and therefore run on the terraform directory specifically which is expected to be `$(System.DefaultWorkingDirectory)/repo_template/build/terraform` as such you can either ensure that the terraform resides within this folder structure or alternatively amend the pipeline templates to put at wherever your terraform resides. i would strongly urge you to relocate your terraform to the terraform directory used within this Repo as this aids in achieving a common way of working making it easier for staff to switch between projects.

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

## Existing Templates ##

Below are the links to all the existing templates

### Pipeline templates ###

- [infrastructure.yml] - used for deploying repeatable terraform to all environments.
- [code_quality.yml] - used to scan all commits to the Repo except for the main, master and development branches. Will also run on pull request for any branch

### IAC Templates ###

These templates are used by the Infrastructure pipeline and Pull Request pipeline to set variables and variable groups based upon an `environment_tag` variable, as well as to keep the input variables for the terraform plan and apply stages consistent.

- [terraform_apply.yml] - used to create a repeatable terraform apply step for deploying terraform based infrastructure for one or more environments
- [terraform_plan.yml] - used to create a repeatable terraform plan step for deploying terraform based infrastructure for one or more environments
- [variables.yml] - used to set the `environment_tag` variable

### Code quality, security and linting tool stage templates ###

- [Checkmarx_KICS.yml]
- [Checkov.yml]
- [Checkov_baseline_creator.yml]
- [GitHub_Super_Linter.yml]
- [Infracost.yml]
- [Mega_Linter.yml]
- [OWASP.yml]
- [TFComplianceCheck.yml]
- [Terrascan.yml]
- [TFLint.yml]
- [TFSec.yml]
  
---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- Flow -->
## Flow ##

The below diagrams show the flow of the pipelines in their default configuration.

---
**Please note:** Should you disable any stage, enable/disable steps within a stage or add any additional stages your flow will differ.
There is overlap of the functionality across some of the stages and it is therefor advised that you review the included documentation to enable/disable stages as you require

---

### code_quality.yml ###

[![](https://mermaid.ink/img/pako:eNqdVMuO2kAQ_JWWT4nEHsh6jcQhEWAee0iCIFIUGQ6D3dgj5uHMjHeDgH_fxmNYxCYhCgcLTZWrq6vk2QWpzjDoBrlhZQHf4oUC-vXayYDOIdVScucwA62AqS2sDFNpAfgrxdKBZFy16GkdGoIzyPAJhS4lKreEu7uP_fa7KS9RcIVgHTPufaP_IZlWQoDBnxVaB87wPEdzPeePGl6l3z7iMLhPZpWCz5gzIpGVpYcH9zUch7sR46IyaD8dPBKHNbL_gXY_DJOBQeYQnrXZAHcogWQ24DQYkn3mrgDmHEuL41p2eSmx_6L3o5B2WQluC5hhqY2zdRRC5w116Kfd5I08b_zKsylTDTj24OQVdMfgaKlKnE1NPOkxTGYo9RNCrNMNVcMly3F5HVvYxEYm-lpQCShLQUGc4vNi8cMV7Wiqdl42RhoPx8AuxNgK9BrKU3MU5RsDXvnr9958epr54GdGbyuLLiqL_q-y6FxZdKsyP-0mb-R54-i3lXlwEv21Mk96jP6psqhObK4VMzAQuspOuXmVuJNMDZbMIKy1ueRBTzGxtfycRad-Ydi5FrwmDj1x1DkvcUk-VU9f7ariIgNbScnMdhm0AomG7oeM7pbdUWoRuAIlLoIu_c2Y2SyChToQryozqnKYcadN0F0zYbEVsMrp-Val5wPPijmji0o2p4cXbDyGFQ)](https://mermaid.live/edit#pako:eNqdVMuO2kAQ_JWWT4nEHsh6jcQhEWAee0iCIFIUGQ6D3dgj5uHMjHeDgH_fxmNYxCYhCgcLTZWrq6vk2QWpzjDoBrlhZQHf4oUC-vXayYDOIdVScucwA62AqS2sDFNpAfgrxdKBZFy16GkdGoIzyPAJhS4lKreEu7uP_fa7KS9RcIVgHTPufaP_IZlWQoDBnxVaB87wPEdzPeePGl6l3z7iMLhPZpWCz5gzIpGVpYcH9zUch7sR46IyaD8dPBKHNbL_gXY_DJOBQeYQnrXZAHcogWQ24DQYkn3mrgDmHEuL41p2eSmx_6L3o5B2WQluC5hhqY2zdRRC5w116Kfd5I08b_zKsylTDTj24OQVdMfgaKlKnE1NPOkxTGYo9RNCrNMNVcMly3F5HVvYxEYm-lpQCShLQUGc4vNi8cMV7Wiqdl42RhoPx8AuxNgK9BrKU3MU5RsDXvnr9958epr54GdGbyuLLiqL_q-y6FxZdKsyP-0mb-R54-i3lXlwEv21Mk96jP6psqhObK4VMzAQuspOuXmVuJNMDZbMIKy1ueRBTzGxtfycRad-Ydi5FrwmDj1x1DkvcUk-VU9f7ariIgNbScnMdhm0AomG7oeM7pbdUWoRuAIlLoIu_c2Y2SyChToQryozqnKYcadN0F0zYbEVsMrp-Val5wPPijmji0o2p4cXbDyGFQ)


### infrastructure.yml ###

[![](https://mermaid.ink/img/pako:eNqtVkFPgzAY_StfetJkHmC3HTQ6plejuxjYoaPfXCO0pBSTZey_W8ayybCuRTkQUr733tf3vSbdklQyJBPyrmixhnmUCDDPfRBPzTqkMs-51shACsgpFyPzLjUqkAoYfmImixyFhqWiIl1juYCbm9uH4OqZF5hxgVBqqvR1Ilreh6D5D9NgqyoBc1SKrqTKocioAC4aSkDxyZUUDe3droW51zf09UzQZYasjoLYCbYYpBLxspWZhhZcRfU_7OakM7bgCiXZuVArFe39rl-rNMWyXFVZPQu2Lx0SWhTZBlbtPH9q98DxSHnThB--ZfDB7LXesKwfg7gLut-DrNNzrz-3xHd-nkoH456-HQoU7Hgk3NW72Q5jJ9hikMqfMufaWS-aoTUmlkn4SR0GMWBLPp2dAhzaYvLziNzrewH22dEAqUsJdpfvRngcu-EWw3SOIbY17t5AL6pj76j6aV2w_Bd9ixn7RI5tY7c47gE4d-gpjKcKqUbQ9H0g3QUTuhK9BnooC8aiQkYkR2XuPMzcjrYNOiF6jTkmZGI-GVUfCUnEztRVBTOMM8a1VGSyolmJI0IrLV83Ij0utFURp-aqlR9Wd1_kbWAh)](https://mermaid.live/edit#pako:eNqtVkFPgzAY_StfetJkHmC3HTQ6plejuxjYoaPfXCO0pBSTZey_W8ayybCuRTkQUr733tf3vSbdklQyJBPyrmixhnmUCDDPfRBPzTqkMs-51shACsgpFyPzLjUqkAoYfmImixyFhqWiIl1juYCbm9uH4OqZF5hxgVBqqvR1Ilreh6D5D9NgqyoBc1SKrqTKocioAC4aSkDxyZUUDe3droW51zf09UzQZYasjoLYCbYYpBLxspWZhhZcRfU_7OakM7bgCiXZuVArFe39rl-rNMWyXFVZPQu2Lx0SWhTZBlbtPH9q98DxSHnThB--ZfDB7LXesKwfg7gLut-DrNNzrz-3xHd-nkoH456-HQoU7Hgk3NW72Q5jJ9hikMqfMufaWS-aoTUmlkn4SR0GMWBLPp2dAhzaYvLziNzrewH22dEAqUsJdpfvRngcu-EWw3SOIbY17t5AL6pj76j6aV2w_Bd9ixn7RI5tY7c47gE4d-gpjKcKqUbQ9H0g3QUTuhK9BnooC8aiQkYkR2XuPMzcjrYNOiF6jTkmZGI-GVUfCUnEztRVBTOMM8a1VGSyolmJI0IrLV83Ij0utFURp-aqlR9Wd1_kbWAh)

### infrastructure_pull_request.yml ###

[![](https://mermaid.ink/img/pako:eNqVVU2P2jAQ_StWTl2JPSROcuDQiiVZtpcKtayqCnrwxrMQNbFTx0FFwH-vP1InICCFA8rYb957M-PEey_jFLyxtxak2qBFsmJI_Sb-cqrWUcbLMpcSKOIMEbZDb4KwbIPgTwaVRCXJ2Uj91xKE2qaIwhYKXpXA5E_0-Pjxyf8wzysocgaolkTIh5Y_WM6bokACfjdQSyRFvl6DONe5ymFZnny9j6b-XjTsM0tgiyoiSAnaTg2KlivmBj4dLX5q8IcfUB8Sf_m1YWgBQpB3LkpUFYQh9aRLQMC2ueDMlHEuFlixVyIHxIJOLLgm9jpZ3BTDVmwuOB1Qw50avqamaZpM5qrHl0Tb9nzhhyTcu5Z3o3nboao3tLNCdVp0Txp2afF_ptnExNi8y2JiLN5lLzH27rDWN4d0Wam_nyiQ7n6tX6SqUMOjjr8F6omlwTVk374lxTdJgx5pOECKO9LoJinukcaXkRqn0F0f0l55L70XGBh96CO0_Mxffie5NEeUy4064Ibfncu0V9VzsJxQetJ-85Gy57hDG97gGq-16_jxoFd3Vmd4wGvY84oHvYaON7zM2zltM6JBr5HjjAa8xj2v4aDX2PHGt3mf7bxefBvOzKDTf5HZTAMHxqdgE6a4jUx_0tCBw1OwKTWN2sgYTGNv5JUg1NVE1bW213srT7ksYeWN1SMl4tfKW7GjwjUVJRJSmksuvPE7KWoYeaSR_NuOZW7BopKcqDuybFePfwFvpFSR)](https://mermaid.live/edit#pako:eNqVVU2P2jAQ_StWTl2JPSROcuDQiiVZtpcKtayqCnrwxrMQNbFTx0FFwH-vP1InICCFA8rYb957M-PEey_jFLyxtxak2qBFsmJI_Sb-cqrWUcbLMpcSKOIMEbZDb4KwbIPgTwaVRCXJ2Uj91xKE2qaIwhYKXpXA5E_0-Pjxyf8wzysocgaolkTIh5Y_WM6bokACfjdQSyRFvl6DONe5ymFZnny9j6b-XjTsM0tgiyoiSAnaTg2KlivmBj4dLX5q8IcfUB8Sf_m1YWgBQpB3LkpUFYQh9aRLQMC2ueDMlHEuFlixVyIHxIJOLLgm9jpZ3BTDVmwuOB1Qw50avqamaZpM5qrHl0Tb9nzhhyTcu5Z3o3nboao3tLNCdVp0Txp2afF_ptnExNi8y2JiLN5lLzH27rDWN4d0Wam_nyiQ7n6tX6SqUMOjjr8F6omlwTVk374lxTdJgx5pOECKO9LoJinukcaXkRqn0F0f0l55L70XGBh96CO0_Mxffie5NEeUy4064Ibfncu0V9VzsJxQetJ-85Gy57hDG97gGq-16_jxoFd3Vmd4wGvY84oHvYaON7zM2zltM6JBr5HjjAa8xj2v4aDX2PHGt3mf7bxefBvOzKDTf5HZTAMHxqdgE6a4jUx_0tCBw1OwKTWN2sgYTGNv5JUg1NVE1bW213srT7ksYeWN1SMl4tfKW7GjwjUVJRJSmksuvPE7KWoYeaSR_NuOZW7BopKcqDuybFePfwFvpFSR)

### infrastructure_quality.yml ###

[![](https://mermaid.ink/img/pako:eNqdV11vozgU_SsWT7NSR4MN20AfdjUN4aOzu4qm87Jq-uCCm6AAZoxpp2r639fJdQjTMDibPkQVPpzre87xB69WyjNmXVlLQesV-hYsKqT-PuO7qXqOUl6WuZQsQ7xCtHpBD4JW6QqxHymrJSppXl2o30YyoYYzlLEnVvC6ZJW8Rx8__nGNP8zzmhV5xVAjqZC_aX5yN2-LAgn2vWWNRFLkyyUT7-v8kgNYrvF2HE3x67XIsyVLBXtGXKDpiqVr_vQGqOkOtTlAPs1F3pQ0LXiboScqcvpQsAbVvG4LqnrdBPjua1uhHmmT0ur-_9FVXPYpyY5Sz6zPF0ATM_wa0rxoBWv-1BMPCIyQo5EZvLP5lzWbUFklmCqCnrlYo1yyEimt1khyJFTJ51yuEJWSpqutLc19n2LzD99EWHnxUOTNCn1lNRey2VlZ8OUeSnrVyHnVSFeNGKqF0JtxViHMysgXAV984OuJHwFJTIYGY3gzObwpt1lVPrRF11kMDAkZAyXAdKNyxUr-xFDA07VaMnlJl2yPAaIb8gvMz5Hvxamk4gf6kkxv9wEFosA5DpRzMHLmnGUkUGyNDB1TbKCaERcCLnIGDYLB2Bn1AECJc5J0GLRLqkdBU97Ibl3r5YadgfWme8HGZjQywsPt6OEYjzekYQk-rSVn19HfbEmVhWov3rcELIF7nAS3lwT3vCS4XRJcUxKgmhEXAi5yB6WDwdgdFQ5AiXuSbJc72W55RdWZsd2-97pdgm6Tu7lgNRUMPapTpYdDnytavDR5p8UEojN5T_geOANgOOma6IN1L9sz8KHNiww1balW98vRxKHONyYE7Z9MQB54x3Z7Pbu98-z2Ors9k91QzYgLARd5g3bDYOyN2g2gxDvJbg9UC_9Sa2QvGRAE_rFkfk8y_zzJ_E4y3yQZVDPiQsBF_qBkMBj7o5IBKPFPkszXkt2ydK8YvB9g-1gybPc0w_Z5ogHJTjVFYZBNVzQjQ42Mesif9mVb78v2-L5s633ZHpXvBi5XeKNOFfuwVtUuUqJ50VW9gVsRMcASOHMdE2y3a21cEwwW8u8mGIT30gTTdk1GcPvz1dbnL34Hm_KyLnJ132dwoekOZKyjRgaiRvpRI2dGjRyiRoxRIzpq5gusvpliMhw1fefEZDxq-mKJhy-E1oVVMqE-wDL18fa6fWdhyRUr2cK6Uv9mVKwX1qJ6U7i2zpQ2syyXXFhXj7Ro2IVFW8lvX6q0ewCoIKfqS7DUT9_-A1NHdDs)](https://mermaid.live/edit#pako:eNqdV11vozgU_SsWT7NSR4MN20AfdjUN4aOzu4qm87Jq-uCCm6AAZoxpp2r639fJdQjTMDibPkQVPpzre87xB69WyjNmXVlLQesV-hYsKqT-PuO7qXqOUl6WuZQsQ7xCtHpBD4JW6QqxHymrJSppXl2o30YyoYYzlLEnVvC6ZJW8Rx8__nGNP8zzmhV5xVAjqZC_aX5yN2-LAgn2vWWNRFLkyyUT7-v8kgNYrvF2HE3x67XIsyVLBXtGXKDpiqVr_vQGqOkOtTlAPs1F3pQ0LXiboScqcvpQsAbVvG4LqnrdBPjua1uhHmmT0ur-_9FVXPYpyY5Sz6zPF0ATM_wa0rxoBWv-1BMPCIyQo5EZvLP5lzWbUFklmCqCnrlYo1yyEimt1khyJFTJ51yuEJWSpqutLc19n2LzD99EWHnxUOTNCn1lNRey2VlZ8OUeSnrVyHnVSFeNGKqF0JtxViHMysgXAV984OuJHwFJTIYGY3gzObwpt1lVPrRF11kMDAkZAyXAdKNyxUr-xFDA07VaMnlJl2yPAaIb8gvMz5Hvxamk4gf6kkxv9wEFosA5DpRzMHLmnGUkUGyNDB1TbKCaERcCLnIGDYLB2Bn1AECJc5J0GLRLqkdBU97Ibl3r5YadgfWme8HGZjQywsPt6OEYjzekYQk-rSVn19HfbEmVhWov3rcELIF7nAS3lwT3vCS4XRJcUxKgmhEXAi5yB6WDwdgdFQ5AiXuSbJc72W55RdWZsd2-97pdgm6Tu7lgNRUMPapTpYdDnytavDR5p8UEojN5T_geOANgOOma6IN1L9sz8KHNiww1balW98vRxKHONyYE7Z9MQB54x3Z7Pbu98-z2Ors9k91QzYgLARd5g3bDYOyN2g2gxDvJbg9UC_9Sa2QvGRAE_rFkfk8y_zzJ_E4y3yQZVDPiQsBF_qBkMBj7o5IBKPFPkszXkt2ydK8YvB9g-1gybPc0w_Z5ogHJTjVFYZBNVzQjQ42Mesif9mVb78v2-L5s633ZHpXvBi5XeKNOFfuwVtUuUqJ50VW9gVsRMcASOHMdE2y3a21cEwwW8u8mGIT30gTTdk1GcPvz1dbnL34Hm_KyLnJ132dwoekOZKyjRgaiRvpRI2dGjRyiRoxRIzpq5gusvpliMhw1fefEZDxq-mKJhy-E1oVVMqE-wDL18fa6fWdhyRUr2cK6Uv9mVKwX1qJ6U7i2zpQ2syyXXFhXj7Ro2IVFW8lvX6q0ewCoIKfqS7DUT9_-A1NHdDs)

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- Tools -->
## Tools ##

Below is a directory of links to a document per template explaining what the tools that are included in code quality templates are, how they are currently configured and how to use them.

1. [Bridgecrew_Checkov]
2. [Checkmarx_KICS]
3. [GitHub_Super_Linter]
4. [Infracost]
5. [Megalinter]
6. [Mend_Bolt] - Formerly Whitesource Bolt
7. [OWASP]
8. [Sonar_Cloud]
9. [Template_updater]
10. [terraform_Compliance]
11. [Terrascan]
12. [TFLint]
13. [TFSec]

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- Tools -->
## Language and Tool Support ##

Below is a table showing what languages and tools are covered by the included templates.

| language/format              | Checkov              | Checkmarx KICS       | Megalinter           | Mend Bolt            | OWASP Dependency Checker | OWASP ZAP scanner    | Sonar Cloud          | Terrascan            | TFLint               | TFSec                |
| ---------------------------- | :--------------------: | :--------------------: | :--------------------: | :--------------------: | :------------------------: | :--------------------: | :--------------------: | :--------------------: | :--------------------: | :--------------------: |
| .net                         |                      |                      |                      |                      | :white_check_mark:     |                      |                      |                      |                      |                      |
| ABAP                         |                      |                      |                      |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| ACTION                       |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| ANSIBLE                      |                      | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| Apex                         |                      |                      |                      |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| ARM                          | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      | :white_check_mark: |                      |                      |
| Azure blueprints             |                      | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| bash                         |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| C                            |                      |                      | :white_check_mark: | :white_check_mark: | :white_check_mark:     |                      | :white_check_mark: |                      |                      |                      |
| C#??(CSHARP)                  |                      |                      | :white_check_mark: | :white_check_mark: |                          |                      | :white_check_mark: |                      |                      |                      |
| C++??(CPP)                    |                      |                      | :white_check_mark: | :white_check_mark: | :white_check_mark:     |                      | :white_check_mark: |                      |                      |                      |
| CDK                          |                      | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| CDK?? for terraform           |                      | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| CLOJURE                      |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| CLOUDFORMATION               | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      | :white_check_mark: | :white_check_mark: |                      |                      |
| cobol                        |                      |                      |                      |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| COFFEE                       |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| COPYPASTE                    |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| CREDENTIALS                  |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| CSS                          |                      |                      | :white_check_mark: |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| DART                         |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| Docker Compose               |                      | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| DOCKERFILE                   | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      | :white_check_mark: |                      |                      |
| EDITORCONFIG                 |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| ENV                          |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| Flex                         |                      |                      |                      |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| GHERKIN                      |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| GIT                          |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| GO                           |                      |                      | :white_check_mark: | :white_check_mark: | :white_check_mark:     |                      | :white_check_mark: |                      |                      |                      |
| GRAPHQL                      |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| GROOVY                       |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| GRPC                         |                      | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| HELM charts                  | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      | :white_check_mark: |                      |                      |
| HTML                         |                      |                      | :white_check_mark: |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| JAVA                         |                      |                      | :white_check_mark: | :white_check_mark: | :white_check_mark:     | :white_check_mark: | :white_check_mark: |                      |                      |                      |
| JAVASCRIPT                   |                      |                      | :white_check_mark: |                      | :white_check_mark:     | :white_check_mark: | :white_check_mark: |                      |                      |                      |
| JSON                         |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| JSX                          |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| KOTLIN                       |                      |                      | :white_check_mark: |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| KUBERNETES                   | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| LATEX                        |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| LUA                          |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| MARKDOWN                     |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| OPENAPI                      |                      | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| PERL                         |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| PHP                          |                      |                      | :white_check_mark: | :white_check_mark: |                          |                      | :white_check_mark: |                      |                      |                      |
| POWERSHELL                   |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| PROTOBUF                     |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| PUPPET                       |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| PYTHON                       |                      |                      | :white_check_mark: | :white_check_mark: | :white_check_mark:     |                      | :white_check_mark: |                      |                      |                      |
| R                            |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| RAKU                         |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| RST                          |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| RUBY                         |                      |                      | :white_check_mark: | :white_check_mark: | :white_check_mark:     |                      | :white_check_mark: |                      |                      |                      |
| RUST                         |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| SALESFORCE                   |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| SAM                          | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| SCALA                        |                      |                      | :white_check_mark: |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| SNAKEMAKE                    |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| SPELL                        |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| SQL                          |                      |                      | :white_check_mark: |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| SWIFT                        |                      |                      | :white_check_mark: |                      | :white_check_mark:     |                      | :white_check_mark: |                      |                      |                      |
| TEKTON                       |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| TERRAFORM                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| Terraform modules            | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| Terraform plan               | :white_check_mark: | :white_check_mark: | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| TSX                          |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |
| TYPESCRIPT                   |                      |                      | :white_check_mark: |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| Visual Basic .NET??(VBDOTNET) |                      |                      | :white_check_mark: |                      | :white_check_mark:     |                      | :white_check_mark: |                      |                      |                      |
| XML                          |                      |                      | :white_check_mark: |                      |                          |                      | :white_check_mark: |                      |                      |                      |
| YAML                         |                      |                      | :white_check_mark: |                      |                          |                      |                      |                      |                      |                      |

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- USAGE -->
## Usage ##

Please if possible use the folder structure in this Repo to keep a uniform structure across all our repos. Doing so enables developers to to pick things up quicker should they switch teams. However, if not you can modify the templates as required.

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- ROADMAP -->
## Roadmap ##

- [x] Create and test initial templates
- [x] Add this pipeline guide
- [x] Add templates for any paid for tools
- [ ] Get terraform compliance stage to work
- [ ] Implementation for hero products
- [ ] Scripted pipeline to run against existing repos in the organisation
- [ ] Enterprise level reporting - possibly via power bi

---
<!-- Readme Navigation -->
[(Back to the Table of Contents)](#table-of-contents)

---

<!-- CONTRIBUTING -->
## Contributing ##

Contributions are always **greatly appreciated**.

If there is a free tool you think should be added, please clone the Repo and create a pull request. For any proposed paid tools please use the contacts section further down before adding to this Repo.
Thanks again!

1. Clone the Repo (`git clone https://dev.azure.com/bcagroup/BCA.Operations.Utilities/_git/repo_template`)
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

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

<!-- REFERENCES -->
## References ##

Below is a list of useful references

- [ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [Best README template](https://github.com/othneildrew/Best-README-Template/) - really nice markdown templates
- [Bridgecrew](https://bridgecrew.io/) - paid version of Checkov
- [Checkmarx KICS](https://checkmarx.com/product/opensource/kics-open-source-infrastructure-as-code-project/) - open source policy-as-code based
- [Checkov](https://www.checkov.io/) - Open source policy-as-code based
- [CycloneDX](https://cyclonedx.org/)
- [CycloneDX GitHub](https://github.com/CycloneDX)
- [GitHub Super Linter](https://github.com/github/super-linter/) - open source multi languages linter tool written and maintained by GitHub
- [Mega Linter](https://megalinter.github.io/latest/) - project forked from GitHub Super Linter which includes some auto fixes and more useful report output formats
- [Mend (formerly Whitesource) Bolt](https://whitesource.atlassian.net/wiki/spaces/WD/pages/1641644045/Mend+Bolt+for+Azure+Pipelines/) - enforce open source licence compliance including on dependencies and open source dependency management (SCA)
- [OWASP](https://owasp.org/)
- [OWASP Dependency Track](https://owasp.org/www-project-dependency-track/)
- [OWASP Dependency Track GitHub](https://github.com/DependencyTrack/dependency-track)
- [Prisma Cloud](https://www.paloaltonetworks.com/prisma/cloud) - by Palo Alto networks the owners of Bridgecrew
- [terraform](https://www.terraform.io/)
- [terraform Best Practices](https://www.terraform-best-practices.com/) - really useful reference guide with some translations for foreign colleagues
- [terraform Compliance](https://terraform-compliance.com/)
- [Terrascan](https://runterrascan.io/)
- [TFLint](https://github.com/terraform-linters/tflint/) - terraform linter written and maintained by some of Hashicorp's own developers - used to be shipped with terraform as standard
- [TFSec](https://aquasecurity.github.io/tfsec/) - nice lightweight policy-as-code tool for terraform. there is also a really good Visual Studio Code extension from them

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
