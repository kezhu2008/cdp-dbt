-- old management hierarchy
WITH RECURSIVE comaum_cte(
      CID,
      CNODE,
      c_descr,
      B_INACTIVE,
      D_CHANGED_ON,
      LVL,
      Path
) AS (
      (
            SELECT CHLD.I_NODE_ID CID,
                  CHLD.C_ABBREV CNODE,
                  CHLD.c_descr,
                  CHLD.B_INACTIVE,
                  CHLD.D_CHANGED_ON,
                  1 AS LVL,
                  CAST('' AS varchar(max)) AS Path
            FROM {{ source('ccm', 'node') }} CHLD
                  LEFT OUTER JOIN {{ source('ccm', 'relationship') }} REL ON CHLD.I_NODE_ID = REL.I_NODE_ID_C
            WHERE CHLD.C_ABBREV = 'COMAUM'
            UNION ALL
            SELECT PRNT.I_NODE_ID_C CID,
                  PRT.C_ABBREV,
                  PRT.c_descr,
                  PRT.B_INACTIVE,
                  PRT.D_CHANGED_ON,
                  comaum.LVL + 1 LVL,
                  CAST(
                        ISNULL(comaum.Path, '') + comaum.CNODE + '/' AS varchar(max)
                  )
            FROM comaum_cte comaum
                  INNER JOIN {{ source('ccm', 'relationship') }} PRNT ON comaum.CID = PRNT.I_NODE_ID_P
                  INNER JOIN {{ source('ccm', 'node') }} PRT ON PRNT.I_NODE_ID_C = PRT.I_NODE_ID
      )
),

-- client hierarchy
client_cte(
      CID,
      CNODE,
      c_descr,
      B_INACTIVE,
      D_CHANGED_ON,
      LVL,
      Path
) AS (
      (
            SELECT CHLD.I_NODE_ID CID,
                  CHLD.C_ABBREV CNODE,
                  CHLD.c_descr,
                  CHLD.B_INACTIVE,
                  CHLD.D_CHANGED_ON,
                  1 AS LVL,
                  CAST('' AS varchar(max)) AS Path
            FROM {{ source('ccm', 'node') }} CHLD
                  LEFT OUTER JOIN {{ source('ccm', 'relationship') }} REL ON CHLD.I_NODE_ID = REL.I_NODE_ID_C
            WHERE CHLD.C_ABBREV = 'CLIENT'
            UNION ALL
            SELECT PRNT.I_NODE_ID_C CID,
                  PRT.C_ABBREV,
                  PRT.c_descr,
                  PRT.B_INACTIVE,
                  PRT.D_CHANGED_ON,
                  client.LVL + 1 LVL,
                  CAST(
                        ISNULL(client.Path, '') + client.CNODE + '/' AS varchar(max)
                  )
            FROM client_cte client
                  INNER JOIN {{ source('ccm', 'relationship') }} PRNT ON client.CID = PRNT.I_NODE_ID_P
                  INNER JOIN {{ source('ccm', 'node') }} PRT ON PRNT.I_NODE_ID_C = PRT.I_NODE_ID
      )
),

INNER_HIERARCHY_COMPASS_CTE(PID, CID, LVL) AS (
      SELECT REL.I_NODE_ID_P PID,
            CHLD.I_NODE_ID CID,
            1 AS LVL
      FROM {{ source('ccm', 'node') }} CHLD
            LEFT OUTER JOIN {{ source('ccm', 'relationship') }} REL ON CHLD.I_NODE_ID = REL.I_NODE_ID_C
      WHERE CHLD.C_ABBREV = 'COMPASS'
      UNION ALL
      SELECT PRNT.I_NODE_ID_P PID,
            PRNT.I_NODE_ID_C CID,
            TMP.LVL + 1 LVL
      FROM INNER_HIERARCHY_COMPASS_CTE TMP
            INNER JOIN {{ source('ccm', 'relationship') }} PRNT ON TMP.CID = PRNT.I_NODE_ID_P
),

HIERARCHY_COMPASS_CTE(CID, CNODE, PID, PNODE, LVL) AS (
      SELECT CLD.I_NODE_ID CID,
            CLD.C_ABBREV CNODE,
            PRT.I_NODE_ID PID,
            PRT.C_ABBREV PNODE,
            TP.LVL
      FROM INNER_HIERARCHY_COMPASS_CTE TP
            INNER JOIN {{ source('ccm', 'node') }} CLD ON TP.CID = CLD.I_NODE_ID
            LEFT OUTER JOIN {{ source('ccm', 'node') }} PRT ON TP.PID = PRT.I_NODE_ID
)

