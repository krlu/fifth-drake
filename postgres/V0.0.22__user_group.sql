CREATE TABLE account.user_group(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  users UUID[]
);