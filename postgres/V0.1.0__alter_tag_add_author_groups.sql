ALTER TABLE league.tag
  ADD COLUMN author UUID REFERENCES account.user(id),
  ADD COLUMN authorized_groups UUID[];
