require 'google_api_scopes'
require 'oauth_config'

module Rack
  class OpenID
    
    def begin_authentication(env, qs)
      req = Rack::Request.new(env)
      params = self.class.parse_header(qs)
      session = env["rack.session"]

      unless session
        raise RuntimeError, "Rack::OpenID requires a session"
      end

      consumer = ::OpenID::Consumer.new(session, @store)
      identifier = params['identifier'] || params['identity']

      begin
        oidreq = consumer.begin(identifier)
        add_simple_registration_fields(oidreq, params)
        add_attribute_exchange_fields(oidreq, params)
        add_oauth_hybrid_fields(oidreq, params)
        add_ui_fields(oidreq, params)
        url = open_id_redirect_url(req, oidreq, params["trust_root"], params["return_to"], params["method"])
        return redirect_to(url)
      rescue ::OpenID::OpenIDError, Timeout::Error => e
        env[RESPONSE] = MissingResponse.new
        return @app.call(env)
      end
    end

    # openid.ns.oauth=http://specs.openid.net/extensions/oauth/1.0
    # openid.oauth.consumer=vark.com
    # openid.oauth.scope=http://www-opensocial.googleusercontent.com/api/people    
    def add_oauth_hybrid_fields(open_id_request, params={})
      if params["oauth_scopes"] and !params["oauth_scopes"].empty?
        raise "You must pass an oauth_consumer_key" unless params["oauth_consumer_key"]        
        scopes_str = []
        
        params["oauth_scopes"].each do |oauth_scope_key|
          if oauth_scope_value = GOOGLE_API_SCOPES[oauth_scope_key.to_sym]
            scopes_str << oauth_scope_value
          else
            scopes_str << oauth_scope_key
          end
        end
        
        unless scopes_str.empty?
          oauth_scope = scopes_str.join(',')        
          oauth_request_token_request = ::OpenID::OAuthHybrid::Request.new(params["oauth_consumer_key"], oauth_scope)
          open_id_request.add_extension(oauth_request_token_request)
        end
      end
    end


    def add_ui_fields(open_id_request, params={})
      if params["ui"] #and params["ui"]["mode"] and params["ui"]["mode"]=='popup'
        ui_request = ::OpenID::UI::Request.new(params)
        open_id_request.add_extension(ui_request)
      end
    end
    
    
    private
    
    def request_url(req)
      url = realm_url(req)
      url << req.script_name
      url << req.path_info
      unless req.query_string.blank?
        url << '?'+req.query_string
      end
      url
    end
    
  end
end
