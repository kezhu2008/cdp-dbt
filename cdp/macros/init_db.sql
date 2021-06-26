{%macro init_db() %}

{% set dbs = ["cdp_prod", "cdp_test", "cdp_dev"] %}
{% set users = ["dbt_prod", "dbt_test", "dbt_dev"] %}
{% set schemas = ["public.checkpoint_dbo", "public.chess_dbo", "public.ccm_dbo"] %}




{% for user in users %}
{% set sql = 'DROP USER IF EXISTS ' ~ user ~ ';' %}
{% do run_query(sql) %}
{% set sql = 'CREATE USER ' ~ user ~ ' WITH PASSWORD DISABLE;' %}
{% do run_query(sql) %}
{% endfor %}

{% for db in dbs %}
{% set ns.sql = ns.sql ~ 'CREATE DATABASE ' ~ db ~ ' WITH OWNER = ' ~ users[loop.index - 1] ~ ';\n' %}
{% endfor %}

{% do log(ns.sql, info=True) %}

{% endmacro %}