class URLAgent::ConfigurationNotFoundException < Exception
end

class URLAgent::GemsNotFoundException < Exception
end

class URLAgent::IdentifierNotFoundException < Exception
end

class URLAgent::TimeoutException < Exception
end

class URLAgent::ConnectionError < Exception
end

class URLAgent::NoLiveURLFound < Exception
end

class URLAgent::EMHTTPDispatcherReactorNotRunning < Exception
end

class URLAgent::LogDirectoryNotPresent < Exception
end
