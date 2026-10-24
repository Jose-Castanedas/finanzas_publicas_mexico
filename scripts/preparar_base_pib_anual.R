# Cargar librerías

library(tidyverse)

# Verificar la codificación de cada archivo csv

guess_encoding("data/raw/pib_precios_2018.csv")
guess_encoding("data/raw/pib_precios_corrientes.csv")


# Cargar archivos de datos

pib_2018 <- read_csv("data/raw/pib_precios_2018.csv", locale = locale(encoding = "UTF-16LE"))
pib_corriente <- read_csv("data/raw/pib_precios_corrientes.csv", locale = locale(encoding = "UTF-16LE"))

# Limpiar columna de Periodos en ambos DataFrames

pib_2018 <- pib_2018 %>%
  mutate(Periodos = str_squish(Periodos),
         Periodos = str_remove(Periodos, "\\s*r\\d+$"))

pib_corriente <- pib_corriente %>%
  mutate(Periodos = str_squish(Periodos),
         Periodos = str_remove(Periodos, "\\s*r\\d+$"))

