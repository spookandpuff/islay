ActivityLog.register(:asset, AssetLogDecorator, %{
  SELECT
    'asset' AS type,
    updated_at AS created_at,
    (SELECT name FROM users WHERE id = updater_id LIMIT 1) AS user_name,
    update_status(created_at, updated_at) AS event,
    REPLACE(type, 'Asset', ' - ') || name AS name,
    id,
    NULL::integer AS parent_id
  FROM assets
  ORDER BY updated_at
})

ActivityLog.register(:asset_group, AssetGroupLogDecorator, %{
  SELECT
    'asset_group' AS type,
    updated_at AS created_at,
    (SELECT name FROM users WHERE id = updater_id LIMIT 1) AS user_name,
    update_status(created_at, updated_at) AS event,
    name,
    id,
    NULL::integer AS parent_id
  FROM asset_groups ORDER BY updated_at
})

ActivityLog.register(:user, UserLogDecorator, %{
  SELECT
    'user' AS type,
    updated_at AS created_at,
    NULL AS user_name,
    update_status(created_at, updated_at) AS event,
    name,
    id,
    NULL::integer AS parent_id
  FROM users
  ORDER BY updated_at
})
