# Chase Stevens -- Device Readings API

This repo is a Ruby on Rails API for a server to receive and host device counts and readings while storing all data in memory.

## Setup
- Check that local ruby version matches with project version (3.0.1).
- Install Memcached 
  - For MacOS with HomeBrew, run `brew install memcached`
  - Ensure that memcached is working with `brew services restart memcached`
- Run `bundle install` to install all third party packages are installed
- Run `bin/rails s` to start the server

## Reading the Repo
- `config/routes.rb` for endpoints to the API
- `app/controllers/v1/devices_controller.rb` for actions and routing requests
- `app/models/device.rb` for Device specific logic
- `lib/memory_store.rb` for connection to the Memcached data layer

## Checking the API
- Create a device `post "/record_count"`
- Update a device `post "/record_count"`
- Check device's latest reading `get "/latest_timestamp/:uuid"`
- Check device's cumulative count `get "/cumulative_count/:uuid"`
- Reset the Memecached process (`brew services restart memcached`) and verify that all previous data in memory has been removed

## Key Decisions Made
- Ruby on Rails API -- The server is set up using the Ruby on Rails web framework. While some may find that Ruby on Rails would be heavy handed for a simple web server, the framework provides a lot of benefits and features out of the box. https://guides.rubyonrails.org/api_app.html#why-use-rails-for-json-apis-questionmark
- Memcached -- The data is stored in memory using Memcached
  - Separate Process -- Having the memory storage run on a separate process from the web server means that the server can be started and stopped without resetting the data in memory.
  - Guaranteed to store data in memory
- Non-RESTful API -- The endpoints provided in the API match the business logic provided in the scope of work.

## Post Mortem
Due to the time limit provided, the API in the repo here is not up to production standards. Much time was spent investing in reading and writing data from the memory layer to the application.

For models in Ruby on Rails, classes would inherit from the ActiveRecord::Base class. ActiveRecord is an ORM that provides functionality for reading and writing data to and from the database. Since we are not using a standard database, we opted to not inherit from ActiveRecord and instead implement models at Plain Old Ruby Objects. This can be seen in the class methods `find` and `create`.

We also invested time in moving the client to write to and from the Memecached data into its own module that could be included in other models moving forward.

Overall, I don't think any single decision was the wrong decision. I view this API in its current state as a good foundation, both to serve its initial need, and also as being flexible and maintanable to include other features. There would be more work needed to get the API to a production-ready state, but that work is identified and could be implemented in a straight forward and confident manner.


## Areas to Improve On
### Tests
Tests for the Device model, the Devices controller, the routes and parameters of the API, and the MemoryStore module would provide easier maintenance and stability in the application moving forward.

My choice in tests would be to add RSpec for writing test cases and assertions. Many reach for FactoryBot for adding test data -- I think in our current case that this choice would be overkill, and instead would opt to use RSpec doubles for mock data.

### Error Handling
The API has simple guard clauses and nil checks to ensure that missing or malformed data does not cause the server to raise exceptions; however, error handling could be improved to cover more cases, as well as writing custom exceptions to raise more detailed messages to the user and to improve monitoring and visibility into application metrics.

### Data Structure and Validation
The application has a few checks at the controller and model level to ensure that data is not passed to memory that we do not want to store; however, more could be done to ensure that data adheres to our standards. Adding in structs for readings would help improve how we can read and write data, and controlling what data we write to the memory layer from our `Device#create` and `Device#update` methods would also allow for better data validation.

### Security and Authentication
In its current state, the API can receive and return data to anyone who knows a device's ID. Since each device has a long alphanumeric UUID, there is a layer of security through obfuscation; however, this would be insufficient to serve clients in the real world. Adding a token generation layer and check for each device would be a way to step up security and ensure 