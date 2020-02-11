Feature: End a kiosk in Maintenance mode

  Background:
    * def keyCloakInfo = { grant_type: 'client_credentials', client_id: 'kiosk',client_secret: 'd507efd5-f4eb-4607-8a05-91495aa8804e' }
    * call read('classpath:oauth2.feature') keyCloakInfo
    * print accessToken

    * url 'https://api.qa.tdstickets.com/kiosk'
    * configure headers = { TDS-Serial-Number: 'F183009004', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa


  Scenario: Ending of Maintenance mode for Kiosk
    Given path 'v1/maintenance/end'
    And request {}
    When method post
    Then assert responseStatus == 200 || responseStatus == 400
    * def response = responseStatus == 200 ? {'startAt': '#string'} : {'message': 'This terminal is not currently in maintenance mode'}
    * match response contains any response

    * print response




