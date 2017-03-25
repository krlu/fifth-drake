CREATE TABLE account.user_to_permission(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES account.user(id),
  group_id UUID REFERENCES account.user_group(id),
  permission account.permission_level NOT NULL
);
