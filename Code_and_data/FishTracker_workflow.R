# =========================================================='
# Comparative evaluation of two automated fish counting software tools using acoustic camera data.
# Quentin Godeaux, Hervé Rogissart, Clément Rautureau, François Martignac, Franck Cattanéo, Jean Guillard.  
# =========================================================='
# Purpose: Core analysis 
# Structure: Libraries â†’ Data Loading â†’ Analysis â†’ Export
# Both seasons analyzed: 2020-2021 and 2023-2024
# April 2026 
# =========================================================='


# ==================================='
# LOAD PACKAGES AND DEFINE PATHS ####
# ==================================='

# =========================================================='
## LIBRARY LOADING & SETUP                              ####
# =========================================================='

# Packages
required_packages <- c(
  "ggplot2", "dplyr", "tidyr", "lubridate", "scales", "DescTools", "epiR", "patchwork", "openair")

missing_packages <- required_packages[!required_packages %in% rownames(installed.packages())]
if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}
invisible(lapply(required_packages, library, character.only = TRUE))

# Resolve paths relative to the repo so the script works after a fresh download.
locate_repo_root <- function() {
  candidates <- character()

  cmd_args <- commandArgs(trailingOnly = FALSE)
  file_arg <- cmd_args[grepl("^--file=", cmd_args)]
  if (length(file_arg) > 0) {
    candidates <- c(candidates, dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/", mustWork = FALSE)))
  }

  if (requireNamespace("rstudioapi", quietly = TRUE)) {
    ctx <- try(rstudioapi::getSourceEditorContext(), silent = TRUE)
    if (!inherits(ctx, "try-error") && !is.null(ctx$path) && nzchar(ctx$path)) {
      candidates <- c(candidates, dirname(normalizePath(ctx$path, winslash = "/", mustWork = FALSE)))
    }
  }

  ofile <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(ofile) && nzchar(ofile)) {
    candidates <- c(candidates, dirname(normalizePath(ofile, winslash = "/", mustWork = FALSE)))
  }

  candidates <- c(candidates, getwd())

  for (candidate in unique(candidates)) {
    candidate <- normalizePath(candidate, winslash = "/", mustWork = FALSE)
    if (dir.exists(file.path(candidate, "Code_and_data", "data"))) {
      return(candidate)
    }
    if (basename(candidate) == "Code_and_data" && dir.exists(file.path(candidate, "data"))) {
      return(normalizePath(file.path(candidate, ".."), winslash = "/", mustWork = FALSE))
    }
  }

  stop("Could not locate the repo root. Expected a Code_and_data/data folder.")
}

repo_root <- locate_repo_root()
data_root <- file.path(repo_root, "Code_and_data", "data")
season_root_2020 <- file.path(data_root, "Survey 2020")
season_root_2023 <- file.path(data_root, "Survey 2023")

# =========================================================='
## FILE PATHS                                           ####
# =========================================================='

# Season 2020-2021
file_FishT_2020 <- file.path(season_root_2020, "CSOT_2020-12-15_merged.txt")
file_Sonar_2020 <- file.path(season_root_2020, "comparaison_work_HV.txt")
file_Wind_2020 <- file.path(season_root_2020, "climatik-request-3156645")
file_OP <- file.path(season_root_2020, "data_ccc_technical_note_op1_op2.txt")

# Season 2023-2024
file_FishT_2023 <- file.path(season_root_2023, "CSOT_merged_exportTortSpee.txt")

# ========================================='
# CHAPTER A: SEASON 2020-2021 ANALYSIS ####
# ========================================='

# =========================================================='
## SECTION 1: LOAD DATA - 2020-2021                     ####
# =========================================================='

data_FishT_2020 <- read.delim(file_FishT_2020, header = TRUE, sep = ";") # FishTracker data 2020
data_sonar_2020 <- read.table(file_Sonar_2020, sep = "\t", header = TRUE, stringsAsFactors = FALSE) # Sonar5 data 2020
data_OP1_OP2 <- read.table(file_OP, sep = "\t", header = TRUE, stringsAsFactors = FALSE) # Data operator 1 & operator 2

# Load wind data
vent_candidates <- Sys.glob(file_Wind_2020)
if (length(vent_candidates) == 0) stop("Wind file not found")
data_vent <- read.csv(vent_candidates[1], sep = ";", header = TRUE, stringsAsFactors = FALSE)

# =========================================================='
## SECTION 2: DATA PREPARATION - 2020-2021              ####
# =========================================================='

# Prepare Sonar5
data_sonar_2020$DateTime <- ymd_h(paste(data_sonar_2020$Date, data_sonar_2020$Hour))

