# frozen_string_literal: true

json.array! certification_requests, partial: 'api/v1/certification_requests/certification_request',
                                    as: :certification_request
