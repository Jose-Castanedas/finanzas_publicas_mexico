# Cargar librerías

library(tidyverse)
library(readxl)

# Cargar archivos de datos

# Cargar archivos excel

gasto <- read_excel("data/raw/gasto_neto_presupuestario.xlsx")
ingreso <- read_excel("data/raw/ingreso_presupuestario.xlsx")
saldo <- read_excel("data/raw/saldo_rquerimientos_financieros.xlsx")

# Extrar los datos necesarios



