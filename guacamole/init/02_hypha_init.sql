CREATE TABLE guacamole_connection_parameter_template(
  parameter_name  varchar(128),
  parameter_value varchar(4096),

  PRIMARY KEY (parameter_name)
);
INSERT INTO guacamole_connection_parameter_template (parameter_name, parameter_value)
VALUES
('client-name','hypha'),
('normalize-clipboard', 'preserve'),
('server-layout', 'failsafe'),
('ignore-cert', true),
('console', true),
('timeout', 5),
('resize-method', 'display-update')
;

CREATE TABLE guacamole_connection_template (
  connection_name_prefix     varchar(128) NOT NULL,
  -- connection group id
  parent_id           integer,
  protocol            varchar(32)  NOT NULL,
  
  -- Concurrency limits
  max_connections          integer,
  max_connections_per_user integer,

  -- Connection Weight
  connection_weight        integer,
  failover_only            boolean NOT NULL DEFAULT FALSE,

  -- Guacamole proxy (guacd) overrides
  proxy_port              integer,
  proxy_hostname          varchar(512),
  proxy_encryption_method guacamole_proxy_encryption_method,

  template_priority INT,

  PRIMARY KEY (connection_name_prefix)
);
INSERT INTO guacamole_connection_template
(connection_name_prefix, parent_id, protocol, max_connections, max_connections_per_user, connection_weight, failover_only, proxy_port, proxy_hostname, proxy_encryption_method, template_priority)
VALUES
('hypha', null, 'rdp', 1, 1, null, false, null, null, null, 0);
