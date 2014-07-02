
* Pinger
  * Implement detailed logging
  * Handle expected response
  * Handle 500 errors
* Walk through for edge-case error handling
* Completely test non-get requests (how do you define them in urls.yaml?)
* Tests for EMHTTPDispatcher
* Support proxies for outgoing connections
* Write the net/http dispatcher
* Debug logging to log responses too
* Write a URL Agent server to proxy requests through

## Done

### 20120402 (binoy@mobme.in)
* Modified logging format to include url name in all log lines

### 20110817 (vishnu@mobme.in)
* Pinger is now integrated into Base & monitoring is auto-started if there is a pinger configuration in urls.yaml.
* A logger implementation & detailed logging for Pinger
* Sprinkling logging seeds everywhere
* Detailed debug logging for requests & responses
* Fixed Fiber.yield errors for the Pinger

### 20110816 (vishnu@mobme.in)
* Pinger
  * Pinger now works & tests connection and timeout errors configurable in the pinger block in urls.yaml
  * Each url can be configured separately with test parameters

### 20110810 (vishnu@mobme.in)
* Extensive reworking to work with edge versions of gems.
* Fixing a bug in upstream em-http-request & em-synchrony.
* Base now throws error on timeouts and connection errors.
* Much _cleaner_ code, modularizing into base, url sets & urls.
  * Urls can be marked as dead
  * Url sets have at least one live url.
  * Urls can be directly invoked & passed on to the dispatcher.
* BREAKING CHANGE: The url_agent.call(:google) syntax no longer works.

### 20110729 (vishnu@mobme.in)
* url_agent[:identifier].get(arguments) work

### 20110726 (vishnu@mobme.in)
* The basic URLAgent::Base class
  * url_agent = URLAgent::Base.instance
  * url_agent.call(:identifier, { parameters }) => result
* Auto-detection of em-synchrony architecture
* The em-http dispatcher
