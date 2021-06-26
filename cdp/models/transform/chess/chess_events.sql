SELECT 
    e.eventdate as EventDate,
    e.datereported as ReportDate,
    e.duedate as DueDate,
    e.reviewdate as ReviewDate,
    e.revieweddate as ReviewedDate,
    e.verificationdate as VerificationDate,
    e.originalduedate as OriginalDueDate,
    e.closedoutdate as ClosedOutDate,
    /* e.potentialconsequenceid */
    /* e.initialpotentialconsequenceid */
    /* e.revisedpotentialconsequenceid */
    /* e.initialconsequenceid */
    /* e.consequenceid */
    /* e.revisedconsequenceid */
    /* e.likelihoodid  */
    /* e.classvalueid  */
    /* e.reclassvalueid  */
    /* e.statusreasonid  */
    
    /* e.revisedlikelihoodid  */
    /* e.initiallikelihoodid  */
    /* e.initialriskassessmentid */
    /* e.riskassessmentid  */
    /* e.revisedriskassessmentid */
    /* e.checklistguid */
    /* scheduledeventid */
    /* statuscode */
    e.sitevessel,
    /* siteid */
    ep.EventID as EventID, 
    ep.ParticipantTypeCODE as ParticipantCode, 
    ep.ParticipantTypeID as ParticipantID,
    et.Name as EventTypeName,
    et.Description as EventDescription,
    est.Name as EventSubTypeName,
    et.CanSchedule as CanSchedule,
    et.IsIncident as IsIncident,
    et.IncludeRiskRank as IncludeRiskRank,
    etc.Name as EventCategoryName,
    etc.Description as EventCategoryDescription,
    etc.Sequence as EventCategorySequence

    
FROM {{ source('chess', 'event') }} e
    LEFT OUTER JOIN {{ source('chess', 'event_participant')}} ep on e.id = ep.eventid
    LEFT OUTER JOIN {{ source('chess', 'event_subtype')}} est on e.eventsubtypeid = est.id
    LEFT OUTER JOIN {{ source('chess', 'event_type')}} et on est.eventtypeid = et.id
    LEFT OUTER JOIN {{ source('chess', 'event_type_category')}} etc on et.eventtypecategoryid = etc.id
    /* LEFT OUTER JOIN {{ source('chess', 'exposure')}} ex on e.exposureid = ex.id */
