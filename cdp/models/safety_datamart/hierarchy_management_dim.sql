SELECT 
    cost_centre,
    {{ dbt_utils.surrogate_key(['cost_centre']) }} as management_hierarchy_key,
    "region (map)" as region_map, 
    "map sector" as map_sector, 
    "Sub-sector" as management_sub_sector
FROM {{ ref('ccm_hierarchy') }}