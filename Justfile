

deploy-and-run profile:
    databricks bundle deploy --profile {{profile}}
    databricks bundle run shiny-app-r --profile {{profile}}

logs profile:
    databricks apps logs shiny-app-r --profile {{profile}}