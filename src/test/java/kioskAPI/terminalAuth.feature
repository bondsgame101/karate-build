Feature: Logging into Terminal

  Background:
    * def keyCloakInfo = { grant_type: 'client_credentials', client_id: 'kiosk',client_secret: 'd507efd5-f4eb-4607-8a05-91495aa8804e' }
    * call read('classpath:oauth2.feature') keyCloakInfo
    * print accessToken

    * url 'https://api.qa.tdstickets.com/kiosk'
    * configure headers = { TDS-Serial-Number: 'F183009004', TDS-Unlock-Key: 'Basic RjE4MzAwOTAwNDoxMjM0', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa

  Scenario: Ending of Maintenance mode for Kiosk
    Given path 'v1/unlock'
    And request {}
    When method post
    Then status 200

    * print resonse