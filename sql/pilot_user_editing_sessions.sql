SELECT
  user_id,
  event_editingSessionId AS session_id,
  event_editor AS editor,
  MAX(`event_page.revid`) AS rev_id,
  MIN(IF(event_action IN ('init', 'ready'), timestamp, NULL)) AS session_started,
  MAX(timestamp) AS session_ended,
  MIN(IF(event_action = 'ready', timestamp, NULL)) AS editor_ready,
  MIN(IF(event_action IN ('saveAttempt', 'saveSuccess'), timestamp, NULL)) AS first_attempt,
  IF(SUM(event_action = 'abort') > 0,
    IF(SUM(`event_action.abort.type` = 'nochange') > 0,
      'abort_nochange',
      'abort'
    ),
    IF(SUM(event_action = 'saveSuccess') > 0,
      'success',
    IF(SUM(event_action = 'saveFailure') > 0,
      'failure',
      'other_abort'
    ))
  ) AS outcome
FROM staging.ve2_pilot_users
INNER JOIN log.Edit_11448630 ON
  wiki = 'enwiki' AND
  user_id = `event_user.id`
WHERE timestamp BETWEEN "2015052115" and "2015052215"
GROUP BY user_id, session_id;