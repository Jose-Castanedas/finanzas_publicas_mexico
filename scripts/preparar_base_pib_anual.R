# Cargar librerías

library(tidyverse)

# Verificar la codificación de cada archivo csv

guess_encoding("data/raw/pib_precios_2018.csv")
guess_encoding("data/raw/pib_precios_corrientes.csv")


# Cargar archivos de datos

pib_2018 <- read_csv("data/raw/pib_precios_2018.csv", locale = locale(encoding = "UTF-16LE"))
pib_corriente <- read_csv("data/raw/pib_precios_corrientes.csv", locale = locale(encoding = "UTF-16LE"))

# Parte 1. Limpiar datos y renombrar columnas

# 1.1. PIB 2018

pib_2018 <- pib_2018 %>%
  rename(pib = 3) %>%
  mutate(Periodos = str_squish(Periodos),
         Periodos = str_remove(Periodos, "\\s*r\\d+$"))

# 1.2. PIB corriente

pib_corriente <- pib_corriente %>%
  rename(pib = 3) %>%
  mutate(Periodos = str_squish(Periodos),
         Periodos = str_remove(Periodos, "\\s*r\\d+$"))

