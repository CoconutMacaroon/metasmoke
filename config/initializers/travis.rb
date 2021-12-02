# frozen_string_literal: true

if AppConfig['travis'].present? && AppConfig['travis']['token'].present?
  Travis.access_token = AppConfig['travis']['token']
end
