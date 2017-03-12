CREATE TABLE account.user(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  user_id TEXT NOT NULL,
  email TEXT NOT NULL,
  authorized BOOLEAN NOT NULL,
  access_token TEXT NOT NULL,
  refresh_token TEXT NOT NULL
);