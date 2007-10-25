module ActiveRecord
  module Validations
    module ClassMethods
      
      def validates_email_veracity_of(*attr_names)
        # Validates the form of an email address and verifies it's domain by checking if there are any
        # mail servers associated with it.
        #
        # Options:
        #           message => Changes the default error message.
        #      domain_check => Skips domain MX lookup unless true.
        #           timeout => (seconds) Time before the domain lookup is skipped. Default is 2.
        #   fail_on_timeout => Causes validation to fail if a timeout occurs.
        #   timeout_message => Changes the default timeout error message.
        #
        # Examples:
        #   validates_email_veracity_of :email, :message => 'is not correct.'
        #     | Changes the default error message from 'is invalid.' to 'is not correct.'
        #   validates_email_veracity_of :email, :domain_check => false
        #     | Domain lookup is skipped.
        #   validates_email_veracity_of :email, :timeout => 0.5
        #     | Causes the domain lookup to timeout if it does not complete within half a second.
        #   validates_email_veracity_of :email, :fail_on_timeout => true, :timeout_message => 'is invalid.'
        #     | Causes the validation to fail on timeout and changes the error message to 'is invalid.'
        #     | to obfuscate it.
        configuration = {
          :message => 'is invalid.',
          :timeout_message => 'domain is currently unreachable, try again later.',
          :timeout => 2,
          :domain_check => true,
          :fail_on_timeout => false
        }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
        validates_each(attr_names, configuration) do |record, attr_name, value|
          next if value.blank?
          email = ValidatesEmailVeracityOf::EmailAddress.new(value)
          message = :message unless email.pattern_is_valid?
          if configuration[:domain_check] && !message
            message = case email.domain_has_mail_servers?(configuration)
              when nil then :timeout_message
              when false then :message
            end
          end
          record.errors.add(attr_name, configuration[message]) if message
        end
      end
      
    end
  end
end