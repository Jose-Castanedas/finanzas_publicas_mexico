# Cargar librerías

library(tidyverse)
library(readxl)

# Cargar archivos de datos

gasto <- read_excel("data/raw/gasto_neto_presupuestario.xlsx", skip = 2, na = "n.d.")
ingreso <- read_excel("data/raw/ingreso_presupuestario.xlsx", skip = 2, na = "n.d.")
saldo <- read_excel("data/raw/saldo_rquerimientos_financieros.xlsx", na = "n.d.")

# Parte 1. Gasto Neto Presupuestario

# 1. Función para convertir fila en un vector númerico

g_fila_a_vector <- function(fila) {
  as.numeric(unlist(gasto[fila, -1]))
}

# 2. Crear vector de años

años <- 1990:2025

# 3. Unir en un DataFrame

df_gasto <- data.frame(
  año = años,
  gasto_total = g_fila_a_vector(1),
  programable = g_fila_a_vector(2),
  no_programable = g_fila_a_vector(19),
  corriente = g_fila_a_vector(3),
  capital = g_fila_a_vector(12),
  inversion_fisica = g_fila_a_vector(13),
  gasto_pensiones = g_fila_a_vector(26)
)

# Parte 2. Ingreso Presupuestario

# 1. Función para convertir fila en un vector númerico
