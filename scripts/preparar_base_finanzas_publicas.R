# Cargar librerías

library(tidyverse)
library(readxl)

# Cargar archivos de datos

gasto <- read_excel("data/raw/gasto_neto_presupuestario.xlsx", skip = 2, na = "n.d.")
ingreso <- read_excel("data/raw/ingreso_presupuestario.xlsx", skip = 2, na = "n.d.")
saldo <- read_excel("data/raw/saldo_rquerimientos_financieros.xlsx", na = "n.d.")

# Parte 1. Gasto Neto Presupuestario

# 1. Limpiar el nombre de los registros de las filas

gasto <- gasto %>%
  rename(nombre_fila = 1) %>%
  mutate(nombre_fila = str_squish(nombre_fila), 
         nombre_fila = str_remove(nombre_fila, "\\s*\\d+_/"))


# 2. Usar pivot_longer() para tener un DataFrame con años y valores de cada registro en columnas

gasto_largo <- gasto %>%
  pivot_longer(
    cols = -nombre_fila,
    names_to = "año",
    values_to = "valor"
  )

# 3. Filtrar y renombrar únicamente los datos que se necesitan

# 3.1. Crear vector con los datos a buscar y su nuevo nombre

nuevos_nombres <- c(
  "Total"            = "gasto_total",
  "Programable"      = "programable",
  "No programable"   = "no_programable",
  "Corriente"        = "corriente",
  "Capital"          = "capital",
  "Inversión física" = "inversion_fisica",
  "Gasto de pensiones" = "gasto_pensiones"
)

# 3.2. Filtrar y renombrar

gasto_largo <- gasto_largo %>%
  filter(nombre_fila %in% names(nuevos_nombres)) %>%
  mutate(nombre_fila = recode(nombre_fila, !!!nuevos_nombres))

# 4. Usar pivot_wider() para pasar de filas a columnas

df_gasto <- gasto_largo %>%
  pivot_wider(
    names_from = nombre_fila,
    values_from = valor
  )

