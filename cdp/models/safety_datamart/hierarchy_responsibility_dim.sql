SELECT 
    cost_centre, 
    {{ dbt_utils.surrogate_key(['cost_centre']) }} as responsibility_hierarchy_key,
    executive_director, 
    gm, 
    nm, 
    am
FROM {{ ref('ccm_hierarchy') }}