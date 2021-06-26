

CREATE EXTERNAL SCHEMA IF NOT EXISTS ingester_ccm_dbo FROM REDSHIFT DATABASE 'public' SCHEMA 'ccm_dbo';
CREATE EXTERNAL SCHEMA IF NOT EXISTS ingester_checkpoint_dbo FROM REDSHIFT DATABASE 'public' SCHEMA 'checkpoint_dbo';
CREATE EXTERNAL SCHEMA IF NOT EXISTS ingester_chess_dbo FROM REDSHIFT DATABASE 'public' SCHEMA 'chess_dbo';

grant all PRIVILEGES on schema ingester_ccm_dbo to dbt_dev;
grant all PRIVILEGES on schema ingester_checkpoint_dbo to dbt_dev;
grant all PRIVILEGES on schema ingester_chess_dbo to dbt_dev;