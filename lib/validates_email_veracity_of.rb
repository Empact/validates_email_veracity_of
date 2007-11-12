class ValidatesEmailVeracityOf
  
  
  class MailServer
    
    attr_accessor :name
    
    def initialize(name = '')
      self.name = name
    end
    
  end
  
  
  class Domain
    
    require 'resolv'
    require 'timeout'
    
    attr_accessor :name
    
    def initialize(name = '')
      self.name = name
    end
    
    # Returns an array of mail server objects for the provided domain, if the domain
    # does not exist, it will return an empty array. If it times out, nil is returned.
    def mail_servers(options = {})
      st = Timeout::timeout(options.fetch(:timeout, 2)) do
        dns = Resolv::DNS.new
        type = Resolv::DNS::Resource::IN::MX
        dns.getresources(name, type).collect{|ms| MailServer.new(ms.exchange.to_s)}
      end
     rescue Timeout::Error
      nil
    end
    
  end
  
  
  class EmailAddress
    
    attr_accessor :address
    
    def initialize(email = '')
      self.address = email
    end
    
    # Domains that we know have mail servers
    def self.known_domains
      %w[ aol.com gmail.com hotmail.com mac.com msn.com
      rogers.com sympatico.ca yahoo.com ]
    end
    
    def domain
      Domain.new(address.include?('@') ? address.split('@')[1].strip : '')
    end
    
    def pattern_is_valid?
      address =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    end
    
    # Checks if the email address' domain has any mail servers associated to it,
    # if it does then it will return true, if it does not then it will return false
    # if it times out, it will return false or nil if the fail_on_timeout option is
    # specified.
    def domain_has_mail_servers?(options = {})
      return true if EmailAddress.known_domains.include?(domain.name.downcase)
      mail_servers = domain.mail_servers(options)
      if mail_servers.nil?
        options.fetch(:fail_on_timeout, true) ? nil : true
      else
        !mail_servers.empty?
      end
    end
    
  end
  
  
end