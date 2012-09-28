ActivityLog.register(:asset, AssetLogDecorator, %{
  SELECT
    'asset' AS type,
    updated_at AS created_at,
    (SELECT name FROM users WHERE id = updater_id) AS user_name,
    'updated' AS event,
    REPLACE(type, 'Asset', ' - ') || name,
    id,
    NULL AS parent_id
  FROM assets
  ORDER BY updated_at
})

ActivityLog.register(:user, UserLogDecorator, %{
  SELECT
    'user' AS type,
    updated_at AS created_at,
    NULL AS user_name,
    'updated' AS event,
    name,
    id,
    NULL AS parent_id
  FROM users
  ORDER BY updated_at
})
