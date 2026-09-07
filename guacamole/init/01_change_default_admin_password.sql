\getenv guacamole_admin_password GUACAMOLE_ADMIN_PASSWORD

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION guacamole_change_password(user_id_to_change INTEGER, new_password TEXT) RETURNS TEXT
AS $$
DECLARE
    salt BYTEA := gen_random_bytes(32);
BEGIN
    UPDATE guacamole_user SET password_hash = digest(new_password || upper(encode(salt, 'hex')), 'sha256') WHERE user_id = user_id_to_change;
    UPDATE guacamole_user SET password_salt = salt WHERE user_id = user_id_to_change;
    RETURN new_password;
END;
$$ LANGUAGE plpgsql;

-- change default password to set in .env
SELECT guacamole_change_password(1, :'guacamole_admin_password');

DROP FUNCTION guacamole_change_password;
