**FishTracker_workflow (Godeaux et al., 2026)**  
*R workflow for the comparative evaluation of two automated fish‑counting software tools (FishTracker and Sonar5) using acoustic‑camera data*  [1]

---

## 1. Metadata  

| Field | Value |
|-------|-------|
| **Name** | FishTracker_workflow |
| **Version** | Final version for publication (April 2026) |
| **Date** | April 2026 |
| **Authors / Developers** | Quentin Godeaux, Hervé Rogissart, Clément Rautureau, François Martignac, Franck Cattanéo, Jean Guillard |
| **Contact** | Clément Rautureau at clement.rautureau@inrae.fr |
| **Laboratory / Host Institution** | INRAE-USMB UMR CARRTEL |
| **License** | MIT License (see file `LICENSE`) |
| **Website** | *to be completed* |
| **Source code** | *to be completed (URL of the repository)* |
| **Scientific domain** | Hydroacoustics, Aquatic ecology, Limnology |
| **Key functionalities** | Processing of FishTracker and Sonar5 data, Concordance Correlation Coefficient (CCC) analysis, Bland‑Altman plots, Wind‑condition analysis |
| **Technologies** | R, RStudio |
| **Keywords** | Fish counting, acoustic camera, FishTracker, Sonar5, CCC, Bland‑Altman |

---

## 2. Context & History  

### History  

- **Pre‑processing**: Original scripts for hydroacoustic data analysis.  
- **Previous releases**: First stable version published.  
- **Integrated components & dependencies**: Uses open‑source R packages `ggplot2`, `dplyr`, `epiR`, `openair`, etc.  
- **Roadmap**: *to be completed*  
- **Equivalent software**: *to be completed*  

### Related projects  

- **Reference publication**: Godeaux, Q., Rogissart, H., Rautureau, C., Martignac, F., Cattanéo, F., & Guillard, J. (2026). *Comparative evaluation of two automated fish counting software tools using acoustic camera data*.

---

## 3. Objectives  

### Scientific objectives  

Evaluate, in a comparative manner, two automatic fish‑counting tools (FishTracker and Sonar5) on acoustic‑camera datasets collected during the 2020‑2021 and 2023‑2024 campaigns. The assessment is based on statistical concordance methods (Concordance Correlation Coefficient – CCC, Bland‑Altman diagrams) and incorporates the influence of environmental variables, notably wind, on detection reliability.

### Usage & dissemination objectives  

- **Planned lifespan**: *to be completed*  
- **Intended use**: Reproducibility of the results presented in the article (Godeaux et al., 2026).  
- **Target audience**: Researchers in ecology, hydroacoustic engineers, the broader scientific community.  
- **Dissemination goals**: Promote open science; provide a research‑data deposit ensuring transparency.  
- **Collaboration community**: Yes.  
- **Preservation**: Deposition in a long‑term repository (e.g., Zenodo) is recommended.

---

## 4. Technical Features  

- **Technologies**: R language.  
- **Dependencies**:  
  - Local R installation.  
  - Internet connection (required only for the first execution to install missing packages).  
  - R packages: `ggplot2`, `dplyr`, `tidyr`, `lubridate`, `scales`, `DescTools`, `epiR`, `patchwork`, `openair`.  
- **Reuse of existing blocks**: Tidyverse ecosystem and the `epiR` package for epidemiological statistics.  
- **Technical constraints**: The script relies on relative file paths; moving or renaming raw data folders/files without updating the script will cause errors.

---

## 5. Installation & Usage  

### Repository layout  

```
Godeaux_et_al._2026/
  Code_and_data/
    FishTracker_workflow.R
    data/
      Survey 2020/
      Survey 2023/
  README.md
  Subset.zip
```

### Input data  

The workflow expects the raw files to remain in the following locations:

- `Code_and_data/data/Survey 2020/`  
- `Code_and_data/data/Survey 2023/`

Key files include:

- `Code_and_data/data/Survey 2020/CSOT_2020-12-15_merged.txt`  
- `Code_and_data/data/Survey 2020/comparaison_work_HV.txt`  
- `Code_and_data/data/Survey 2020/climatik-request-3156645`  
- `Code_and_data/data/Survey 2020/data_ccc_technical_note_op1_op2.txt`  
- `Code_and_data/data/Survey 2023/CSOT_merged_exportTortSpee.txt`  
- `Code_and_data/data/Survey 2023/data_2023_2024_S5(Last).txt`  
- `Code_and_data/data/Survey 2023/data_2023_2024_combined_cleaning_manuel(Last).txt`  
- `Code_and_data/data/Survey 2023/ClimatiK 12-24_12_2023/Vent_2023.txt`

> **Note**: If a required file is absent, the script aborts with a clear error message. When renaming a raw file, update the corresponding path inside `FishTracker_workflow.R`.

The workflow processes both seasons (2020‑2021 and 2023‑2024).

### How to run  

#### Option A – In RStudio  

1. Open the repository in RStudio.  
2. Open `Code_and_data/FishTracker_workflow.R`.  
3. Click **Source** or execute the script line by line.

#### Option B – In the R console  

From the repository root, run:

```r
source("Code_and_data/FishTracker_workflow.R")
```

If the script is launched from another directory, it will attempt to locate the repository automatically.

### Outputs  

Figures are saved in the `Outputs/` directory, which is created automatically if it does not already exist.

### Troubleshooting  

- **Missing package**: Re‑run the script; it will install the required package automatically.  
- **File not found**: Verify that the raw‑data directories and file names match the structure described above.  
- **No output generated**: Ensure the script terminated without error and that the `Outputs/` folder has write permissions.

---

## 6. Team & Development  

### Governance  

- **Responsible institution**: INRAE-USMB UMR CARRTEL 

### Team members (authors of the study)  

Quentin Godeaux, Hervé Rogissart, Clément Rautureau, François Martignac, Franck Cattanéo, Jean Guillard.

### Development organisation  

- **Methods & tools**: Stand‑alone analysis script.  
- **Version control**: Git / GitHub or GitLab (local).  
- **Documentation**: Markdown files and extensive in‑code comments.

---

## 7. Distribution & Citation  

### Reference repository  

- **Main URL**: *to be completed*  
- **Persistent identifier (DOI)**: *to be completed*  

### Recommended citation  

> Godeaux, Q., Rogissart, H., Rautureau, C., Martignac, F., Cattanéo, F., & Guillard, J. (2026). *Comparative evaluation of two automated fish counting software tools using acoustic camera data*. *[Journal name]*, DOI *xxxx*.

### Subset availability  

A reduced data set (.aris files) is provided in the repository’s *Releases* section under the name “Subset – Version 1.0” (file `Subset.zip`).
(https://github.com/Github-Carrtel/Godeaux_et_al._2026/releases/tag/v1.0)
---

## 8. Software Management Plan (SMP)  

- **SMP manager**: *to be completed*  
- **Update frequency**: At the time of article publication or when major data‑set updates occur.  
- **Link to Data Management Plan (DMP)**: *to be completed*  

---

## 9. Legal & IP  

- **Authors / Rights holders**: Quentin Godeaux, Hervé Rogissart, Clément Rautureau, François Martignac, Franck Cattanéo, Jean Guillard.  
- **Code license**: **MIT License** – permits broad reuse, suitable for scripts accompanying a scientific publication.  
- **Planned opening date**: Immediately upon publication.   [1]

---

*This README is structured according to the Research Software Management Plan Template, PRESOFT Project V3.2 (CNRS/IN2P3, 2018).*
