

deploy-and-run profile wh-id:
    databricks bundle deploy --profile {{profile}} --var "sql_warehouse_id={{wh-id}}"
    databricks bundle run shiny-app-r --profile {{profile}} --var "sql_warehouse_id={{wh-id}}"

logs profile:
    databricks apps logs shiny-app-r --profile {{profile}}