# Filter FishTracker data
data_FishT_2020 <- data_FishT_2020 %>%
  filter(!is.na(length)) %>%
  mutate(length = length * 100) %>%
  filter(length > 20 & length < 60, distance > 2) %>%
  filter(!(distance >= 3.10 & distance <= 3.80),
         !(distance >= 4.19 & distance <= 4.21),
         !(distance >= 5.70 & distance <= 7)) %>%
  group_by(id, Date, Time) %>%
  summarise(length = mean(length, na.rm = TRUE),
            distance = mean(distance, na.rm = TRUE),
            angle = mean(angle, na.rm = TRUE),
            direction = first(direction),
            detections_count = n(), .groups = "drop") %>%
  filter(detections_count <= 5)

# Create hourly detection counts
data_FishT_2020 <- data_FishT_2020 %>%
  mutate(DateTime = as.POSIXct(paste(Date, Time), format = "%Y-%m-%d %H:%M:%S")) %>%
  filter((DateTime >= as.POSIXct("2020-12-15") & DateTime <= as.POSIXct("2020-12-23 23:59:59")) |
         (DateTime >= as.POSIXct("2021-01-05") & DateTime <= as.POSIXct("2021-01-17 23:59:59")))

data_sonar_2020 <- data_sonar_2020 %>%
  mutate(DateTime = as.POSIXct(paste(DateTime), format = "%Y-%m-%d %H:%M:%S")) %>%
  filter((DateTime >= as.POSIXct("2020-12-15") & DateTime < as.POSIXct("2020-12-23")) |
         (DateTime >= as.POSIXct("2021-01-05") & DateTime < as.POSIXct("2021-01-17")))

# Hourly aggregation
time_seq_2020 <- c(
  seq(as.POSIXct("2020-12-15"), as.POSIXct("2020-12-23 23:00:00"), by = "hour"),
  seq(as.POSIXct("2021-01-05"), as.POSIXct("2021-01-17 23:00:00"), by = "hour")
)

data_FishT_2020_H <- data_FishT_2020 %>%
  mutate(DateTime = floor_date(DateTime, "hour")) %>%
  count(DateTime, name = "FishT") %>%
  right_join(data.frame(DateTime = time_seq_2020), by = "DateTime") %>%
  mutate(FishT = replace_na(FishT, 0))

data_sonar_2020_H <- data_sonar_2020 %>%
  select(DateTime, operator1, data_work_HV_hall_filtre) %>%
  rename(Sonar5 = data_work_HV_hall_filtre)

# Combine 2020-2021
combined_2020 <- data_sonar_2020_H %>%
  left_join(data_FishT_2020_H, by = "DateTime") %>%
  filter(!is.na(operator1) & !is.na(Sonar5) & !is.na(FishT))

# Filter December for additional analysis
combined_2020_december <- combined_2020 %>%
  filter(DateTime >= as.POSIXct("2020-12-15") & 
         DateTime <= as.POSIXct("2020-12-23 23:59:59"))

cat("\nâ”€â”€â”€ 2020-2021 Data Summary â”€â”€â”€\n")
cat("Total observations:", nrow(combined_2020), "\n")
cat("December only:", nrow(combined_2020_december), "\n\n")

# =========================================================='
## SECTION 3: CCC ANALYSIS - 2020-2021                  ####
# =========================================================='

ccc_sonar_2020 <- epi.ccc(combined_2020$Sonar5, combined_2020$operator1,
                          ci = "z-transform", conf.level = 0.95)
ccc_fishtracker_2020 <- epi.ccc(combined_2020$FishT, combined_2020$operator1,
                                ci = "z-transform", conf.level = 0.95)
ccc_OP <- epi.ccc(data_OP1_OP2$Operateur1, data_OP1_OP2$Operateur2,
                  ci = "z-transform", conf.level = 0.95)

# =========================================================='
## SECTION 4: VISUALIZATION - 2020-2021 TIME SERIES     ####
# =========================================================='

# Wind overlay 2020-2021
data_vent$DateTime <- as.POSIXct(
  paste(data_vent$AN, data_vent$MOIS, data_vent$JOUR, "07:00:00"),
  format = "%Y %m %d %H:%M:%S"
)

