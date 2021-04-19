# name: QQ connect
# about: Authenticate with discourse with qq connect.
# version: 0.1.1
# author: Erick Guan

gem 'omniauth-qq', '0.3.0'

class QQAuthenticator < ::Auth::Authenticator

  QQ_APP_ID = ENV['QQ_APP_ID']
  QQ_SECRET = ENV['QQ_SECRET']

  def name
    'qq'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    data = auth_token[:info]
    raw_info = auth_token[:extra][:raw_info]
    name = data['nickname']
    username = data['name']
    qq_uid = auth_token[:uid]
    
    puts "qq_uid is %s" % qq_uid
    puts "name is %s " % name
    puts "username is %s " % username

    current_info = ::PluginStore.get('qq', "qq_uid_#{qq_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.username = username
    result.extra_data = { qq_uid: qq_uid, raw_info: raw_info }

    result
  end

  def after_create_account(user, auth)
    qq_uid = auth[:uid]
    ::PluginStore.set('qq', "qq_id_#{qq_uid}", {user_id: user.id})
  end

  def register_middleware(omniauth)
    omniauth.provider :qq, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = QQ_APP_ID
      strategy.options[:client_secret] = QQ_SECRET
    }
  end
end

auth_provider :frame_width => 760,
              :frame_height => 500,
              :authenticator => QQAuthenticator.new,
              :background_color => '#51b7ec'

register_css <<CSS

.btn-social.qq:before {
  font-family: FontAwesome;
  content: "\\f1d6";
}

CSS
