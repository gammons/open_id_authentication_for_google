require 'uri'
require 'openid'
require 'rack/openid'

require 'rack/open_id_overrides'
require 'ax_mappings'
require 'google_api_scopes'
require 'openid_extensions/oauth_hybrid'
require 'openid_extensions/ui'
require 'oauth_config'


module OpenIdAuthentication
  
  GOOGLE_OPEN_ID_IDENTIFIER = 'https://www.google.com/accounts/o8/id'
  
  def self.new(app)
    store = OpenIdAuthentication.store
    if store.nil?
      Rails.logger.warn "OpenIdAuthentication.store is nil. Using in-memory store."
    end

    ::Rack::OpenID.new(app, OpenIdAuthentication.store)
  end

  def self.store
    @@store
  end

  def self.store=(*store_option)
    store, *parameters = *([ store_option ].flatten)

    @@store = case store
    when :memory
      require 'openid/store/memory'
      OpenID::Store::Memory.new
    when :file
      require 'openid/store/filesystem'
      OpenID::Store::Filesystem.new(Rails.root.join('tmp/openids'))
    when :memcache
      require 'memcache'
      require 'openid/store/memcache'
      OpenID::Store::Memcache.new(MemCache.new(parameters))
    else
      store
    end
  end

  self.store = nil

  class Result
    ERROR_MESSAGES = {
      :missing      => "Sorry, the OpenID server couldn't be found",
      :invalid      => "Sorry, but this does not appear to be a valid OpenID",
      :canceled     => "OpenID verification was canceled",
      :failed       => "OpenID verification failed",
      :setup_needed => "OpenID verification needs setup"
    }

    def self.[](code)
      new(code)
    end

    def initialize(code)
      @code = code
    end

    def status
      @code
    end

    ERROR_MESSAGES.keys.each { |state| define_method("#{state}?") { @code == state } }

    def successful?
      @code == :successful
    end

    def unsuccessful?
      ERROR_MESSAGES.keys.include?(@code)
    end

    def message
      ERROR_MESSAGES[@code]
    end
  end

  protected
  
        
    # The parameter name of "openid_identifier" is used rather than
    # the Rails convention "open_id_identifier" because that's what
    # the specification dictates in order to get browser auto-complete
    # working across sites
    def using_open_id?(identifier = nil) #:doc:
      identifier ||= open_id_identifier
      !identifier.blank? || request.env[Rack::OpenID::RESPONSE]
    end

    def authenticate_with_open_id(identifier = nil, options = {}, &block) #:doc:
      if identifier == :google
        identifier = GOOGLE_OPEN_ID_IDENTIFIER     
      end
      
      # TODO: make this configurable
      @openid_service = :google              
      
      # Map AX keys
      if options[:required]
        options[:required].collect! do |field_name|
          if ax_attr_name = AX_MAPPINGS[field_name.to_sym]
            ax_attr_name
          else
            field_name
          end
        end
      end

      if options[:optional]
        options[:optional].collect! do |field_name|
          if ax_attr_name = AX_MAPPINGS[field_name.to_sym]
            ax_attr_name
          else
            field_name
          end
        end
      end
      
      identifier ||= open_id_identifier

      if options[:oauth_scopes] and !options[:oauth_scopes].empty?
        # need to save oauth config so that access token can be requested        
        @oauth_config = OAuthConfig.for(@openid_service)
        
        # need to pass the consumer_key to Rack
        options[:oauth_consumer_key] = @oauth_config.consumer_key        
      end
      
      if request.env[Rack::OpenID::RESPONSE]
        complete_open_id_authentication(&block)
      else
        begin_open_id_authentication(identifier, options, &block)
      end
    end

  private
  
    def open_id_identifier
      params[:openid_url] || params[:openid_identifier]
    end

    def begin_open_id_authentication(identifier, options = {})
      options[:identifier] = identifier
      value = Rack::OpenID.build_header(options)
      response.headers[Rack::OpenID::AUTHENTICATE_HEADER] = value
      head :unauthorized
    end

    def complete_open_id_authentication
      response   = request.env[Rack::OpenID::RESPONSE]
      identifier = response.display_identifier

      case response.status
      when OpenID::Consumer::SUCCESS
        # Merge sreg and ax data
        data = OpenID::SReg::Response.from_success_response(response).data
        
        if ax=OpenID::AX::FetchResponse.from_success_response(response) and !ax.data.empty?
          ax.data.each_pair do |ax_field_name, value|
            if attr_name = INVERTED_AX_MAPPINGS[ax_field_name]
              data[attr_name]=value
            else
              data[ax_field_name]=ax.data[ax_field_name]
            end
          end
        end

        # Get OAuth access token
        if oauth_response = OpenID::OAuthHybrid::Response.from_success_response(response) and oauth_response.request_token
          data[:oauth_access_token] = get_oauth_access_token(oauth_response)
        end

        yield Result[:successful], identifier, data
      when :missing
        yield Result[:missing], identifier, nil
      when :invalid
        yield Result[:invalid], identifier, nil
      when OpenID::Consumer::CANCEL
        yield Result[:canceled], identifier, nil
      when OpenID::Consumer::FAILURE
        yield Result[:failed], identifier, nil
      when OpenID::Consumer::SETUP_NEEDED
        yield Result[:setup_needed], response.setup_url, nil
      end
    end
    
    def get_oauth_access_token(authorized_request_token)
      google_oauth_consumer = OAuth::Consumer.new(@oauth_config.consumer_key, @oauth_config.consumer_secret, @oauth_config.settings)
      request_token = OAuth::RequestToken.new google_oauth_consumer, authorized_request_token.request_token
      request_token.get_access_token
    end
end