p_wind_2020 <- ggplot(combined_2020_december, aes(x = DateTime)) +
  geom_line(aes(y = FishT, color = "FishT"), size = 1.2) +
  geom_line(aes(y = Sonar5, color = "Sonar5"), size = 1.2) +
  geom_line(aes(y = operator1, color = "Operator1"), size = 1.2) +
  geom_line(data = data_vent, aes(x = DateTime, y = V * 100, color = "Wind Speed"),
            size = 1, linetype = "dashed") +
  geom_point(data = data_vent, aes(x = DateTime, y = VX * 100), color = "#800080", size = 3) +
  geom_text(data = data_vent, aes(x = DateTime, y = VX * 100, label = round(VX, 1)),
            color = "#800080", size = 3.5, vjust = -1) +
  scale_y_continuous(name = "Detections", limits = c(0, 850),
                     sec.axis = sec_axis(~ . / 100, name = "Wind (m/s)")) +
  scale_color_manual(values = c("FishT" = "#5E84B9", "Sonar5" = "#E69F00",
                                "Operator1" = "#009900", "Wind Speed" = "#800080")) +
  labs(x = "Date", y = "Detections", 
       title = "Detections vs Wind Conditions (Dec 2020)") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top", legend.title = element_blank(),
        panel.border = element_rect(color = "black", fill = NA, size = 1))

# Day/Night pattern 2020-2021
period_rects <- combined_2020_december %>%
  mutate(Day = as.Date(DateTime),
         Period = ifelse(format(DateTime, "%H:%M:%S") >= "18:00:00" | 
                        format(DateTime, "%H:%M:%S") < "07:00:00", 
                        "Night", "Day")) %>%
  distinct(Day, Period) %>%
  mutate(xmin = as.POSIXct(paste(Day, ifelse(Period == "Night", "18:00:00", "07:00:00"))),
         xmax = as.POSIXct(paste(Day, ifelse(Period == "Night", "07:00:00", "18:00:00"))) + 
                ifelse(Period == "Night", 86400, 0))

last_day <- max(as.Date(combined_2020_december$DateTime))
period_rects <- rbind(period_rects,
                      data.frame(Day = last_day, Period = "Night",
                                xmin = as.POSIXct(paste(last_day, "18:00:00")),
                                xmax = as.POSIXct(paste(last_day + 1, "07:00:00"))))

p_daynight_2020 <- ggplot(combined_2020_december, aes(x = DateTime)) +
  geom_rect(data = period_rects,
            aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = Period),
            alpha = 0.2, inherit.aes = FALSE) +
  scale_fill_manual(values = c("Night" = "lightblue", "Day" = "white")) +
  geom_line(aes(y = operator1, color = "Operator1"), size = 1.3) +
  ylim(0, 800) +
  scale_color_manual(values = c("Operator1" = "#E74C3C")) +
  labs(x = "Date", y = "Detections",
       title = "Day/Night Detection Pattern (2020)") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top", legend.title = element_blank(),
        panel.border = element_rect(color = "black", fill = NA, size = 1))

# =============================================================='
## SECTION 5: VISUALIZATION - 2020-2021 CCC & BLAND-ALTMAN  ####
# =============================================================='

plot_ccc <- function(x, y, ccc_result, title, color) {
  df <- data.frame(x = x, y = y)
  ccc_val <- round(ccc_result$rho.c[1], 3)
  
  ggplot(df, aes(x = x, y = y)) +
    geom_point(color = color, size = 1.5, alpha = 0.7) +
    geom_smooth(method = "lm", se = FALSE, color = "darkgrey", size = 0.8) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red", size = 0.8) +
    labs(title = paste0(title, "\nCCC = ", ccc_val),
         x = "Operator1 (manual)", y = "Automated") +
    coord_equal() +
    theme_minimal(base_size = 11) +
    theme(plot.title = element_text(size = 12, face = "plain"),
          panel.border = element_rect(color = "black", fill = NA, size = 1))
}

plot_bland_altman <- function(x, y, title, color) {
  df <- data.frame(
    mean = (x + y) / 2,
    diff = x - y
  )
  
  mean_diff <- mean(df$diff, na.rm = TRUE)
  sd_diff <- sd(df$diff, na.rm = TRUE)
  upper_limit <- mean_diff + 1.96 * sd_diff
  lower_limit <- mean_diff - 1.96 * sd_diff
  
  ggplot(df, aes(x = mean, y = diff)) +
    geom_point(color = color, size = 1.5, alpha = 0.7) +
    geom_hline(yintercept = mean_diff, linetype = "dashed", color = "red", linewidth = 1) +
    geom_hline(yintercept = upper_limit, linetype = "dotted", color = "darkgreen", linewidth = 0.8) +
    geom_hline(yintercept = lower_limit, linetype = "dotted", color = "darkgreen", linewidth = 0.8) +
    annotate("text", x = max(df$mean, na.rm = TRUE), y = mean_diff, 
             label = "Mean", hjust = -0.1, vjust = -1, size = 3, color = "red") +
    annotate("text", x = max(df$mean, na.rm = TRUE), y = upper_limit, 
             label = "+1.96 SD", hjust = -0.1, vjust = -1, size = 3, color = "darkgreen") +
    annotate("text", x = max(df$mean, na.rm = TRUE), y = lower_limit, 
             label = "-1.96 SD", hjust = -0.1, vjust = 1, size = 3, color = "darkgreen") +
    labs(title = title,
         x = "Mean", y = "Difference") +
    theme_minimal(base_size = 11) +
    theme(plot.title = element_text(size = 12, face = "plain"),
          panel.border = element_rect(color = "black", fill = NA, size = 1))
}

