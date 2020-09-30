library(readxl)
library(tidyverse)
library(tidyr)

#initialize readin listing
sheets_fromexcel <- list()

sheetlist <- excel_sheets(path="D:/OneDrive - CGIAR/Scientist requests/Job_Kihara/data_transpose/CAS-UNEP Gas samples_JK_01_John.xlsx")

for (i in 1:length(sheetlist)){
  tempdf <- read_excel(path="D:/OneDrive - CGIAR/Scientist requests/Job_Kihara/data_transpose/CAS-UNEP Gas samples_JK_01_John.xlsx", sheet = sheetlist[i])
  tempdf$sheetname <- sheetlist[i]
  sheets_fromexcel[[i]] <- tempdf 
}

transposed_sheets <- list()


for(i in 1:length(sheets_fromexcel)){
  
  df <- sheets_fromexcel[[i]]
  
  transposed_sheets[[i]] <- df %>%
    select(`SAMPLE NAME`, Plot, `CH4 conc (ppm)`, `CO2 conc (ppm)`, `N2O conc (ppb)`) %>% 
    filter(str_detect(`SAMPLE NAME`, "SM")) %>% 
    mutate(id = (row_number()-1) %% 4 + 1) %>% 
    group_by(id) %>%
    mutate(row = row_number()) %>% 
    pivot_wider(names_from = "id",
                values_from = c(`SAMPLE NAME`, `CH4 conc (ppm)`, `CO2 conc (ppm)`, `N2O conc (ppb)`),
                names_glue = "V{id}{.value}") %>% 
    select(V1 = `V1SAMPLE NAME`, V2 = `V2SAMPLE NAME`, V3 = `V3SAMPLE NAME`, V4 = `V4SAMPLE NAME`, everything()) %>% 
    select(-row)
 
}

new_data <- dplyr::bind_rows(transposed_sheets)

write_csv(new_data, "D:/OneDrive - CGIAR/Scientist requests/Job_Kihara/data_transpose/transposed/CAS-UNEP Gas samples_JK_01_transposed.csv")