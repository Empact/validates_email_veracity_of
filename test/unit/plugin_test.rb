require 'test/unit'
require File.dirname(__FILE__) + '/../test_helper'

class ValidatesEmailVeracityOfTest < Test::Unit::TestCase
  
  @@real_emails = %w[
    itsme@heycarsten.com
    steve@apple.com
    pete@unspace.ca
    heycarsten@gmail.com ]
  
  @@emails_with_fake_domains = %w[
    nobody@carstensnowhereland.ca
    fake@fakeplace9876.org
    nothing@cooltown75.co.uk
    nil_person@nilington.net ]
  
  @@well_formed_emails = %w[
    itsme@heycarsten.com
    steve_jobs@apple.com
    SomeoneNice@SomePlace.com
    joe.blow@domain.co.uk
    joe.blow_2@web-site.net
    c00ki3@m0nst3r.org ]
    
  @@malformed_emails = %w[
    fake
    Do.Not.work
    @noWhere.com
    hi@mom
    #$%^&$
    sdf%^%@'d.Com ]
  
  def test_that_malformed_addresses_should_not_validate
    @@malformed_emails.each do |email|
      assert !Email.new(:address => email).valid?
    end
  end
  
  def test_that_all_well_formed_emails_should_validate_when_skip_remote_is_set
    @@well_formed_emails.each do |email|
      assert EmailSkipRemote.new(:address => email).valid?
    end
  end
  
  def test_that_all_real_emails_should_validate
    @@real_emails.each do |email|
      assert Email.new(:address => email).valid?
    end
  end
  
  def test_that_all_email_addresses_with_fake_domains_should_fail
    @@emails_with_fake_domains.each do |email|
      assert !Email.new(:address => email).valid?
    end
  end
  
  def test_that_blank_email_addresses_should_pass_validation
    assert Email.new(:address => '').valid?
  end
  
  def test_that_nil_email_addresses_should_pass_validation
    assert Email.new(:address => nil).valid?
  end
  
  def test_should_pass_validation_on_timeout_by_default
    assert EmailTimeout.new(:address => 'fake@fake1fake2nowhere3.ca').valid?
  end
  
  def test_should_fail_validation_on_timeout_when_fail_on_timeout_is_set
    assert !EmailFailOnTimeout.new(:address => 'fake@fake1fake2nowhere3.ca').valid?
  end
  
end
