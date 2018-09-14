if defined? FactoryGirl
  require Rails.root.join('test', 'factory_helper.rb')
  FactoryGirl::SyntaxRunner.send(:include, FactoryHelper)
end
