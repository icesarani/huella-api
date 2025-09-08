# frozen_string_literal: true

module CertificationErrors
  class RequestNotAssignedError < StandardError; end
  class RequestAlreadyFinalizedError < StandardError; end
  class VeterinarianNotAssignedError < StandardError; end
  class TooManyCertificationsError < StandardError; end
  class PhotoRequiredError < StandardError; end
end
