Feature: Pulling Oauth 2.0 Access Token

  Scenario: Oauth 2.0 Grant Token
    * url 'https://accounts.stage.tdstickets.com/auth/realms/qa/protocol/openid-connect/token'
    * form field grant_type = grant_type
    * form field client_id = client_id
    * form field client_secret = client_secret
    * method post
    * status 200

    * def accessToken = response.access_token
    * print accessToken