WITH basic_fact as (SELECT
    ce.id as event_id_pk,
    ce.createdon as created_on,
    TO_CHAR(ce.createdon, 'DD-MM-YYYY') as created_on_date,
    split_part(cv."name",':',1) as cost_centre
FROM {{ source('chess', 'event') }} ce
LEFT JOIN {{ source('chess', 'class_values') }} cv
ON ce.classvalueid = cv.id )

SELECT  
event_id_pk,
created_on,
created_on_date,
cost_centre,
{{ dbt_utils.surrogate_key(['cost_centre']) }} as cc_surrogate_key
FROM basic_fact
