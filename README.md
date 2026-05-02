# FishTracker_workflow (Godeaux et al., 2026)

> R workflow for the comparative evaluation of two automated fish counting software tools (FishTracker and Sonar5) using acoustic camera data.

## 1. Métadonnées / Metadata

| Champ | Valeur |
|-------|--------|
| **Nom** | FishTracker_workflow |
| **Version** | Version finale pour publication (Avril 2026) |
| **Date** | Avril 2026 |
| **Auteurs / Développeurs** | Quentin Godeaux, Hervé Rogissart, Clément Rautureau, François Martignac, Franck Cattanéo, Jean Guillard |
| **Contact** | [À compléter : email de contact] |
| **Laboratoire / Organisme responsable** | [À compléter : ex. INRAE, UMR CARRTEL] |
| **Licence** | MIT License (Voir fichier `LICENSE`) |
| **Site web** | [À compléter] |
| **Code source** | [À compléter : URL du dépôt Git] |
| **Domaine scientifique** | Hydroacoustique, Écologie aquatique, Limnologie |
| **Fonctionnalités clés** | Traitement de données FishTracker et Sonar5, Analyse de concordance (CCC), Graphes de Bland-Altman, Analyse de données de vent |
| **Technologies** | R, RStudio |
| **Mots-clés** | Fish counting, acoustic camera, FishTracker, Sonar5, CCC, Bland-Altman |

## 2. Contexte et historique / Context & History

### Historique
- Matériel préparatoire : Scripts originaux d'analyse de données d'hydroacoustique.
- Versions précédentes : Première version stable de publication.
- Composants intégrés et dépendances : Utilisation de packages R open-source (`ggplot2`, `dplyr`, `epiR`, `openair`, etc.).
- Feuille de route / Roadmap : [À compléter]
- Logiciels équivalents : [À compléter]

### Projet(s) lié(s)
- **Publication de référence** : Godeaux, Q., Rogissart, H., Rautureau, C., Martignac, F., Cattanéo, F., & Guillard, J. (2026). Comparative evaluation of two automated fish counting software tools using acoustic camera data.

## 3. Objectifs / Objectives

### Objectifs scientifiques
Évaluer comparativement deux logiciels de comptage automatique de poissons (FishTracker et Sonar5) sur des données de caméras acoustiques (campagnes 2020-2021 et 2023-2024). L'évaluation se base sur des méthodes statistiques de concordance (Concordance Correlation Coefficients - CCC, diagrammes de Bland-Altman) et intègre l'impact des conditions environnementales, notamment le vent, sur la fiabilité des détections.

### Objectifs d'utilisation et de diffusion
- Durée de vie prévue : [À compléter]
- Utilisation prévue : Reproductibilité scientifique des résultats de l'article (Godeaux et al., 2026).
- Public cible : Chercheurs en écologie, ingénieurs en hydroacoustique, communauté scientifique.
- Objectifs de diffusion : Open science, publication d'un dépôt de recherche garantissant la transparence.
- Communauté de collaboration souhaitée : Oui
- Préservation : Dépôt sur un entrepôt de données pérenne (ex: Zenodo) recommandé.

## 4. Caractéristiques techniques / Technical Features

- **Technologies utilisées** : Langage R.
- **Dépendances** :
  - R installé localement.
  - Connexion Internet (lors de la première exécution) pour l'installation automatique des packages manquants.
  - Packages R : `ggplot2`, `dplyr`, `tidyr`, `lubridate`, `scales`, `DescTools`, `epiR`, `patchwork`, `openair`.
- **Réutilisation de briques existantes** : L'écosystème Tidyverse et le package `epiR` pour les statistiques épidémiologiques.
- **Contraintes techniques** : Le script utilise des chemins relatifs. Évitez de déplacer ou renommer les fichiers bruts ou les sous-dossiers de données sans ajuster le script.

## 5. Installation et utilisation / Installation & Usage

### Repository layout
This repository contains the R workflow and associated folders.
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

### Input data
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

> **Note**: If one of these files is missing, the script stops with a clear error message. If you rename one of the raw files, update the corresponding path in `FishTracker_workflow.R`.

The workflow processes both seasons: 2020-2021 and 2023-2024.

### How to run

**Option A : In RStudio**
1. Open the repository in RStudio.
2. Open `Code_and_data/FishTracker_workflow.R`.
3. Click `Source` or run the script.

**Option B : In the R console**
From the repository root, run the script in R.
If the script is launched from another folder, it will try to locate the repository automatically.

### Outputs
Figures are written to the `Outputs/` directory. The folder is created automatically if it does not already exist.

### Troubleshooting
- **Missing package**: rerun the script and let it install the required package.
- **File not found**: check that the raw data folders and filenames match the structure above.
- **No output created**: make sure the script finished without an error and that the `Outputs/` folder is writable.

## 6. Organisation de l'équipe et du développement / Team & Development Organisation

### Gouvernance
- Organisme responsable : [À compléter]

### Équipe
- Membres (Auteurs de l'étude) : Quentin Godeaux, Hervé Rogissart, Clément Rautureau, François Martignac, Franck Cattanéo, Jean Guillard.

### Organisation du développement
- Méthodes et outils : Script d'analyse (standalone).
- Gestion des versions : Git / GitHub ou GitLab local.
- Documentation : Markdown et commentaires exhaustifs au sein du code R.

## 7. Diffusion et citation / Distribution & Citation

### Dépôt de référence
- URL du dépôt principal : [À compléter]
- Identifiant pérenne (DOI) : [À compléter]

### Citation
> Godeaux, Q., Rogissart, H., Rautureau, C., Martignac, F., Cattanéo, F., & Guillard, J. (2026). Comparative evaluation of two automated fish counting software tools using acoustic camera data. [À compléter avec le nom de la revue/journal et le DOI].

### Subset availability
The data subset can be found in the repository’s releases section under the name “Subset – Version 1.0” (File `Subset.zip` is available in the root).

## 8. Gestion du Plan de Gestion de Logiciel / SMP Management

- Responsable du SMP : [À compléter]
- Fréquence de mise à jour : À l'occasion de la publication de l'article ou de mises à jour majeures du jeu de données.
- Lien avec le DMP (Data Management Plan) : [À compléter]

## 9. Licences et propriété intellectuelle / Legal & IP

- Auteurs et détenteurs des droits : Quentin Godeaux, Hervé Rogissart, Clément Rautureau, François Martignac, Franck Cattanéo, Jean Guillard.
- Licence du code : **MIT License** (permet une réutilisation large et ouverte, idéale pour les scripts accompagnant une publication).
- Date d'ouverture prévue : Immédiate lors de la publication.

---
*Ce README est structuré selon le Modèle de Plan de Gestion de Logiciel de la Recherche – Projet PRESOFT V3.2 (CNRS/IN2P3, 2018).*