# CCC plots 2020-2021
p_ccc_sonar_2020 <- plot_ccc(combined_2020$Sonar5, combined_2020$operator1, ccc_sonar_2020,
                             "Sonar5 vs Operator1 (2020)", "steelblue")
p_ccc_fish_2020 <- plot_ccc(combined_2020$FishT, combined_2020$operator1, ccc_fishtracker_2020,
                            "FishTracker vs Operator1 (2020)", "MediumPurple")
p_ccc_op <- plot_ccc(data_OP1_OP2$Operateur1, data_OP1_OP2$Operateur2, ccc_OP,
                     "Operator1 vs Operator2", "darkorange")

# Bland-Altman plots 2020-2021
p_ba_sonar_2020 <- plot_bland_altman(combined_2020$Sonar5, combined_2020$operator1,
                                     "Sonar5 vs Operator1 (2020)", "steelblue")
p_ba_fish_2020 <- plot_bland_altman(combined_2020$FishT, combined_2020$operator1,
                                    "FishTracker vs Operator1 (2020)", "MediumPurple")
p_ba_op <- plot_bland_altman(data_OP1_OP2$Operateur1, data_OP1_OP2$Operateur2,
                             "Operator1 vs Operator2", "darkorange")

# Combined layouts 2020-2021
combined_sonar_2020 <- p_ccc_sonar_2020 | p_ba_sonar_2020
combined_fish_2020 <- p_ccc_fish_2020 | p_ba_fish_2020
combined_op <- p_ccc_op | p_ba_op

# ========================================='
# CHAPTER B: SEASON 2023-2024 ANALYSIS ####
# ========================================='

# =========================================================='
## SECTION 1: LOAD DATA - 2023-2024                     ####
# =========================================================='

sonar_2023_candidates <- Sys.glob(file.path(season_root_2023, "data_2023_2024_S5*.txt"))
manual_2023_candidates <- Sys.glob(file.path(season_root_2023, "data_2023_2024_combined_cleaning_manuel*.txt"))
wind_2023_candidates <- Sys.glob(file.path(season_root_2023, "ClimatiK 12-24_12_2023", "Vent_2023.txt"))

if (length(sonar_2023_candidates) == 0) stop("2023 Sonar file not found")
if (length(manual_2023_candidates) == 0) stop("2023 manual file not found")
if (!file.exists(file_FishT_2023)) stop("2023 FishT file not found")
if (length(wind_2023_candidates) == 0) stop("2023 wind file not found")

data_sonar_2023 <- read.table(sonar_2023_candidates[1], sep = "\t", header = TRUE, stringsAsFactors = FALSE)
data_manual_2023 <- read.table(manual_2023_candidates[1], sep = "\t", header = TRUE, stringsAsFactors = FALSE)
data_fisht_2023 <- read.table(file_FishT_2023, sep = ";", header = TRUE, stringsAsFactors = FALSE)
data_wind_2023 <- read.table(wind_2023_candidates[1], sep = ";", header = TRUE, stringsAsFactors = FALSE)

# =========================================================='
## SECTION 2: DATA PREPARATION - 2023-2024 ####
# =========================================================='

# Prepare dates
data_manual_2023$Date <- as.Date(data_manual_2023$Date, format = "%d/%m/%Y")
data_sonar_2023$DateTime <- ymd_h(paste(data_sonar_2023$Date, data_sonar_2023$Hour))
data_manual_2023$DateTime <- ymd_h(paste(data_manual_2023$Date, data_manual_2023$Hour))

# Filter FishTracker 2023
data_fisht_2023 <- data_fisht_2023 %>%
  filter(!is.na(length)) %>%
  mutate(length = length * 100) %>%
  filter(length > 20 & length < 60, distance > 4, speed > 0.1) %>%
  group_by(id, Date, Time) %>%
  summarise(length = mean(length, na.rm = TRUE),
            distance = mean(distance, na.rm = TRUE),
            angle = mean(angle, na.rm = TRUE),
            direction = first(direction),
            detections_count = n(), .groups = "drop") %>%
  filter(detections_count <= 5) %>%
  mutate(DateTime = as.POSIXct(paste(Date, Time), format = "%Y-%m-%d %H:%M:%S")) %>%
  filter(DateTime >= as.POSIXct("2023-12-12") & DateTime <= as.POSIXct("2023-12-23 23:59:00"))

