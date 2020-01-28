Feature: End a kiosk in Maintenance mode

  Background:
    * url 'https://accounts.stage.tdstickets.com/auth/realms/qa/protocol/openid-connect/token'
#    * url 'https://accounts.stage.tdstickets.com/auth/realms/stage/protocol/openid-connect/token'
    * form field grant_type = 'client_credentials'
    * form field client_id = 'kiosk'
    * form field client_secret = 'd507efd5-f4eb-4607-8a05-91495aa8804e'
    * method post
    * status 200

    * def accessToken = response.access_token
    * print accessToken

    * url 'https://api.qa.tdstickets.com/kiosk'
    * configure headers = { TDS-Serial-Number: 'F183009004', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa


  Scenario: Ending of Maintenance mode for Kiosk
    Given path 'v1/maintenance/end'
    And request {}
    When method post
    Then status 200

    * print response
