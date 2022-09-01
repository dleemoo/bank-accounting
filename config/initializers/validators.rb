# frozen_string_literal: true

class UuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if String(value).match(uuid_regexp)

    record.errors.add(attribute, options[:message] || "is not a valid UUID")
  end

  private

  def uuid_regexp
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
  end
end