# Hourly aggregation 2023
hour_seq_2023 <- seq(as.POSIXct("2023-12-12"), as.POSIXct("2023-12-23 23:00:00"), by = "hour")

data_fisht_2023_H <- data_fisht_2023 %>%
  mutate(DateTime = floor_date(DateTime, "hour")) %>%
  count(DateTime, name = "FishT_Detections") %>%
  right_join(data.frame(DateTime = hour_seq_2023), by = "DateTime") %>%
  mutate(FishT_Detections = replace_na(FishT_Detections, 0))

# Combine 2023 data
data_sonar_2023 <- data_sonar_2023 %>%
  rename(Sonar5 = Effectif) %>%
  mutate(DateTime = as.POSIXct(DateTime, format = "%Y-%m-%d %H:%M:%S"))

data_manual_2023 <- data_manual_2023 %>%
  rename(Operator1 = Effectif) %>%
  mutate(DateTime = as.POSIXct(DateTime, format = "%Y-%m-%d %H:%M:%S"))

combined_2023 <- data_sonar_2023 %>%
  select(DateTime, Sonar5) %>%
  left_join(data_manual_2023 %>% select(DateTime, Operator1), by = "DateTime") %>%
  left_join(data_fisht_2023_H, by = "DateTime") %>%
  filter(DateTime >= as.POSIXct("2023-12-12") & DateTime <= as.POSIXct("2023-12-23 23:59:59")) %>%
  filter(!is.na(Sonar5) & !is.na(Operator1) & !is.na(FishT_Detections)) %>%
  rename(FishT = FishT_Detections)

# Wind data 2023
data_wind_2023 <- data_wind_2023 %>%
  mutate(Date = as.Date(paste(AN, MOIS, JOUR, sep = "-"), format = "%Y-%m-%d"),
         DateTime = as.POSIXct(Date)) %>%
  filter(Date >= as.Date("2023-12-12") & Date <= as.Date("2023-12-24"))

# =========================================================='
## SECTION 3: WIND ANALYSIS - 2023-2024                 ####
# =========================================================='

# Create period classification
data_wind_2023_pÃ©riode <- data_wind_2023 %>%
  mutate(PERIODE = case_when(
    JOUR >= 12 & JOUR <= 18 ~ "Period1 (12-18 Dec)",
    JOUR >= 19 & JOUR <= 23 ~ "Period2 (19-23 Dec)",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(PERIODE))

# Descriptive statistics by period
wind_stats <- data_wind_2023_pÃ©riode %>%
  group_by(PERIODE) %>%
  summarise(
    Observations = n(),
    V_mean = mean(V, na.rm = TRUE),
    V_sd = sd(V, na.rm = TRUE),
    VX_mean = mean(VX, na.rm = TRUE),
    VX_sd = sd(VX, na.rm = TRUE),
    V_min = min(V, na.rm = TRUE),
    V_max = max(V, na.rm = TRUE),
    VX_min = min(VX, na.rm = TRUE),
    VX_max = max(VX, na.rm = TRUE),
    .groups = "drop"
  )

print(wind_stats) # Wind statistics 2023-2024
cat("\nâ”€â”€â”€ 2023-2024 Data Summary â”€â”€â”€\n")
cat("Total observations:", nrow(combined_2023), "\n\n")

# =========================================================='
## SECTION 4: CCC ANALYSIS - 2023-2024                  ####
# =========================================================='

ccc_sonar_2023 <- epi.ccc(combined_2023$Sonar5, combined_2023$Operator1,
                          ci = "z-transform", conf.level = 0.95)
ccc_fishtracker_2023 <- epi.ccc(combined_2023$FishT, combined_2023$Operator1,
                                ci = "z-transform", conf.level = 0.95)

# =========================================================='
## SECTION 5: VISUALIZATION - 2023-2024 TIME SERIES     ####
# =========================================================='

p_wind_2023 <- ggplot(combined_2023, aes(x = DateTime)) +
  geom_line(aes(y = FishT, color = "FishT"), size = 1) +
  geom_line(aes(y = Sonar5, color = "Sonar5"), size = 1) +
  geom_line(aes(y = Operator1, color = "Operator1"), size = 1) +
  geom_line(data = data_wind_2023, aes(x = DateTime, y = V * 100, color = "Wind Speed"),
            size = 0.9, linetype = "dashed", inherit.aes = FALSE) +
  geom_point(data = data_wind_2023, aes(x = DateTime, y = VX * 100),
             color = "#800080", size = 2, inherit.aes = FALSE) +
  geom_text(data = data_wind_2023, aes(x = DateTime, y = VX * 100, label = round(VX, 1)),
            color = "#800080", size = 3.5, vjust = -1) +
  scale_y_continuous(name = "Detections", limits = c(0, 1400),
                     sec.axis = sec_axis(~ . / 100, name = "Wind (m/s)")) +
  scale_color_manual(values = c("FishT" = "#5E84B9", "Sonar5" = "#E69F00",
                                "Operator1" = "#009900", "Wind Speed" = "#800080")) +
  labs(x = "Date", y = "Detections",
       title = "Detections vs Wind Conditions (Dec 2023)") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top", legend.title = element_blank(),
        panel.border = element_rect(color = "black", fill = NA, size = 1))

