# Databricks Apps with Shiny in R 

This project shows an example of how to build a Shiny app in R that runs on Databricks Apps.

## R Code

Just a sample shiny app that shows a simple dashboard with a bar chart and a table.

## Launch pattern 

Databricks Apps provide access to `uv` on the running container. Therefore, we need a small script which practically does the following:

1. Installs the R runtime and the required packages
2. Runs the Shiny app (and passess all OS environment variables to the app)


Script command  call be like this:

```
uv run scripts/launcher.py
```

## Deployment pattern

Use [DABs](https://docs.databricks.com/aws/en/dev-tools/bundles/). Keep all deployment details in `databricks.yml`. 