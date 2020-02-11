Feature: Log In

  Background:
    #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}

    * def faker = new faker()

  Scenario: Creating a New User
    * def userCreateRequest =
    """
    {
      "country": {

        "countryId": 1

      },
      "email": "sbrooks+ppb2@tdstickets.com",
      "firstName": "Steven",
      "lastName": "Brooks",
      "mobile": "5555525548",
      "password": "test1234",
      "matchingPassword": "test1234"
    }
    """

    Given path 'user'
    And request { 'carrierId': 1, 'origin': { 'stopUuid': '#(origin.origin)' }, 'destination': { 'stopUuid': '#(destination.destination)' }, 'departDate': '#(randomDepart)' }
    When method post
    Then status 200