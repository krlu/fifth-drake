package gg.climb.fifthdrake.lolobjects.accounts

import java.util.UUID

/**
  * Data object for user account information
  *
  * Created by michael on 3/3/17.
  */
class User(val uuid: UUID,
           val firstName: String,
           val lastName: String,
           val userId: String,
           val email: String,
           val authorized: Boolean,
           val accessToken: String,
           val refreshToken: String)
