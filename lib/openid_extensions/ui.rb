# An implementation of the OpenID User Interface Extension 1.0 DRAFT 0.4
# 
# see: http://wiki.openid.net/f/openid_ui_extension_draft01.html
 
# &openid.ns.ui=http://specs.openid.net/extensions/ui/1.0
# &openid.ui.icon=true
# &openid.ui.mode=popup 
 
require 'oauth'
require 'openid/extension'
 
module OpenID
 
  module UI
    NS_URI = "http://specs.openid.net/extensions/ui/1.0"
 
    class Request < Extension
      attr_accessor :ns_alias, :ns_uri

      def initialize(options)
        @ns_alias = 'ui'
        @ns_uri = NS_URI
        @options = options
      end
 
      def self.from_openid_request(oid_req)
        oauth_req = new
        args = oid_req.message.get_args(NS_URI)
        if args == {}
          return nil
        end
        oauth_req.parse_extension_args(args)
        return oauth_req
      end
 
      
      def parse_extension_args(args)
        @icon = args['icon']
        @mode = args['mode']
      end
 
      def get_extension_args
        ns_args = {}
        ns_args['icon'] = 'true'
        ns_args['mode'] = 'popup'
        return ns_args
      end
    end
 
    class Response < Extension
    end
 
  end
end