# FishTracker Workflow

This repository contains the R workflow used for the comparative evaluation of two automated fish counting software tools using acoustic camera data (Godeaux et al., 2026), together with the associated statistics and figures.

The main entry point is:

- `Code_and_data/FishTracker_workflow.R`

The script uses paths relative to the repository, so it should run after a fresh clone without manually editing file paths.

## Repository layout

```text
Godeaux_et_al._2026/
  Code_and_data/
    FishTracker_workflow.R
    data/
      Survey 2020/
      Survey 2023/
  README.md
  .gitattributes
  Subset.zip
```

## Requirements

- R installed locally
- Internet access the first time you run the script, so missing packages can be installed from CRAN

The script uses these packages:

- `ggplot2`
- `dplyr`
- `tidyr`
- `lubridate`
- `scales`
- `DescTools`
- `epiR`
- `patchwork`
- `openair`

## How to run

### In RStudio

1. Open the repository in RStudio.
2. Open `Code_and_data/FishTracker_workflow.R`.
3. Click `Source` or run the script.

### In the R console

From the repository root, run the script in R.

If the script is launched from another folder, it will try to locate the repository automatically.

## Getting the files

There are two different ways to use this repository.

### Option 1: code only

If someone only wants to read the code, they can use GitHub's regular download button:

1. Open the repository page on GitHub.
2. Click `Code`.
3. Click `Download ZIP`.
4. Unzip the folder on the computer.

This is enough to get the R script and the documentation.

### Option 2: full repository with `Subset.zip`

`Subset.zip` is a large file stored with Git LFS. That means it is not a normal file inside GitHub's main storage.

For the full repository, the safest method is to clone it with Git and Git LFS:

1. Install Git.
2. Install Git LFS.
3. Open a terminal.
4. Run:

```bash
git clone https://github.com/GQxD/Godeaux_et_al._2026.git
cd Godeaux_et_al._2026
git lfs install
git lfs pull
```

5. Check that `Subset.zip` is present in the repository folder.
6. If needed, unzip `Subset.zip` before running the analysis.

Important:

- If Git LFS is not installed, `Subset.zip` may appear as a small pointer file instead of the real archive.
- By default, GitHub source-code ZIP downloads do not include Git LFS objects unless the repository is configured to include them in archives.
- If a user is not comfortable with the command line, the easiest solution is usually to ask someone to install Git LFS once and clone the repository for them.

## Input data

The workflow expects the raw files to stay in these folders:

- `Code_and_data/data/Survey 2020/`
- `Code_and_data/data/Survey 2023/`

Important files include:

- `Code_and_data/data/Survey 2020/CSOT_2020-12-15_merged.txt`
- `Code_and_data/data/Survey 2020/comparaison_work_HV.txt`
- `Code_and_data/data/Survey 2020/climatik-request-3156645`
- `Code_and_data/data/Survey 2020/data_ccc_technical_note_op1_op2.txt`
- `Code_and_data/data/Survey 2023/CSOT_merged_exportTortSpee.txt`
- `Code_and_data/data/Survey 2023/data_2023_2024_S5(Last).txt`
- `Code_and_data/data/Survey 2023/data_2023_2024_combined_cleaning_manuel(Last).txt`
- `Code_and_data/data/Survey 2023/ClimatiK 12-24_12_2023/Vent_2023.txt`

If one of these files is missing, the script stops with a clear error message.

## Outputs

Figures are written to:

- `Outputs/`

The folder is created automatically if it does not already exist.

## Large file note

`Subset.zip` is stored with Git LFS because it is larger than the standard GitHub file limit for normal Git objects.

Git LFS keeps a small pointer in the repository and stores the real file separately. That is why the archive has to be pulled after cloning.

## Notes

- The script uses relative paths, so avoid moving the `Code_and_data/data/` folder unless you also update the script.
- If you rename one of the raw files, update the corresponding path in `FishTracker_workflow.R`.
- The workflow processes both seasons:
  - 2020-2021
  - 2023-2024

## Troubleshooting

- **Missing package**: rerun the script and let it install the required package.
- **File not found**: check that the raw data folders and filenames match the structure above.
- **No output created**: make sure the script finished without an error and that the `Outputs/` folder is writable.
