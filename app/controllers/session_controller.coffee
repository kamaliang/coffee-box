exports.getSessionController = (app) ->

  openid = require('openid')
  relyingParty = new openid.RelyingParty(
      app.settings.url + '/verify' # verification url
    , null                         # realm
    , false                        # use stateless verification
    , []                           # extensions
    )

  return {

    # GET /login
    new: (req, res, next) ->
      res.render 'session/new'

    # POST /login
    create: (req, res, next) ->
      # don't auth with OpenID if in dev mode
      if app.settings.env is 'development'
        req.session.loggedIn = true
        return res.redirect '/admin'
      
      id = req.body.id
      relyingParty.authenticate id, false, (error, authUrl) ->
        return res.send 'Authentication failed: ' + error.message, 200 if error?
        return res.send 'Authentication failed', 200 unless authUrl
        res.redirect authUrl

    # GET /verify
    verify: (req, res, next) ->
      message = ''
      relyingParty.verifyAssertion req, (error, result) ->
        if error
          message = error
        else
          if result.authenticated
            if result.claimedIdentifier in app.settings.openIds
              req.session.loggedIn = true
              return res.redirect '/admin'
            else
              message = 'account not in admin list'
        res.send 'Authentication failed: ' + message


    # GET /logout
    destroy: (req, res, next) ->
      req.session.destroy (err) ->
        res.redirect 'home'

    # middleware for requiring login
    requireLogin: (req, res, next) ->
      return res.rediret '/login' unless req.session.loggedIn
      next()

  }
