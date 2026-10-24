# Cargar librerías

library(tidyverse)

# Verificar la codificación de cada archivo csv

guess_encoding("data/raw/pib_precios_2018.csv")
guess_encoding("data/raw/pib_precios_corrientes.csv")


# Cargar archivos de datos

pib_2018 <- read_csv("data/raw/pib_precios_2018.csv", locale = locale(encoding = "UTF-16LE"))
pib_corriente <- read_csv("data/raw/pib_precios_corrientes.csv", locale = locale(encoding = "UTF-16LE"))
