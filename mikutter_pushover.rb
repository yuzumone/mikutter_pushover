# -*- coding: utf-8 -*-

require "net/https"

Plugin.create(:mikutter_pushover) do
 
  on_mention do |service, msg|
    msg.each do |m|
      if Time.now - m.message[:created] < 10 and
        m.retweet? == false
        title = "Mentioned by " + m.user.to_s
        pushover(title, m)
      end
    end
  end

  on_favorite do |service, user, msg|
    title = "Favorite by " + user.to_s
    pushover(title, msg)
  end

  on_retweet do |msg|
    msg.each do |m|
      if Time.now - m.message[:created] < 10
        m.retweet_source_d.next { |s|
          if s.user.to_s == Service.primary.user.to_s
            title = "ReTweeted by " + m.user.to_s
            pushover(title, s)
          end
        }
      end
    end
  end

  def pushover(title, msg)
    url = URI.parse("https://api.pushover.net/1/messages.json")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
                        :user => UserConfig[:pushover_user],
                        :token => UserConfig[:pushover_token],
                        :title => title,
                        :message => msg,
                      })
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end

  settings "Pushover" do
    input("User", :pushover_user)
    input("Token", :pushover_token)
  end

end
