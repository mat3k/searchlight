module Searchlight
  class Search
    extend DSL

    def self.search_target
      defined?(@search_target) ? @search_target : superclass.search_target
    end

    def initialize(options = {})
      options.each { |key, value| public_send("#{key}=", value) } if options && options.any?
    end

    def search
      @search ||= self.class.search_target
    end

    def results
      @results ||= run
    end

    protected

    attr_writer :search

    private

    def search_methods
      public_methods.map(&:to_s).select { |m| m.start_with?('search_') }
    end

    def run
      search_methods.each do |method|
        new_search  = run_search_method(method)
        self.search = new_search unless new_search.nil?
      end
      search
    end

    def run_search_method(method_name)
      option_value = public_send(method_name.sub(/\Asearch_/, ''))
      option_value = option_value.reject { |item| blank_value?(item) } if option_value.respond_to?(:reject)
      public_send(method_name) unless blank_value?(option_value)
    end

    # Note that false is not blank
    def blank_value?(value)
      (value.respond_to?(:empty?) && value.empty?) || value.nil? || value.to_s.strip == ''
    end

  end
end