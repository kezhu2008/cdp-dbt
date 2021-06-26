# cdp-dbt

## Setup

### Windows

The following script is required

```
set RS_HOST_NAME=<cdp-dev-ingestion-cluster.cid05enmie3a.ap-southeast-2.redshift.amazonaws.com or localhost>
set RS_PORT=<port>
set RS_DB_NAME=<cdp_dev | cdp_test | cdp_prod>
set RS_CLUSTER_ID=cdp-dev-ingestion-cluster
set RS_DBT_USER=<dbt_dev | dbt_test | dbt_prod>
set DBT_USER_NAME=kz
set AWS_PROFILE=<aws profile with permission to GetCredential>
```
