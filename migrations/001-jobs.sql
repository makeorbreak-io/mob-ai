CREATE EXTENSION "uuid-ossp";

CREATE TABLE jobs(
  id uuid DEFAULT uuid_generate_v4(),
  payload JSONB,
  type VARCHAR,
  status VARCHAR,
  worker VARCHAR,
  updated_at TIMESTAMP,
  result JSONB
);
