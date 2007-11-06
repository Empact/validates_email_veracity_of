require 'test/unit'
require File.dirname(__FILE__) + '/../test_helper'

class DomainTest < Test::Unit::TestCase
  
  def test_should_fail_gracefully_with_no_name
    domain = ValidatesEmailVeracityOf::Domain.new
    assert (domain.mail_servers == [])
  end
  
  def test_should_return_mail_servers_for_gmail_dot_com
    domain = ValidatesEmailVeracityOf::Domain.new('gmail.com')
    assert !domain.mail_servers.empty?
  end
  
  def test_should_return_false_by_default_on_timeout
    domain = ValidatesEmailVeracityOf::Domain.new('nowhere-abcdef.ca')
    assert !domain.mail_servers(:timeout => 0.0001)
  end
  
  def test_should_return_nil_on_timeout_when_fail_on_timeout_is_set
    domain = ValidatesEmailVeracityOf::Domain.new('nowhere-abcdef.ca')
    assert_nil domain.mail_servers(:timeout => 0.0001, :fail_on_timeout => true)
  end

end


class EmailAddressTest < Test::Unit::TestCase
  
  def test_domain_has_mail_servers_should_fail_gracefully_when_no_address_is_set
    email = ValidatesEmailVeracityOf::EmailAddress.new
    assert !email.domain_has_mail_servers?
  end
  
  def test_malformed_email_addresses_should_fail_pattern_validation
    emails = %w[
      fake
      Do.Not.work
      @noWhere.com
      hi@mom
      #$%^&$
      sdf%^%@'d.Com ]
    emails.each do |address|
      email = ValidatesEmailVeracityOf::EmailAddress.new(address)
      assert_nil email.pattern_is_valid?
    end
  end
  
  def test_well_formed_email_addresses_should_pass_pattern_validation
    emails = %w[
      itsme@heycarsten.com
      steve_jobs@apple.com
      SomeoneNice@SomePlace.com
      joe.blow@domain.co.uk
      joe.blow_2@web-site.net
      c00ki3@m0nst3r.org ]
    emails.each do |address|
      email = ValidatesEmailVeracityOf::EmailAddress.new(address)
      assert email.pattern_is_valid?
    end
  end
  
  def test_itsme_at_heycarsten_dot_com_should_have_mail_servers
    email = ValidatesEmailVeracityOf::EmailAddress.new('itsme@heycarsten.com')
    assert email.domain_has_mail_servers?
  end
  
  def test_nobody_at_carstensnowhereland_dot_ca_should_not_have_mail_servers
    email = ValidatesEmailVeracityOf::EmailAddress.new('nobody@carstensnowhereland.ca')
    assert !email.domain_has_mail_servers?
  end
  
  def test_an_object_with_no_address_should_still_have_a_domain_object
    email = ValidatesEmailVeracityOf::EmailAddress.new
    assert email.domain.is_a?(ValidatesEmailVeracityOf::Domain)
  end
  
end
