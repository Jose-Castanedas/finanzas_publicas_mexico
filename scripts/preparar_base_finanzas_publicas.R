# Cargar librerías

library(tidyverse)
library(readxl)

# Cargar archivos de datos

gasto <- read_excel("data/raw/gasto_neto_presupuestario.xlsx", skip = 2, na = "n.d.")
ingreso <- read_excel("data/raw/ingreso_presupuestario.xlsx", skip = 2, na = "n.d.")
saldo <- read_excel("data/raw/saldo_rquerimientos_financieros.xlsx", skip = 2, na = "n.d.")

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

nombres_gasto <- c(
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
  filter(nombre_fila %in% names(nombres_gasto)) %>%
  mutate(nombre_fila = recode(nombre_fila, !!!nombres_gasto))

# 4. Usar pivot_wider() para pasar de filas a columnas

df_gasto <- gasto_largo %>%
  pivot_wider(
    names_from = nombre_fila,
    values_from = valor
  )

# Parte 2. Ingreso Presupuestario

# 1. Limpiar de los registros de las filas

ingreso <- ingreso %>%
  rename(nombre_fila = 1) %>%
  mutate(nombre_fila = str_squish(nombre_fila),
         nombre_fila = str_remove(nombre_fila, "\\s*\\d+_/"))

# 1.1. Distinguir los nombres repetidos en los datos

ingreso <- ingreso %>%
  mutate(nombre_fila = make.unique(nombre_fila))

# 2. Usar pivot_longer() para tener un DataFrame con años y valores de cada registro en columnas

ingreso_largo <- ingreso %>%
  pivot_longer(
    cols = -nombre_fila,
    names_to = "año",
    values_to = "valor",
    names_transform = \(x) as.integer(str_squish(x))
  )

# 3. Filtrar y renombrar únicamente los datos que se necesitan

# 3.1. Crear vector con los datos a buscar y su nuevo nombre

nombres_ingreso <- c(
  "Total" = "ingreso_total",
  "Petroleros" = "petroleros",
  "No petroleros" = "no_petroleros",
  "Tributarios" = "tributarios",
  "No tributarios" = "no_tributarios",
  "Impuesto sobre la renta" = "isr",
  "Impuesto al valor agregado" = "iva",
  "Impuesto especial sobre producción y servicios" = "ieps",
  "IEPS gasolinas y diesel" = "ieps_gasolinas",
  "IEPS distinto de gasolinas y diesel" = "ieps_distinto"
)

# 3.2. Filtrar y renombrar

ingreso_largo <- ingreso_largo %>%
  filter(nombre_fila %in% names(nombres_ingreso)) %>%
  mutate(nombre_fila = recode(nombre_fila, !!!nombres_ingreso))

# 4. Usar pivot_wider() para pasar de filas a columnas

df_ingreso <- ingreso_largo %>%
  pivot_wider(
    names_from = nombre_fila,
    values_from = valor
  )

# Parte 3. Saldo Hitórico de los RFSP

# 1. Limpiar el nombre de los registros de las filas

saldo <- saldo %>%
  rename(nombre_fila = 1) %>%
  mutate(nombre_fila = str_squish(nombre_fila))

# 1.1. Distinguir los nombres repetidos en los datos

saldo <- saldo %>%
  mutate(nombre_fila = make.unique(nombre_fila))

# 2. Usar pivot_longer() para tener un DataFrame con años y valores de cada registro en columnas

saldo_largo <- saldo %>%
  pivot_longer(
    cols = -nombre_fila,
    names_to = "año",
    values_to = "valor",
    names_transform = \(x) as.integer(str_squish(x))
  )

# 3. Filtrar y renombrar únicamente los datos que se necesitan

# 3.1. Crear vector con los datos a buscar y su nuevo nombre

nombres_saldo <- c(
  "Saldo histórico de los RFSP" = "saldo_historico",
  "Interno" = "interno",
  "Externos" = "externo"
)

# 3.2. Filtrar y renombrar

saldo_largo <- saldo_largo %>%
  filter(nombre_fila %in% names(nombres_saldo)) %>%
  mutate(nombre_fila = recode(nombre_fila, !!!nombres_saldo))

# 4. Usar pivot_wider() para pasar de filas a columnas

df_saldo <- saldo_largo %>%
  pivot_wider(
    names_from = nombre_fila,
    values_from = valor
  )

# Parte 4. Unir los 3 DataFrames en uno solo

df_finanzas <- df_gasto %>%
  left_join(df_ingreso, by="año") %>%
  left_join(df_saldo, by="año")
