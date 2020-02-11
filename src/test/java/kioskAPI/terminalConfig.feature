Feature: Pulling configuration from the Termnial

  Background:
    * def keyCloakInfo = { grant_type: 'client_credentials', client_id: 'kiosk',client_secret: 'd507efd5-f4eb-4607-8a05-91495aa8804e' }
    * call read('classpath:oauth2.feature') keyCloakInfo
    * print accessToken

    * url 'https://api.qa.tdstickets.com/kiosk'
    * configure headers = { TDS-Serial-Number: 'F183009004', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa

  Scenario: Successfully pulling the Terminal configuration
    Given path 'v1/terminal'
    And request {}
    When method get
    Then status 200

    * print response