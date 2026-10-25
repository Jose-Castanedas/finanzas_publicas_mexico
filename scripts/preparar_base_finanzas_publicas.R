# Preparar base de finanzas públicas

# Cargar librerías

library(tidyverse)
library(readxl)

# Cargar archivos de datos
# skip = 2 omite los encabezados de las hojas; "n.d." se trata como NA

gasto <- read_excel("data/raw/gasto_neto_presupuestario.xlsx", skip = 2, na = "n.d.")
ingreso <- read_excel("data/raw/ingreso_presupuestario.xlsx", skip = 2, na = "n.d.")
saldo <- read_excel("data/raw/saldo_rquerimientos_financieros.xlsx", skip = 2, na = "n.d.")

# Parte 1. Gasto Neto Presupuestario

# 1. Limpiar el nombre de los registros de las filas
# El regex quita el sufijo numérico tipo "1_/" que traen los nombres

gasto <- gasto %>%
  rename(nombre_fila = 1) %>%
  mutate(nombre_fila = str_squish(nombre_fila), 
         nombre_fila = str_remove(nombre_fila, "\\s*\\d+_/"))

# 1.1. Distinguir los nombres repetidos (make.unique añade .1, .2, ...)

gasto <- gasto %>%
  mutate(nombre_fila = make.unique(nombre_fila))

# 2. Pasar de formato ancho a largo: un año por fila

gasto_largo <- gasto %>%
  pivot_longer(
    cols = -nombre_fila,
    names_to = "año",
    values_to = "valor",
    names_transform = \(x) as.integer(str_squish(x))
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
  "Directo" = "inversion_directa",
  "Indirecto" = "inversion_indirecta",
  "Gasto de pensiones" = "gasto_pensiones"
)

# 3.2. Filtrar y renombrar usando el mapeo anterior

gasto_largo <- gasto_largo %>%
  filter(nombre_fila %in% names(nombres_gasto)) %>%
  mutate(nombre_fila = recode(nombre_fila, !!!nombres_gasto))

# 4. Volver a formato ancho: una columna por indicador

df_gasto <- gasto_largo %>%
  pivot_wider(
    names_from = nombre_fila,
    values_from = valor
  )

# Parte 2. Ingreso Presupuestario

# 1. Limpiar el nombre de los registros de las filas

ingreso <- ingreso %>%
  rename(nombre_fila = 1) %>%
  mutate(nombre_fila = str_squish(nombre_fila),
         nombre_fila = str_remove(nombre_fila, "\\s*\\d+_/"))

# 1.1. Distinguir los nombres repetidos (make.unique añade .1, .2, ...)

ingreso <- ingreso %>%
  mutate(nombre_fila = make.unique(nombre_fila))

# 2. Pasar de formato ancho a largo: un año por fila

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
  "Tributarios" = "tributarios_gf",
  "No tributarios" = "no_tributarios_gf",
  "Impuesto sobre la renta" = "isr",
  "Impuesto al valor agregado" = "iva",
  "Impuesto especial sobre producción y servicios" = "ieps",
  "IEPS gasolinas y diesel" = "ieps_gasolinas",
  "IEPS distinto de gasolinas y diesel" = "ieps_distinto"
)

# 3.2. Filtrar y renombrar usando el mapeo anterior

ingreso_largo <- ingreso_largo %>%
  filter(nombre_fila %in% names(nombres_ingreso)) %>%
  mutate(nombre_fila = recode(nombre_fila, !!!nombres_ingreso))

# 4. Volver a formato ancho: una columna por indicador

df_ingreso <- ingreso_largo %>%
  pivot_wider(
    names_from = nombre_fila,
    values_from = valor
  )

# Parte 3. Saldo Histórico de los RFSP

# 1. Limpiar el nombre de los registros de las filas

saldo <- saldo %>%
  rename(nombre_fila = 1) %>%
  mutate(nombre_fila = str_squish(nombre_fila))

# 1.1. Distinguir los nombres repetidos (make.unique añade .1, .2, ...)

saldo <- saldo %>%
  mutate(nombre_fila = make.unique(nombre_fila))

# 2. Pasar de formato ancho a largo: un año por fila

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
  "Saldo histórico de los RFSP" = "shrfsp",
  "Interno" = "shrfsp_interno",
  "Externos" = "shrfsp_externo"
)

# 3.2. Filtrar y renombrar usando el mapeo anterior

saldo_largo <- saldo_largo %>%
  filter(nombre_fila %in% names(nombres_saldo)) %>%
  mutate(nombre_fila = recode(nombre_fila, !!!nombres_saldo))

# 4. Volver a formato ancho: una columna por indicador

df_saldo <- saldo_largo %>%
  pivot_wider(
    names_from = nombre_fila,
    values_from = valor
  )

# Parte 4. Unir los 3 DataFrames en uno solo
# left_join conserva la cobertura de años de df_gasto

df_finanzas <- df_gasto %>%
  left_join(df_ingreso, by="año") %>%
  left_join(df_saldo, by="año")

# Parte 5. Exportar df_finanzas a un archivo csv

# 5.1. Especificar ruta y nombre de archivo

ruta <- file.path("data/processed", "base_finanzas_publicas.csv")

# 5.2. Renombrar la columna "año" a "anio" (se renombra por posición 1)

df_finanzas <- df_finanzas %>%
  rename(anio = 1)

# 5.3. Exportar DataFrame a csv

write.csv(df_finanzas, ruta, row.names = FALSE)
