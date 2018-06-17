# -*- coding: utf-8 -*-

require "net/https"

Plugin.create(:mikutter_pushover) do
 
  on_mention do |service, msg|
    msg.each do |m|
      if Time.now - m.created < 10 and !m.retweet?
        title = "Mentioned by #{m.user.idname}"
        pushover(title, m.description)
      end
    end
  end

  on_favorite do |service, user, msg|
    unless user.me?
      title = "Favorited by #{user.idname}"
      pushover(title, msg.description)
    end
  end

  on_retweet do |msg|
    msg.each do |m|
      if Time.now - m.created < 10
        m.retweet_source_d.next { |s|
          if s.from_me?
            title = "ReTweeted by #{m.user.idname}"
            pushover(title, s.description)
          end
        }
      end
    end
  end

  def pushover(title, msg)
    url = URI.parse("https://api.pushover.net/1/messages.json")
    req = Net::HTTP::Post.new(url.path)
    priority = if UserConfig[:pushover_high_priority]
                 1
               else
                 0
               end
    req.set_form_data({
                        :user => UserConfig[:pushover_user],
                        :token => UserConfig[:pushover_token],
                        :title => title,
                        :message => msg,
                        :priority => priority,
                      })
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end

  settings "Pushover" do
    input("UserKey", :pushover_user)
    input("Token", :pushover_token)
    boolean("HighPriority", :pushover_high_priority)
  end

end
