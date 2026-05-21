Este repositorio contiene el pipeline de transformación de datos (Data Engineering) construido con dbt (Data Build Tool) y Snowflake. El objetivo principal es preparar y modelar datos transaccionales bancarios para alimentar un Modelo Predictivo de Riesgo Crediticio y dashboards de inteligencia de negocio en Power BI.

# Arquitectura de Datos
El modelado sigue las mejores prácticas de Kimball y se divide en tres capas conceptuales:

•	Bronze (Raw): Ingesta de datos crudos desde Snowflake. Definición de sources.

•	Silver (Staging): Casteo de tipos, limpieza de nulos, estandarización de nombres (inglés) y normalización.

•	Gold (Marts): Modelado dimensional (Esquema de Estrella). Incluye tablas de hechos transaccionales (fct_loan) y de snapshot periódico para evitar el Data Leakage en los modelos de Machine Learning.

# Prerrequisitos y Configuración
1.	Tener acceso a un Warehouse en Snowflake.
2.	Instalar dbt-core y el conector de Snowflake: pip install dbt-snowflake
3.	Copiar el archivo profiles_template.yml en el directorio ~/.dbt/profiles.yml y rellenar con las credenciales (entornos DEV y PROD soportados).

# Cómo ejecutar el proyecto

1. Instalar dependencias (dbt-utils)
   
dbt deps

2. Cargar las semillas (diccionarios de datos estáticos)
   
dbt seed

3. Ejecutar los modelos (con captura de snapshots para SCD Tipo 2)
   
dbt snapshot
dbt run

4. Ejecutar la batería de tests (Genéricos y Singulares)
   
dbt test

Linaje de Datos y Gobernanza
Para visualizar el DAG (Directed Acyclic Graph) y consultar el diccionario de datos documentado:
dbt docs generate
dbt docs serve
