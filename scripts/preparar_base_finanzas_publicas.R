# Cargar librerías

library(tidyverse)
library(readxl)

# Cargar archivos de datos

gasto <- read_excel("data/raw/gasto_neto_presupuestario.xlsx", skip = 2, na = "n.d.")
ingreso <- read_excel("data/raw/ingreso_presupuestario.xlsx", na = "n.d.")
saldo <- read_excel("data/raw/saldo_rquerimientos_financieros.xlsx", na = "n.d.")

# Parte 1. Gasto programable

# 1. Función para convertir fila en un vector númerico

fila_a_vector <- function(fila) {
  as.numeric(unlist(gasto[fila, -1]))
}

# 2. Crear vector de años

años <- 1990:2025

# 3. Unir en un DataFrame

df_gasto <- data.frame(
  año = años,
  gasto_total = fila_a_vector(1),
  programable = fila_a_vector(2),
  no_programable = fila_a_vector(19),
  corriente = fila_a_vector(3),
  capital = fila_a_vector(12),
  inversion_fisica = fila_a_vector(13),
  gasto_pensiones = fila_a_vector(26)
)
