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

If you clone this repository and need the contents of `Subset.zip`, make sure Git LFS is installed on your machine.

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

