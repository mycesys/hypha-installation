-- required for password encryption
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION guacamole_create_user_and_session(
  task_id VARCHAR(4096),
  guacamole_password VARCHAR(4096),
  remote_login VARCHAR(4096),
  remote_password VARCHAR(4096),
  hostname VARCHAR(4096),
  port VARCHAR(4096),
  remote_app_name VARCHAR(4096),
  remote_app_dir VARCHAR(4096),
  remote_app_parameters VARCHAR(4096),
  OUT created_user_id INTEGER,
  OUT created_user_login VARCHAR(4096)
)
AS $$
DECLARE
    created_connection_id INTEGER;
    created_entity_id INTEGER;
    password_salt BYTEA := gen_random_bytes(32);
BEGIN
    INSERT INTO guacamole_connection
    (connection_name, parent_id, protocol, max_connections, max_connections_per_user, connection_weight, failover_only, proxy_port, proxy_hostname, proxy_encryption_method)
    SELECT
      connection_name_prefix || '_' || task_id as connection_name,
      parent_id,
      protocol,
      max_connections,
      max_connections_per_user,
      connection_weight,
      failover_only,
      proxy_port,
      proxy_hostname,
      proxy_encryption_method
    FROM guacamole_connection_template
    ORDER BY template_priority
    LIMIT 1
    RETURNING connection_id INTO created_connection_id;

    INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
    ((
      SELECT
      created_connection_id as connection_id,
      parameter_name,
      parameter_value
      FROM guacamole_connection_parameter_template
    ) UNION (
      SELECT
      created_connection_id as connection_id,
      parameter_name,
      parameter_value
      FROM ( VALUES
        ('hostname', hostname),
        ('port', port),
        ('initial-program',remote_app_name),
        ('remote-app',remote_app_name),
        ('username',remote_login),
        ('password',remote_password),
        ('remote-app-dir', remote_app_dir),
        ('remote-app-args', remote_app_parameters)
      ) AS guacamole_connection_parameter_configurable(parameter_name, parameter_value)
    ));

    INSERT INTO guacamole_entity (name, type)
    SELECT
      connection_name_prefix || '_' || task_id as name,
      'USER' as type
    FROM guacamole_connection_template
    RETURNING entity_id, name INTO created_entity_id, created_user_login;
    INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission)
    VALUES (created_entity_id,created_connection_id,'READ');
    INSERT INTO guacamole_connection_group_permission (entity_id, connection_group_id, permission)
    SELECT
      created_entity_id,
      guacamole_connection_template.parent_id as connection_group_id,
      'READ'
    FROM guacamole_connection_template WHERE parent_id IS NOT NULL AND template_priority = (SELECT min(template_priority) FROM guacamole_connection_template);

    INSERT INTO guacamole_user
      (entity_id,password_hash,password_salt,password_date,disabled,expired)
    VALUES
      (created_entity_id,digest(guacamole_password || upper(encode(password_salt, 'hex')), 'sha256'),password_salt,NOW(),false,false)
    RETURNING user_id INTO created_user_id;
    INSERT INTO guacamole_user_permission (entity_id, affected_user_id, permission)
    VALUES (created_entity_id,created_user_id,'READ');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION guacamole_finish_session_and_disable_user(user_id_to_finish INTEGER) RETURNS INTEGER
AS $$
BEGIN
    UPDATE guacamole_connection_history SET end_date = NOW() WHERE user_id = user_id_to_finish;
    UPDATE guacamole_user SET disabled = true WHERE user_id = user_id_to_finish;
    RETURN user_id_to_finish;
END;
$$ LANGUAGE plpgsql;
