Feature: Pulling Oauth 2.0 Access Token

  Scenario: Oauth 2.0 Grant Token
    * url 'https://accounts.stage.tdstickets.com/auth/realms/qa/protocol/openid-connect/token'
    * form field grant_type = "#(clientCreds)"
    * form field client_id = 'wanderu-carrier-ops'
    * form field client_secret = 'c5cdefb8-7982-48ad-84cd-354c991b186f'
    * method post
    * status 200

    * def accessToken = response.access_token
    * print accessToken