select distinct coc.CNODE AS "Cost_Centre",
      (CCD.[Cost_centre] + ':' + CCD.[Contract_Name]) AS "Essatto Name",
      CCD.[Contract_Name] AS "Contract_Name",
      CCD.[Business_Sector] AS [Hyperion],
      CCD.[MAPSector] as "MAP Sector",
      -- CLD.[PARENT_COMPANY] AS "Client Hierarchy",
      -- (
      --       select c_descr
      --       from {{ source('ccm', 'node') }}
      --       where c_abbrev = client.L2
      -- ) as "Client Hierarchy1",
      CCD.ReportingContract AS "Reporting Contract", --?? 
      CCD.[RegionHyperion] as "Management #1",
      -- ISNULL(CCS.CONTRACT_TYPE, '') AS "Contract Type",
      -- ISNULL(OPS.OPERATION_CLASS, '') AS "Private / Public",
      CCD.[SERVICES_DESC] AS [Services],
      -- CASE
      --       WHEN CCD.STATE IS NULL THEN CASE
      --             WHEN DBO.FN_STATE(HR.CNODE, 'COMAUM') = '' THEN DBO.FN_STATE(HR.CNODE, 'COMNZM')
      --             ELSE DBO.FN_STATE(HR.CNODE, 'COMAUM')
      --       END
      --       ELSE CCD.STATE
      -- END AS [State],
      CCD.[COMMODITY] AS [Commodity],
      CCD.[SITE_POPULATION] AS "Site Population",
      CMR.[GENERAL_REGIONAL_MGR] AS [GM],
      ISNULL(CMR.OPERATIONS_MGR, '') AS [NM],
      CMR.[AREA_MGR] AS [AM],
      CCD.[Cost_Centre_Type] AS "CC Type",
      CCD.[RegionMAP] AS "Region (MAP)",
      ISNULL(
            ISNULL(CCD.BUSINESS_SECTOR_DRM, CCD.BUSINESS_SECTOR),
            ''
      ) AS BusinessSector,
      CCD.Business_Sector_Desc,
      ISNULL(CCD.BUSINESS_SUB_SECTOR, '') AS BusinessSubSector,
      CCD.MgmtSubSector AS "Sub-Sector",
      CCD.Purchasing_BusinessSector,
      -- dbo.FN_COMPASS_DESCR(HR.CNODE) AS UnitName,
      CCD.[CONTRACT_ENTITY] AS "Employing Entity",
      ISNULL(CCD.COMPANY_CODE, '') AS [Company],
      ISNULL(CCD.DEPARTMENT, '') AS Department,
      ISNULL(CCD.CLASSIFICATION, '') AS Classification,
      ISNULL(TO_CHAR(CCD.COMMENCEMENT_DATE, 'DD-MM-YYYY'), '') AS CommencementDate,
      -- ISNULL(TO_CHAR(CCS.END_DATE, 'DD-MM-YYYY'), '') AS ExpiryDate,
      -- ISNULL(TO_CHAR(CCL.COST_CENTRE_END_DATE, 'DD-MM-YYYY'),'') AS EndDate,
      ISNULL(CCD.CONTRACT_LENGTH, '') AS ContractLength,
      ISNULL(CCD.Cost_Centre_Type, '') AS CostCentreType,
      ISNULL(CCD.STATUS_OPEN_CLOSED, 'OPEN') AS Status,
      ISNULL (CMR.AREA_MGR, '') AS AREA_MGR,
      ISNULL(CMR.COMMERCIAL_MGR, '') AS COMMERCIAL_MGR,
      ISNULL(CMR.EXECUTIVE_DIRECTOR, '') AS EXECUTIVE_DIRECTOR,
      ISNULL(CMR.GENERAL_REGIONAL_MGR, '') AS GENERAL_REGIONAL_MGR,
      ISNULL(CMR.UNIT_MGR, '') AS UNIT_MGR
      -- isnull (
      --       (
      --             CASE
      --                   WHEN CCD.STATE IS NULL THEN CASE
      --                         WHEN DBO.FN_STATE(HR.CNODE, 'COMAUM') = '' THEN (
      --                               select st.Parent_Master_Value
      --                               from {{ source('ccm', 'commonmaster_mst') }} st 
      --                               where st.Master_Name = 'State'
      --                                     and st.Master_value = DBO.FN_STATE(HR.CNODE, 'COMNZM')
      --                         )
      --                         ELSE (
      --                               select st.Parent_Master_Value
      --                               from {{ source('ccm', 'commonmaster_mst') }} st
      --                               where st.Master_Name = 'State'
      --                                     and st.Master_value = DBO.FN_STATE(HR.CNODE, 'COMAUM')
      --                         )
      --                   END
      --                   ELSE (
      --                         select st.Parent_Master_Value
      --                         from {{ source('ccm', 'commonmaster_mst') }} st
      --                         where st.Master_Name = 'State'
      --                               and st.Master_value = CCD.STATE
      --                   )
      --             END
      --       ),
      --       CCD.STATE
      -- ) AS COUNTRY
from HIERARCHY_COMPASS_CTE HR
      LEFT OUTER JOIN comaum_cte coc ON coc.CID = HR.CID
      -- LEFT OUTER JOIN client_cte clc ON coc.CID = clc.CID
      LEFT OUTER JOIN {{ source('ccm', 'cost_centre_dtl') }} CCD ON coc.CID = CCD.I_NODE_ID
      -- Left JOIN {{ source('ccm', 'client_dtl') }} CLD ON CCD.I_NODE_ID = CLD.I_NODE_ID
      -- Left JOIN {{ source('ccm', 'contract_summary') }} CCS ON CCD.I_NODE_ID = CCS.I_NODE_ID
      -- Left JOIN {{ source('ccm', 'client_operational_setup') }} OPS ON CCD.I_NODE_ID = OPS.I_NODE_ID
      Left JOIN {{ source('ccm', 'mgmt_responsibility') }} CMR ON CCD.I_NODE_ID = CMR.I_NODE_ID 
      --   LEFT OUTER JOIN  dbo.CCM_CLOSURE_DTL AS CCL ON CCD.I_NODE_ID = CCL.I_NODE_ID 
      --   CROSS APPLY DBO.CCM_FN_Split_STR_IN_COLUMNS(coc.PATH,'/') comaum
      --   CROSS APPLY DBO.CCM_FN_Split_STR_IN_COLUMNS(clc.PATH,'/') client
      WHERE (coc.CNODE ~ '^[0-9]+$') AND LEN(coc.CNODE)=6  

