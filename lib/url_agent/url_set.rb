class URLAgent::UrlSet
  attr_reader :urls

  def initialize(urls, options = {})
    @urls = {}
    urls.each do |identifier, url|
      @urls[identifier] = URLAgent::Url.new(url, options.merge(:identifier => identifier))
    end
  end

  def active
    (@urls.select { |key, url| url.alive? }).values.first or raise URLAgent::NoLiveURLFound, "No active url found!"
  end

  def dead!(identifier)
    @urls[identifier].dead!
  end

  def alive!(identifier)
    @urls[identifier].alive!
  end

  def build(arguments = {})
    active.build(arguments)
  end
end