# =============================================================='
## SECTION 6: VISUALIZATION - 2023-2024 CCC & BLAND-ALTMAN  ####
# =============================================================='

# CCC plots 2023-2024
p_ccc_sonar_2023 <- plot_ccc(combined_2023$Sonar5, combined_2023$Operator1, ccc_sonar_2023, "Sonar5 vs Operator1 (2023)", "steelblue")
p_ccc_fish_2023 <- plot_ccc(combined_2023$FishT, combined_2023$Operator1, ccc_fishtracker_2023, "FishTracker vs Operator1 (2023)", "MediumPurple")

# Bland-Altman plots 2023-2024
p_ba_sonar_2023 <- plot_bland_altman(combined_2023$Sonar5, combined_2023$Operator1, "Sonar5 vs Operator1 (2023)", "steelblue")
p_ba_fish_2023 <- plot_bland_altman(combined_2023$FishT, combined_2023$Operator1, "FishTracker vs Operator1 (2023)", "MediumPurple")

# Combined layouts 2023-2024
combined_sonar_2023 <- p_ccc_sonar_2023 | p_ba_sonar_2023
combined_fish_2023  <- p_ccc_fish_2023 | p_ba_fish_2023

# =========================================================='
## SECTION 7: DISPLAY ALL PLOTS                         ####
# =========================================================='

cat("â”€â”€â”€ 2020-2021 TIME SERIES â”€â”€â”€\n")
cat("Plot 1: Wind Overlay (Dec 2020)\n")
print(p_wind_2020)

cat("\nPlot 2: Day/Night Pattern (2020)\n")
print(p_daynight_2020)

cat("\nâ”€â”€â”€ 2020-2021 AGREEMENT ANALYSIS â”€â”€â”€\n")
cat("Plot 3: CCC - Sonar5 vs Operator1 (2020)\n")
print(p_ccc_sonar_2020)

cat("\nPlot 4: CCC - FishTracker vs Operator1 (2020)\n")
print(p_ccc_fish_2020)

cat("\nPlot 5: Bland-Altman - Sonar5 vs Operator1 (2020)\n")
print(p_ba_sonar_2020)

cat("\nPlot 6: Bland-Altman - FishTracker vs Operator1 (2020)\n")
print(p_ba_fish_2020)

cat("\nPlot 7: Combined CCC + Bland-Altman - Sonar5 (2020)\n")
print(combined_sonar_2020)

cat("\nPlot 8: Combined CCC + Bland-Altman - FishTracker (2020)\n")
print(combined_fish_2020)

cat("\nâ”€â”€â”€ 2023-2024 TIME SERIES â”€â”€â”€\n")
cat("Plot 9: Wind Overlay (Dec 2023)\n")
print(p_wind_2023)

cat("\nâ”€â”€â”€ 2023-2024 AGREEMENT ANALYSIS â”€â”€â”€\n")
cat("Plot 10: CCC - Sonar5 vs Operator1 (2023)\n")
print(p_ccc_sonar_2023)

cat("\nPlot 11: CCC - FishTracker vs Operator1 (2023)\n")
print(p_ccc_fish_2023)

cat("\nPlot 12: Bland-Altman - Sonar5 vs Operator1 (2023)\n")
print(p_ba_sonar_2023)

cat("\nPlot 13: Bland-Altman - FishTracker vs Operator1 (2023)\n")
print(p_ba_fish_2023)

cat("\nPlot 14: Combined CCC + Bland-Altman - Sonar5 (2023)\n")
print(combined_sonar_2023)

cat("\nPlot 15: Combined CCC + Bland-Altman - FishTracker (2023)\n")
print(combined_fish_2023)

cat("\nâ”€â”€â”€ OPERATOR AGREEMENT â”€â”€â”€\n")
cat("Plot 16: CCC - Operator1 vs Operator2\n")
print(p_ccc_op)

