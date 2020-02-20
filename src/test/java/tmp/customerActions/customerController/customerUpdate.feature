Feature: Customer Update
  Background:
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}

    * def faker = new faker()
    * def firstName = faker.name().firstName()
    * def lastName = faker.name().lastName()
    * def zip = faker.address().zipCode()
    * def address1 = faker.address().streetAddress()
    * def city = faker.address().city()
    * def state = faker.address().stateAbbr()
    * def mobile = faker.phoneNumber().cellPhone()

    * call read('login.feature')

  Scenario: Updating Customer Information
    * print customerDetail
    * def customerUpdate =
    """
    {
      "customerId": "#(customerId)",
      "firstName": "#(firstName)",
      "lastName": "#(lastName)",
      "address1": "#(address1)",
      "address2": null,
      "city": "#(city)",
      "state": "#(state)",
      "zip": "#(zip)",
      "country": {
          "countryId": 1,
          "name": "United States",
          "countryAbbrev": "US",
          "country3LetterAbbrev": "USA"
      },
      "phone": "(904) 888-8888",
      "mobile": "#(mobile)",
      "email": "sbrooks+ppb1@tdstickets.com"
    }
    """

#    * print customerUpdate

    Given path 'customer/update'
    And request customerUpdate
    When method put
    Then status 200

    * call read('customerDetail.feature')

    * print customerDetail
