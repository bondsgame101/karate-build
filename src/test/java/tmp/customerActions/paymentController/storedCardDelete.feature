Feature: Delete Stored Card

  Background:
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}

#    * def faker = new faker()
#    * def firstName = faker.name().firstName()
#    * def lastName = faker.name().lastName()
#    * def zip = faker.address().zipCode()
#    * def address1 = faker.address().streetAddress()
#    * def city = faker.address().city()
#    * def state = faker.address().stateAbbr()
#    * def mobile = faker.phoneNumber().cellPhone()

    * call read('storedCards.feature')
    * print storedPaymentId

  Scenario: Deleting Store Cards

    Given path 'customer/payment/stored/'
    And path storedPaymentId
    When method delete
    Then status 200

    * print response
    * def oldPaymentId = storedPaymentId

    * call read('storedCards.feature')

    * print storedPaymentId
    * print oldPaymentId

    * match oldPaymentId != '#(storedPaymentId)'
#    * def result = karate.match(oldPaymentId, storedPaymentId)
#    * print result