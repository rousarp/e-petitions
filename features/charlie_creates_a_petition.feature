Feature: As Charlie
  In order to have an issue discussed in parliament
  I want to be able to create a petition and verify my email address.

Background:
  Given a department exists with name: "Cabinet Office", description: "Where cabinets do their paperwork"
  And a department exists with name: "Department for International Development", description: "A large portion of the UK population cannot intonate their words properly. This department is responsible for developing this."

@search
Scenario: Charlie has to search for a petition before creating one
  Given a petition "Rioters should loose benefits" belonging to the "Cabinet Office"
  Given I am on the home page
  When I follow "Create a new e-petition"
  Then I should be asked to search for a new petition
  When I check my petition title
  Then I should see a list of existing petitions I can sign
  When I choose to create a petition anyway
  Then I should be on the new petition page
  And I should see my search query already filled in as the title of the petition

Scenario: Charlie creates our petition
  Given I am on the new petition page
  Then I should see "Create a new e-petition - e-petitions" in the browser page title
  And I should be connected to the server via an ssl connection
  When I fill in "e-petition title" with "The wombats of wimbledon rock."
  And I select "Department for International Development" from "Department"
  And I fill in "e-petition details" with "The racial tensions between the wombles and the wombats are heating up. Racial attacks are a regular occurrence and the death count is already in 5 figures. The only resolution to this crisis is to give half of Wimbledon common to the Wombats and to recognise them as their own independent state."
  And I select "3 months" from "Time to collect signatures"
  And I fill in my details
  And I fill in a valid captcha
  And I check "I agree to the Terms & Conditions"
  Then the markup should be valid
  When I press "Submit"
  Then a petition should exist with title: "The wombats of wimbledon rock.", state: "pending", duration: "3"
  And a signature should exist with email: "womboid@wimbledon.com", name: "Womboid Wibbledon", state: "pending", notify_by_email: true
  And "womboid@wimbledon.com" should receive 1 email

  When I confirm my email address
  Then a petition should exist with title: "The wombats of wimbledon rock.", state: "validated"
  And a signature should exist with email: "womboid@wimbledon.com", name: "Womboid Wibbledon", state: "validated"

Scenario: Charlie tries to submit an invalid petition without javascript.
  Given I am on the new petition page

  When I press "Submit"
  Then I should be on the new petition page
  And I should see "Title must be completed"
  And the "e-petition title" row should display as invalid
  And I should see "Description must be completed"
  And the "e-petition details" row should display as invalid
  And I should see "Name must be completed"
  And the "Name" row should display as invalid
  And I should see "Email must be completed"
  And the "Email" row should display as invalid
  And I should see "You must be a British citizen"
  And the "British citizen or UK resident?" row should display as invalid
  And I should see "Address must be completed"
  And the "Address" row should display as invalid
  And I should see "Town must be completed"
  And the "Town" row should display as invalid
  And I should see "Postcode must be completed"
  And the "Postcode" row should display as invalid
  And I should see "You must accept the terms and conditions."
  And the "I agree to the Terms & Conditions" row should display as invalid
  And I should see "The captcha was not filled in correctly."

  When I fill in "e-petition title" with "012345678911234567892123456789312345678941234567895123456789Blah"
  And I select "Department for International Development" from "Department"
  And I fill in "e-petition details" with "This text is longer than 500 characters. 012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789"
  And I fill in "Name" with "Womboid Wibbledon"
  And I fill in "Email" with "invalid.email.com"
  And choose "no"
  And I fill in "Address" with "The old oak, 5 leafy grove, Wimbledon common"
  And I fill in "Town" with "London"
  And I fill in "Postcode" with "BAD PCD"
  And I select "United Kingdom" from "Country"
  And I press "Submit"
  Then I should be on the new petition page
  And I should see "Title is too long."
  And I should see "Description is too long."
  And I should see "Email not recognised."
  And I should see "Postcode not recognised."
  And the "e-petition title" field should contain "012345678911234567892123456789312345678941234567895123456789Blah"
  And the "Department" select field should have "Department for International Development" selected
  And the "e-petition details" field should contain "This text is longer than 500 characters. 012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789"
  And the "Name" field should contain "Womboid Wibbledon"
  And the "Email" field should contain "invalid.email.com"
  And the "no" radio button should be selected
  And the "Address" field should contain "The old oak, 5 leafy grove, Wimbledon common"
  And the "Town" field should contain "London"
  And the "Postcode" field should contain "BAD PCD"
  And the "Country" select field should have "United Kingdom" selected


