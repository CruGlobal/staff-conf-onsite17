class ApplicationService
  include ActiveModel::Model
  include ActiveModel::Callbacks
  extend Forwardable

  I18N_SCOPE = [:services].freeze

  define_model_callbacks :initialize

  class << self
    # Create a new service, initialized with the given arguments, and {#call} it
    # before returning the new service object.
    def call(*args)
      new(*args).tap(&:call)
    end

    def i18n_scope(scope = nil)
      @scope = scope if scope.present?
      @scope
    end
  end

  def initialize(*_args)
    run_callbacks(:initialize) { super }
  end

  def call
    # Empty implementation which may be overridden by implementors
  end

  protected

  def t(*args)
    opts = args.extract_options!
    opts[:scope] =
      I18N_SCOPE + Array(self.class.i18n_scope) + Array(opts[:scope])

    I18n.t(*args, opts)
  end

  def l(*args)
    I18n.l(*args)
  end
end
