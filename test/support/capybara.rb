require 'selenium/webdriver'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities =
    Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless disable-gpu window-size=3840,21600) }
    )

  Capybara::Selenium::Driver.new(app, browser: :chrome,
                                      desired_capabilities: capabilities)
end

Capybara.javascript_driver =
  if ENV.key?('CAPYBARA_DRIVER')
    ENV['CAPYBARA_DRIVER'].to_sym
  else
    :headless_chrome
  end
