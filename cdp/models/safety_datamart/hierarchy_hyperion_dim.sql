SELECT 
    cost_centre,
    {{ dbt_utils.surrogate_key(['cost_centre']) }} as hyperion_hierarchy_key,
    "management #1" as region_hyperion, 
    Hyperion as hyperion_sector, 
    BusinessSubSector as hyperion_sub_sector
FROM {{ ref('ccm_hierarchy') }}