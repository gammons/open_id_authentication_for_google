class OAuthConfig

  attr_reader :service, :yml_config, :settings
  
  def self.for(service)
    new(service)
  end
  
  
  def initialize(service)
    @service=service
    hash = YAML.load_file(File.join(RAILS_ROOT, 'config', 'oauth_consumer.yml'))    
    @yml_config = hash[RAILS_ENV][@service.to_s]
  end
    
  def consumer_key
    @yml_config["consumer_key"]
  end

  def consumer_secret
    @yml_config["consumer_secret"]
  end
  
  def settings
    case @service
    when :google
      { :site => "https://www.google.com", 
        :request_token_path => "/accounts/OAuthGetRequestToken",
        :authorize_path => "/accounts/OAuthAuthorizeToken",
        :access_token_path => "/accounts/OAuthGetAccessToken",
        :scheme             => :header,
        :http_method        => :post }
    else
      {}
    end
  end
  
end
