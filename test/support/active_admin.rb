module Support
  module ActiveAdmin
    def assert_index_columns(*cols)
      within('.index_table thead') do
        cols.each { |col| assert_selector ".col-#{col}" }
      end
    end

    def assert_show_rows(*rows, selector: nil)
      within("#{selector}.attributes_table") do
        rows.each { |row| assert_selector ".row-#{row}"}
      end
    end

    def assert_edit_fields(*fields, record:)
      within("form#edit_#{form_name(record)}") do
        fields.each do |f|
          assert_selector(
            %w(input select textarea).
              map { |elem| "#{elem}##{form_name(record)}_#{f}" }.
              join(', ')
          )
        end
      end
    end

    # Assert h2#page_title has given text
    # @param [String] text the title to match
    def assert_page_title(text)
      assert_selector 'h2#page_title', text: text
    end

    def assert_active_admin_comments
      assert_selector 'form.active_admin_comment'
    end

    # Used to fill ckeditor fields
    # @param [String] locator label text for the textarea or textarea id
    def fill_in_ckeditor(locator, with:)
      if page.has_css?('label', text: locator)
        locator = find('label', text: locator)[:for]
      end

      # Fill the editor content
      page.execute_script <<-SCRIPT
         var ckeditor = CKEDITOR.instances.#{locator}
         ckeditor.setData('#{with}')
         ckeditor.focus()
         ckeditor.updateElement()
      SCRIPT
    end

    # Selects an <option>
    # @param [String] selector
    # @param [String] value the value to select. If left blank, a random
    #   option will be selected
    # @param [Boolean] include_blank +true+ to randomly choose the blank
    #   option
    def select_option(selector, value: nil, include_blank: false)
      select = find_field(selector, visible: false)

      if (chosen = chosen_widget_sibling(select))
        chosen_widget_select_option(chosen, value: value, include_blank: include_blank)
      else
        select_option_or_random(select, value: value)
      end
    end

    private

    def chosen_widget_sibling(element)
      if (parent = element.first(:xpath, './/..'))
        parent.find('.chosen-container')
      end
    end

    # @param [String] value the value to select. If left blank, a random
    #   option will be selected
    # @param [Fixnum] include_blank +true+ to randomly choose the blank
    #   option
    def chosen_widget_select_option(element, value: nil, include_blank: false)
      element.click

      if value.present?
        element.find('.active-result', text: value, visible: false).click
      else
        options = element.all('.active-result', visible: false).to_a

        if options.any?
          option_pool_size = options.size
          option_pool_size = 9 if option_pool_size > 9
          # because I think capybara has an issue scrolling inside the select box
          # we limit the options to just the options visible without scrolling

          options[rand(option_pool_size)].click unless include_blank && [true, false].sample
        else
          raise format('chosen widget (%p) has no option elements', element)
        end
      end
    end

    # @param [String] value the value to select. If left blank, a random
    #   option will be selected
    def select_option_or_random(element, value: nil)
      if value.present?
        element.find('option', visible: false, text: value).select_option
      else
        options = select.all('option', visible: false)
        options[rand(options.size)].select_option
      end
    end

    def form_name(obj)
      case obj
      when String then obj
      when ActiveRecord::Base then obj.class.to_s.underscore
      else obj.to_s.underscore
      end
    end
  end
end
