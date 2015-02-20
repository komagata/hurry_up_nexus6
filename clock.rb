require 'open-uri'
require 'mail'
require 'css_selector'
require 'clockwork'
include Clockwork

NEXUS6_BASE_URL = 'https://play.google.com/store/devices/details?id=nexus_6_'
COLORS = %w(white blue)
MEMORIES = %w(32 64)

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
  COLORS.each do |color|
    MEMORIES.each do |memory|
      url = "#{NEXUS6_BASE_URL}#{color}_#{memory}gb"
      html = open(url) { |f| f.read }
      status = CssSelector.new.parse(html, '.shipping-status').strip
      if status != '現在在庫切れです。しばらくしてからもう一度ご確認ください。'
        Mail.deliver do
          from     'komagata@gmail.com'
          to       'komagata@gmail.com'
          subject  "Nexus6 #{color} #{memory}MB is now available!"
          body     "Go fast! #{url}"
        end
      else
        puts "Nexus6 #{color} #{memory}GB model is not available..."
      end
    end
  end
end

every(1.minute, 'check_nexus6')
