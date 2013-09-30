require 'json'
require 'net/http'
require 'net/https'

module Ymgr

  class Ymapi

    @@URL_OAUTH_DIRECT = "https://login.yahoo.com/WSLogin/V1/get_auth_token"
    @@URL_OAUTH_ACCESS_TOKEN = 'https://api.login.yahoo.com/oauth/v2/get_token'
    @@URL_YM_SESSION = 'http://developer.messenger.yahooapis.com/v1/session'
    @@URL_YM_PRESENCE = 'http://developer.messenger.yahooapis.com/v1/presence';
    @@URL_YM_CONTACT = 'http://developer.messenger.yahooapis.com/v1/contacts';
    @@URL_YM_MESSAGE = 'http://developer.messenger.yahooapis.com/v1/message/yahoo/{{USER}}';
    @@URL_YM_NOTIFICATION = 'http://developer.messenger.yahooapis.com/v1/notifications';
    @@URL_YM_NOTIFICATION_LONG = 'http://{{NOTIFICATION_SERVER}}/v1/pushchannel/{{USER}}';
    @@URL_YM_BUDDYREQUEST = 'http://developer.messenger.yahooapis.com/v1/buddyrequest/yahoo/{{USER}}';
    @@URL_YM_GROUP = 'http://developer.messenger.yahooapis.com/v1/group/{{GROUP}}/contact/yahoo/{{USER}}';

    @_oauth = nil
    @_token = Hash.new
    @_ym = Hash.new
    @_config = nil
    @_error = nil

    @includeheader = false;
    @debug = false;

    @consumer_key = 'dj0yJmk9ZFZheFdod3hTSEVyJmQ9WVdrOVlUVjBXbFF6TXpZbWNHbzlOalEyT1RNNE1EWXkmcz1jb25zdW1lcnNlY3JldCZ4PTFm'
    @secret_key = '61ac2818885b42ffb4dbce20e7313d2d4d24e2f5'
    @username = 'bott1988'
    @password = 'P@ssw0rd'

# def initialize(consumer_key = 'dj0yJmk9MFRVbmE5R3lnTkhsJmQ9WVdrOWVFa3pjbWRhTkc4bWNHbzlNVEl6T1RVM09UTTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1mNQ--', secret_key = 'c6b3d593f9c5aae82cb0560f8cc138975ae362a4', username = 'testbott', password = 'P@ssw0rd')
#    @consumer_key = consumer_key
#    @secret_key = secret_key
#    @username = username
#    @password = password
    @_ym = Hash.new
    @_error = nil
#  end

    def fetch_request_token
      url = @@URL_OAUTH_DIRECT;
 #   puts url
      url = url + "?&login=" + @username;
      url = url + "&passwd=" + @password;
      url = url + "&oauth_consumer_key=" + @consumer_key;
      puts url
      encoded_url = URI.encode(url)
      uri = URI.parse(encoded_url)
      rs = Net::HTTP.new(uri.host, uri.port)
      rs.use_ssl = true
      rs.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)

      response = rs.request(request)
      rb = response.body
      request_token = rb.gsub('RequestToken=', '').strip
      @_token = Hash.new
      @_token['request'] = request_token
      p @_token
