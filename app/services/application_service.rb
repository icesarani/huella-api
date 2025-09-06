# frozen_string_literal: true

class ApplicationService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  private

  def initialize(*args, **kwargs)
    # Override in subclasses
  end
end
