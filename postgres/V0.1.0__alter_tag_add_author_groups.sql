ALTER TABLE league.tag
  ADD COLUMN author INTEGER REFERENCES account.user(id),
  ADD COLUMN authorized_groups UUID[];