@javascript
Scenario: Charlie tries to submit an invalid petition with javascript.
  Given I am on the new petition page

  Then I should see "Petition Details" within "//fieldset[1]"

  When I press "Next"
  Then I should see "Title must be completed"
  And I should see "Description must be completed"

  When I fill in "e-petition title" with "012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789Blah"
  And I fill in "e-petition details" with "This text is longer than 1000 characters. 012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789012345678911234567892123456789312345678941234567895123456789"
  And I press "Next" within "//fieldset[1]"
  Then I should see "Title is too long."
  And I should see "Description is too long."

  When I fill in "e-petition title" with "The wombats of wimbledon rock." within "//fieldset[1]"
  And I select "Department for International Development" from "Department" within "//fieldset[1]"
  And I fill in "e-petition details" with "The racial tensions between the wombles and the wombats are heating up.  Racial attacks are a regular occurrence and the death count is already in 5 figures.  The only resolution to this crisis is to give half of Wimbledon common to the Wombats and to recognise them as their own independent state." within "//fieldset[1]"
  And I press "Next" within "//fieldset[1]"
  Then I should see "Your Details" within "//fieldset[2]"

  When I press "Next" within "//fieldset[2]"
  Then I should see "Name must be completed" within "//fieldset[2]"
  And I should see "Email must be completed" within "//fieldset[2]"
  And I should see "You must be a British citizen" within "//fieldset[2]"
  And I should see "Address must be completed" within "//fieldset[2]"
  And I should see "Town must be completed" within "//fieldset[2]"
  And I should see "Postcode must be completed" within "//fieldset[2]"

  When I fill in my details with email "wimbledon@womble.com" and confirmation "uncleb@wimbledon.com"
  And I press "Next" within "//fieldset[2]"
  And I should see "Email must match confirmation" within "//fieldset[2]"

  When I fill in my details

  And I press "Next" within "//fieldset[2]"
  Then I should see "Submit Petition" within "//fieldset[3]"

  #Seems there's an envjs bug here
  # And I should see "The wombats of wimbledon rock."
  # And I should see "Department for International Development"
  # And I should see "The racial tensions between the wombles and the wombats are heating up.  Racial attacks are a regular occurrence and the death count is already in 5 figures.  The only resolution to this crisis is to give half of Wimbledon common to the Wombats and to recognise them as their own independent state."

  And I press "Submit"
  Then I should see "You need to accept the terms and conditions."
  When I check "I agree to the Terms & Conditions"
  And I press "Back" within "//fieldset[3]"
  And I fill in "Name" with "Mr. Wibbledon" within "//fieldset[2]"
  And I press "Next" within "//fieldset[2]"
  
  And I fill in an invalid captcha
  And I press "Submit"
  And I should see "The captcha was not filled in correctly."
  
  And I fill in a valid captcha
  And I press "Submit"

  Then a petition should exist with title: "The wombats of wimbledon rock.", state: "pending"
  And a signature should exist with email: "womboid@wimbledon.com", name: "Mr. Wibbledon", state: "pending"


Scenario: Charlie looks up information about departments
  Given I am on the new petition page
  When I follow "Which department does what?"
  Then I should be on the department information page
  And I should see "Cabinet Office"
  And I should see "Where cabinets do their paperwork"
  And I should see "Department for International Development"
  And I should see "A large portion of the UK population cannot intonate their words properly. This department is responsible for developing this."

#The JS version for this scenario can't be run since Selenium doesn't seem to understand pages in new tabs.