#    return true;
    end

    def fetch_access_token
      url = @@URL_OAUTH_ACCESS_TOKEN;
      url = url + '?oauth_consumer_key=' + @consumer_key
      url = url + '&oauth_nonce=' + (Random.rand(50)).to_s + "kaushik" + (Random.rand(100)).to_s
      url = url + '&oauth_signature=' + @secret_key + '%26'
      url = url + '&oauth_signature_method=PLAINTEXT'
      url = url + '&oauth_timestamp=' + Time.now.to_i.to_s
      url = url + '&oauth_token=' + @_token['request']
      url = url + '&oauth_version=1.0'
      puts url
      uri = URI.parse(url)
      rs = Net::HTTP.new(uri.host, uri.port)
      rs.use_ssl = true
      rs.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)

      response = rs.request(request)
      rb = response.body
      puts rb
      access_token = Hash.new
      tmp = rb.split('&')
      tmp.each do |row|
        col = row.split('=')
        access_token[col[0]] = col[1]
      end

      @_token['access'] = access_token
      p @_token['access']
    end

    def signon(status = '', state = 0)
      url = @@URL_YM_SESSION
      url = url +  '?oauth_consumer_key=' + @consumer_key
      url = url +  '&oauth_nonce=' + (Random.rand(50)).to_s + 'kaushik' + (Random.rand(100)).to_s
      url = url +  '&oauth_signature=' + @secret_key +  '%26' +  @_token['access']['oauth_token_secret']
      url = url +  '&oauth_signature_method=PLAINTEXT'
      url = url +  '&oauth_timestamp=' + Time.now.to_i.to_s

      url = url +  '&oauth_token=' + @_token['access']['oauth_token']
      url = url +  '&oauth_version=1.0'
      url = url +  '&notifyServerToken=1'
      puts url
    #  header = Array.new
    #  header.push 'Content-type: application/json; charset=utf-8'
    #  postdata = '{"presenceState" : ' +  state.to_s + ', "presenceMessage" : "' +  status + '"}'
  #  @includeheader = true
 #   rs = Curl::Easy.http_post(url, postdata)
      uri = URI.parse(url)
      rs = Net::HTTP.new(uri.host, uri.port)

      api =	    { presence: {
     	  		  presenceState: '0',
      			  presenceMessage: 'custom message',
      			  clientType: 'mobile'
   		    	  }
		         }	
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = api.to_json
      request.add_field('Content-Type', 'application/json')
      response = rs.request(request)
      @session_id = JSON.parse(response.body)
      puts @session_id["sessionId"]
  #  return false if body.index('sessionId').nil?

  #  js = JSON.parse(body)
  #  js['notifytoken'] = notifytoken
  #  @_ym['signon'] = js
  #  return true
    end

    def send_message(user, message)
    #puts "--------------------------------------------send message--------------"
    #prepare url
      url = @@URL_YM_MESSAGE
      url = url +  '?sid=' +  @session_id["sessionId"]
      url = url +  '&oauth_consumer_key=' +  @consumer_key
      url = url +  '&oauth_nonce=' +  (Random.rand(50)).to_s + 'kaushik' + (Random.rand(100)).to_s
      url = url +  '&oauth_signature=' +  @secret_key +  '%26' +  @_token['access']['oauth_token_secret']
      url = url +  '&oauth_signature_method=PLAINTEXT'
      url = url +  '&oauth_timestamp=' + Time.now.to_i.to_s
      url = url +  '&oauth_token=' +  @_token['access']['oauth_token']
      url = url +  '&oauth_version=1.0'

      url = url.gsub('{{USER}}', user)
    #puts url + '<------\n'
      uri = URI.parse(url)
      rs = Net::HTTP.new(uri.host, uri.port)
      api = {
  	      message: 'test message'
            }
       request = Net::HTTP::Post.new(uri.request_uri)
       request.body = api.to_json
       request.add_field('Content-Type', 'application/json')
       response = rs.request(request)
    
    end

    def signoff
      url = @@URL_YM_SESSION;
      url = url + '?oauth_consumer_key=' + @consumer_key
      url = url + '&oauth_nonce=' + (Random.rand(50)).to_s + 'kaushik' + (Random.rand(100)).to_s
      url = url + '&oauth_signature=' + @secret_key + '%26' + @_token['access']['oauth_token_secret']
      url = url + '&oauth_signature_method=PLAINTEXT'
      url = url + '&oauth_timestamp=' + Time.now.to_i.to_s
      url = url + '&oauth_token=' + @_token['access']['oauth_token']
      url = url + '&oauth_version=1.0'
      url = url + '&sid=' +  @session_id["sessionId"]

      uri = URI.parse(url)
      rs = Net::HTTP.new(uri.host, uri.port)    
      request = Net::HTTP::Delete.new(url)
      request.add_field('Content-Type', 'application/json')
      response = rs.request(request)
    end

    fetch_request_token
    fetch_access_token
    signon
    send_message "deepakmdass", "test"
    signoff
  end
end
