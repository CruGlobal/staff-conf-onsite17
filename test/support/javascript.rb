module Support
  module Javascript
    def enable_javascript!
      Capybara.current_driver = Capybara.javascript_driver
    end

    def wait_for_ajax!
      unless Capybara.current_driver == Capybara.javascript_driver
        raise 'javascript is not enabled'
      end

      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until finished_all_ajax_requests?
      end
    end

    # @raises Timeout::Error
    def finished_all_ajax_requests?
      request_count = page.evaluate_script("$.active").to_i
      request_count && request_count.zero?
    end

    def scroll_to(element)
      browser.execute_script('arguments[0].scrollIntoView(true);',
                             element.native)
    end

    def add_class(element, *classes)
      value = classes.map(&:to_s).join(' ')
      jquery(element, "addClass('#{value}');")
    end

    def jquery_css(element, key, value)
      jquery(element, format('css("%s", "%s")', key, value))
    end

    def jquery(element, javascript)
      browser.execute_script("$(arguments[0]).#{javascript};", element.native)
    end

    private

    def browser
      Capybara.current_session.driver.browser
    end
  end
end