cat("\nPlot 17: Bland-Altman - Operator1 vs Operator2\n")
print(p_ba_op)

cat("\nPlot 18: Combined CCC + Bland-Altman - Operators\n")
print(combined_op)

# =========================================================='
## SECTION 8: EXPORT FIGURES                            ####
# =========================================================='

output_dir <- file.path(repo_root, "Outputs")
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# 2020-2021 Exports
ggsave("01_Wind_Overlay_December_2020.png", plot = p_wind_2020,
       path = output_dir, width = 13, height = 7, dpi = 300)
cat("âœ“ 01_Wind_Overlay_December_2020.png\n")

ggsave("02_DayNight_Pattern_2020.png", plot = p_daynight_2020,
       path = output_dir, width = 12, height = 6, dpi = 300)
cat("âœ“ 02_DayNight_Pattern_2020.png\n")

ggsave("03_CCC_Sonar5_2020.png", plot = p_ccc_sonar_2020,
       path = output_dir, width = 7, height = 7, dpi = 300)
cat("âœ“ 03_CCC_Sonar5_2020.png\n")

ggsave("04_CCC_FishTracker_2020.png", plot = p_ccc_fish_2020,
       path = output_dir, width = 7, height = 7, dpi = 300)
cat("âœ“ 04_CCC_FishTracker_2020.png\n")

ggsave("05_BA_Sonar5_2020.png", plot = p_ba_sonar_2020,
       path = output_dir, width = 8, height = 7, dpi = 300)
cat("âœ“ 05_BA_Sonar5_2020.png\n")

ggsave("06_BA_FishTracker_2020.png", plot = p_ba_fish_2020,
       path = output_dir, width = 8, height = 7, dpi = 300)
cat("âœ“ 06_BA_FishTracker_2020.png\n")

ggsave("07_Combined_Sonar5_2020.png", plot = combined_sonar_2020,
       path = output_dir, width = 14, height = 6, dpi = 300)
cat("âœ“ 07_Combined_Sonar5_2020.png\n")

ggsave("08_Combined_FishTracker_2020.png", plot = combined_fish_2020,
       path = output_dir, width = 14, height = 6, dpi = 300)
cat("âœ“ 08_Combined_FishTracker_2020.png\n")

# 2023-2024 Exports
ggsave("09_Wind_Overlay_December_2023.png", plot = p_wind_2023,
       path = output_dir, width = 13, height = 7, dpi = 300)
cat("âœ“ 09_Wind_Overlay_December_2023.png\n")

ggsave("10_CCC_Sonar5_2023.png", plot = p_ccc_sonar_2023,
       path = output_dir, width = 7, height = 7, dpi = 300)
cat("âœ“ 10_CCC_Sonar5_2023.png\n")

ggsave("11_CCC_FishTracker_2023.png", plot = p_ccc_fish_2023,
       path = output_dir, width = 7, height = 7, dpi = 300)
cat("âœ“ 11_CCC_FishTracker_2023.png\n")

ggsave("12_BA_Sonar5_2023.png", plot = p_ba_sonar_2023,
       path = output_dir, width = 8, height = 7, dpi = 300)
cat("âœ“ 12_BA_Sonar5_2023.png\n")

ggsave("13_BA_FishTracker_2023.png", plot = p_ba_fish_2023,
       path = output_dir, width = 8, height = 7, dpi = 300)
cat("âœ“ 13_BA_FishTracker_2023.png\n")

ggsave("14_Combined_Sonar5_2023.png", plot = combined_sonar_2023,
       path = output_dir, width = 14, height = 6, dpi = 300)
cat("âœ“ 14_Combined_Sonar5_2023.png\n")

ggsave("15_Combined_FishTracker_2023.png", plot = combined_fish_2023,
       path = output_dir, width = 14, height = 6, dpi = 300)
cat("âœ“ 15_Combined_FishTracker_2023.png\n")

# Operator Agreement Exports
ggsave("16_CCC_Operator1_vs_Operator2.png", plot = p_ccc_op,
       path = output_dir, width = 7, height = 7, dpi = 300)
cat("âœ“ 16_CCC_Operator1_vs_Operator2.png\n")

ggsave("17_BA_Operator1_vs_Operator2.png", plot = p_ba_op,
       path = output_dir, width = 8, height = 7, dpi = 300)
cat("âœ“ 17_BA_Operator1_vs_Operator2.png\n")

ggsave("18_Combined_Operator_Agreement.png", plot = combined_op,
       path = output_dir, width = 14, height = 6, dpi = 300)
cat("âœ“ 18_Combined_Operator_Agreement.png\n")

