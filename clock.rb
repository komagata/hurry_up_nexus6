require 'open-uri'
require 'mail'
require 'css_selector'
require 'clockwork'
include Clockwork

NEXUS6_URL = 'https://play.google.com/store/devices/details/Nexus_6_64_GB_%E3%82%AF%E3%83%A9%E3%82%A6%E3%83%89_%E3%83%9B%E3%83%AF%E3%82%A4%E3%83%88?id=nexus_6_white_64gb&hl=ja'

Mail.defaults do
  delivery_method :smtp, {
    address:              'smtp.sendgrid.net',
    port:                 '587',
    domain:               'heroku.com',
    user_name:            ENV['SENDGRID_USERNAME'],
    password:             ENV['SENDGRID_PASSWORD'],
    authentication:       :plain,
    enable_starttls_auto: true
  }
end

handler do |job, time|
  html = open(NEXUS6_URL) { |f| f.read }
  status = CssSelector.new.parse(html, '.shipping-status').strip
  if status != '現在在庫切れです。しばらくしてからもう一度ご確認ください。'
    Mail.deliver do
      from     'komagata@gmail.com'
      to       ENV['MAIL_SEND_TO']
      subject  'Nexus6 is now available!'
      body     "Go fast! #{NEXUS6_URL}"



    end
  else
    puts 'Not available...'
  end
end

every(1.minute, 'check_nexus6')
