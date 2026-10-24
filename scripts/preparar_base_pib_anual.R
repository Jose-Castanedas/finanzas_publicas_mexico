# Cargar librerías

library(tidyverse)

# Verificar la codificación de cada archivo csv

guess_encoding("data/raw/pib_precios_2018.csv")
guess_encoding("data/raw/pib_precios_corrientes.csv")


# Cargar archivos de datos
# Se fuerza UTF-16LE porque es la codificación real de los archivos

pib_2018 <- read_csv("data/raw/pib_precios_2018.csv", locale = locale(encoding = "UTF-16LE"))
pib_corriente <- read_csv("data/raw/pib_precios_corrientes.csv", locale = locale(encoding = "UTF-16LE"))

# Parte 1. Limpiar datos y renombrar columnas

# 1.1. PIB 2018
# Se renombra por posición (3) porque los nombres originales no son estables; el regex quita el sufijo " r1"

pib_2018 <- pib_2018 %>%
  rename(pib = 3) %>%
  mutate(Periodos = str_squish(Periodos),
         Periodos = str_remove(Periodos, "\\s*r\\d+$"))

# 1.2. PIB corriente

pib_corriente <- pib_corriente %>%
  rename(pib = 3) %>%
  mutate(Periodos = str_squish(Periodos),
         Periodos = str_remove(Periodos, "\\s*r\\d+$"))

# Parte 2. Extraer los años de cada DataFrame
# Cada DataFrame del PIB tiene una periodicidad diferente

# 2.1. Extraer únicamente el año y agregarlo en una columna llamada anio
# Los rangos de filter limitan cada serie a únicamente a los años a usar

pib_2018 <- pib_2018 %>%
  mutate(anio = as.integer(str_sub(Periodos, 1, 4))) %>%
  filter(between(anio, 1980, 2025))

pib_corriente <- pib_corriente %>%
  mutate(anio = as.integer(str_sub(Periodos, 1, 4))) %>%
  filter(between(anio, 1993, 2025))

# Parte 3. Tranformar PIB trimestral a anual mediante el promedio de los trimestres

pib_anual_2018 <- pib_2018 %>%
  group_by(anio) %>%
  summarise(pib = mean(pib, na.rm = TRUE))

pib_corriente_anual <- pib_corriente %>%
  group_by(anio) %>%
  summarise(pib = mean(pib, na.rm = TRUE))

# Parte 4. Unir ambos DataFrames
# left_join conserva la cobertura de años de pib_anual_2018

# 4.1. Renombrar columnas en ambos DataFrames

pib_anual_2018 <- pib_anual_2018 %>%
  rename(pib_real = 2)

pib_corriente_anual <- pib_corriente_anual %>%
  rename(pib_nominal = 2)

# 4.2. Unir ambos DataFrames en uno

pib_anual <- pib_anual_2018 %>%
  left_join(pib_corriente_anual, by = "anio")

# Parte 5. Exportar pib_anual a un archivo csv

# 5.1. Especificar ruta y nombre de archivo

ruta <- file.path("data/processed/", "pib_real_nominal_anual.csv")

# 5.2. Exportar DataFrame a csv

write.csv(pib_anual, ruta, row.names = FALSE)
