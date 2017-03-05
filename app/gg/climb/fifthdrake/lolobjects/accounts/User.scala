package gg.climb.fifthdrake.lolobjects.accounts

/**
  * Data object for user account information
  *
  * Created by michael on 3/3/17.
  */
class User(val uuid: String,
           val firstName: String,
           val lastName: String,
           val userId: String,
           val email: String,
           val authorized: Boolean,
           val accessToken: String,
           val refreshToken: String)