# =========================================================='
## SECTION 9: WIND ANALYSIS - 2023-2024                 ####
# =========================================================='

# Extract wind data for 2023 (already loaded in data_wind_2023)
# Check if we need to load additional wind direction data
wind_full_2023_candidates <- Sys.glob(file.path(season_root_2023, "*Vent*2023*.csv"))

if (length(wind_full_2023_candidates) > 0) {
  # Load full wind data with direction (GVX column)
  data_wind_full_2023 <- read.table(wind_full_2023_candidates[1], sep = ";", header = TRUE, stringsAsFactors = FALSE)
  
  # Prepare wind data
  data_wind_full_2023 <- data_wind_full_2023 %>%
    mutate(JOUR = as.numeric(JOUR))
  
  # Create variable for two periods
  data_wind_full_2023 <- data_wind_full_2023 %>%
    mutate(PERIODE = case_when(
      JOUR >= 12 & JOUR <= 17 ~ "Dec 12-17",
      JOUR >= 18 & JOUR <= 23 ~ "Dec 18-23",
      TRUE ~ NA_character_
    ))
  
  # Select specific days for windrose (15, 16, 17, 20, 21, 22)
  jours_selected <- c(15, 16, 17, 20, 21, 22)
  
  data_wind_selected <- data_wind_full_2023 %>%
    filter(JOUR %in% jours_selected) %>%
    mutate(JOUR = factor(JOUR, levels = jours_selected))
  
  # Wind statistics by period
  wind_stats <- data_wind_full_2023 %>%
    filter(!is.na(PERIODE)) %>%
    group_by(PERIODE) %>%
    summarise(
      n_mesures = n(),
      V_mean = mean(V, na.rm = TRUE),
      V_sd = sd(V, na.rm = TRUE),
      VX_mean = mean(VX, na.rm = TRUE),
      VX_sd = sd(VX, na.rm = TRUE),
      V_min = min(V, na.rm = TRUE),
      V_max = max(V, na.rm = TRUE),
      .groups = "drop"
    )
  
  cat("\nâ”€â”€â”€ Wind Statistics by Period â”€â”€â”€\n")
  print(wind_stats)
  
  # Create windrose plots for selected days
  cat("\nâ”€â”€â”€ Generating Windrose Plots by Day â”€â”€â”€\n")
  
  # Create plot with facets by day (will display in console)
  p_windrose_days <- windRose(
    mydata = data_wind_selected,
    ws = "VX",
    wd = "GVX",
    breaks = c(0, 2.9, 4.9, 16.3),
    cols = c("yellow", "pink", "blue"),
    key = FALSE,
    paddle = FALSE,
    grid.line = 10,
    type = "JOUR",
    main = "Wind directions by day (2023: Days 15,16,17,20,21,22)"
  )
  
  cat("âœ“ Windrose by day generated\n")
  
  # Create overall windrose plot
  p_windrose_overall <- windRose(
    mydata = data_wind_full_2023 %>% filter(!is.na(PERIODE)),
    ws = "VX",
    wd = "GVX",
    breaks = c(0, 2.9, 4.9, 16.3),
    cols = c("orange", "green", "blue"),
    key.header = "Wind Speed (m/s)",
    key.position = "bottom",
    paddle = FALSE,
    grid.line = 10,
    main = "2023: Frequency of wind direction (%)"
  )
  
  cat("âœ“ Overall windrose plot generated\n\n")
  
} else {
  cat("\nâš  Warning: Full wind data file (with GVX column) not found.\n")
  cat("  Skipping detailed windrose analysis.\n")
  cat("  Expected: *Vent*2023*.csv in season folder\n\n")
}

# =========================================================='
## SECTION 10: SUMMARY STATISTICS                       ####
# =========================================================='

# CONCORDANCE CORRELATION COEFFICIENTS
cat("â”€â”€â”€ 2020-2021 SEASON â”€â”€â”€\n")
cat("Sonar5 vs Operator1:\n")
print(ccc_sonar_2020$rho.c)
cat("\nFishTracker vs Operator1:\n")
print(ccc_fishtracker_2020$rho.c)

cat("\nâ”€â”€â”€ 2023-2024 SEASON â”€â”€â”€\n")
cat("Sonar5 vs Operator1:\n")
print(ccc_sonar_2023$rho.c)
cat("\nFishTracker vs Operator1:\n")
print(ccc_fishtracker_2023$rho.c)

cat("\nâ”€â”€â”€ OPERATOR AGREEMENT â”€â”€â”€\n")
cat("Operator1 vs Operator2:\n")
print(ccc_OP$rho.c)

# =========================================================='
# END OF SCRIPT
# =========================================================='


