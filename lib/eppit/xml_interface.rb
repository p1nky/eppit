require 'active_support/core_ext'
require 'roxml'

module Eppit
  class MessageBase
    include ROXML

    def initialize()
      yield self if block_given?
    end
  end

  class Message < MessageBase

    NS = { 'xmlns' => 'urn:ietf:params:xml:ns:epp-1.0',
           'xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
           'domain' => 'urn:ietf:params:xml:ns:domain-1.0',
           'contact' => 'urn:ietf:params:xml:ns:contact-1.0',
           'extepp' => 'http://www.nic.it/ITNIC-EPP/extepp-2.0',
           'extcon' => 'http://www.nic.it/ITNIC-EPP/extcon-1.0',
           'extdom' => 'http://www.nic.it/ITNIC-EPP/extdom-2.0',
           'rgp' => 'urn:ietf:params:xml:ns:rgp-1.0' }

    xml_name 'epp'

    xml_accessor :xmlns_domain, :from => '@xmlns:domain'
    xml_accessor :xmlns_contact, :from => '@xmlns:contact'
    xml_accessor :xmlns_extepp, :from => '@xmlns:extepp'
    xml_accessor :xmlns_extdom, :from => '@xmlns:extdom'
    xml_accessor :xmlns_extcon, :from => '@xmlns:extcon'
    xml_accessor :xmlns_rgp, :from => '@xmlns:rgp'
    xml_accessor :xmlns, :from => '@xmlns'

    def initialize
      super
      @xmlns = 'urn:ietf:params:xml:ns:epp-1.0'
      @xmlns_domain = 'urn:ietf:params:xml:ns:domain-1.0'
      @xmlns_contact = 'urn:ietf:params:xml:ns:contact-1.0'
      @xmlns_extepp = 'http://www.nic.it/ITNIC-EPP/extepp-2.0'
      @xmlns_extdom = 'http://www.nic.it/ITNIC-EPP/extdom-2.0'
      @xmlns_extcon = 'http://www.nic.it/ITNIC-EPP/extcon-1.0'
      @xmlns_rgp = 'urn:ietf:params:xml:ns:rgp-1.0'
    end

    # Constructs used in multiple places:
    class HostAttr < MessageBase
      xml_namespaces NS
      xml_namespace :domain
      xml_name 'hostAttr'

      class HostAddr < MessageBase
        xml_namespaces NS
        xml_namespace :domain
        xml_name 'hostAttr'

        xml_accessor :type, :from => '@ip'
        xml_accessor :address, :from => :content
      end

      xml_accessor :host_name, :from => 'domain:hostName'
      xml_accessor :host_addr, :as => [HostAddr], :from => 'domain:hostAddr'
    end

    class Contact < MessageBase
      xml_namespaces NS
      xml_namespace :domain
      xml_name 'contact'

      xml_accessor :type, :from => '@type'
      xml_accessor :id, :from => :content
    end

    class DomainAuthInfo < MessageBase
      xml_namespaces NS
      xml_namespace :domain
      xml_name 'authInfo'

      xml_accessor :pw, :from => 'domain:pw'
    end

    class ContactAuthInfo < MessageBase
      xml_namespaces NS
      xml_namespace :contact
      xml_name 'authInfo'

      xml_accessor :pw, :from => 'contact:pw'
    end

    class PostalInfo < MessageBase
      xml_name 'postalInfo'
      xml_namespace :contact
      xml_namespaces NS

      class Addr < MessageBase
        xml_name 'addr'
        xml_namespace :contact
        xml_namespaces NS

        xml_accessor :street, :from => 'contact:street'
        xml_accessor :city, :from => 'contact:city'
        xml_accessor :sp, :from => 'contact:sp'
        xml_accessor :pc, :from => 'contact:pc'
        xml_accessor :cc, :from => 'contact:cc'
      end

      xml_accessor :type, :from => '@type'
      xml_accessor :name, :from => 'contact:name'
      xml_accessor :org, :from => 'contact:org'
      xml_accessor :addr, :from => 'contact:addr', :as => Addr
    end

    # Fixed position constructs

    class Hello < MessageBase
      xml_name 'hello'
    end

    class Response < MessageBase
      xml_name 'response'
      xml_namespaces NS

      class Extension < MessageBase
        xml_name 'extension'
        xml_namespaces NS

        class PasswdReminder < MessageBase
          xml_name 'passwdReminder'
          xml_namespace :extepp
          xml_namespaces NS

          xml_accessor :ex_date, :from => 'exDate', :as => Time
        end

        class ChgStatusMsgData < MessageBase
          xml_namespaces NS
          xml_namespace :extdom
          xml_name 'chgStatusMsgData'

          class Status < MessageBase
            xml_namespaces NS
            xml_accessor :name, :from => :name
            xml_accessor :lang, :from => '@lang'
            xml_accessor :status, :from => '@s'
            xml_accessor :namespace, :from => :namespace
          end

          xml_accessor :name
          xml_accessor :target_statuses, :as => [Status], :from => '*', :in => 'targetStatus', :namespace => '*'
        end

        class DnsErrorMsgData < MessageBase
          xml_namespaces NS
          xml_namespace :extdom
          xml_name 'dnsErrorMsgData'

          class Nameserver < MessageBase
            xml_namespaces NS
            xml_namespace :extdom
            xml_name 'nameserver'

            class Address < MessageBase
              xml_namespaces NS
              xml_namespace :extdom
              xml_name 'address'

              xml_accessor :type, :from => '@type'
              xml_accessor :address, :from => :content
            end

            xml_accessor :name, :from => '@name'
            xml_accessor :addresses, :from => 'extdom:address', :as => [Address]
          end

          class Test < MessageBase
            xml_namespaces NS
            xml_namespace :extdom
            xml_name 'test'

            class Nameserver < MessageBase
              xml_namespaces NS
              xml_namespace :extdom
              xml_name 'nameserver'

              class Detail < MessageBase
                xml_namespaces NS
                xml_namespace :extdom
                xml_name 'detail'

                xml_accessor :query_id, :from => '@queryId'
                xml_accessor :text, :from => :content
              end

              xml_accessor :status, :from => '@status'
              xml_accessor :name, :from => '@name'
              xml_accessor :details, :from => 'extdom:detail', :as => [Detail]
            end

            xml_accessor :status, :from => '@status'
            xml_accessor :name, :from => '@name'
            xml_accessor :skipped, :from => '@skipped'
            xml_accessor :nameservers, :from => 'extdom:nameserver', :as => [Nameserver]
          end

          class Query < MessageBase
            xml_namespaces NS
            xml_namespace :extdom
            xml_name 'query'

            xml_accessor :query_id, :from => '@id'
            xml_accessor :query_for, :from => 'extdom:queryFor'
            xml_accessor :type, :from => 'extdom:type'
            xml_accessor :destination, :from => 'extdom:destination'
            xml_accessor :result, :from => 'extdom:result'
          end

          xml_accessor :version, :from => '@version'

          xml_accessor :domain, :from => 'extdom:domain'
          xml_accessor :status, :from => 'extdom:status'
          xml_accessor :validation_id, :from => 'extdom:validationId'
          xml_accessor :validation_date, :from => 'extdom:validationDate', :as => Time
          xml_accessor :nameservers, :as => [Nameserver]
          xml_accessor :tests, :as => [Test]
          xml_accessor :queries, :as => [Query]
        end

        class DnsWarningMsgData < MessageBase
          xml_namespaces NS
          xml_namespace :extdom
          xml_name 'dnsWarningMsgData'

          class DnsWarningData < MessageBase
            xml_namespaces NS
            xml_namespace :extdom
            xml_name 'dnsWarningData'

            class Nameserver < MessageBase
              xml_namespaces NS
              xml_namespace :extdom
              xml_name 'nameserver'

              class Address < MessageBase
                xml_namespaces NS
                xml_namespace :extdom
                xml_name 'address'

                xml_accessor :type, :from => '@type'
                xml_accessor :address, :from => :content
              end

              xml_accessor :name, :from => '@name'
              xml_accessor :addresses, :from => 'extdom:address', :as => [Address]
            end

            class Test < MessageBase
              xml_namespaces NS
              xml_namespace :extdom
              xml_name 'test'

              class Nameserver < MessageBase
                xml_namespaces NS
                xml_namespace :extdom
                xml_name 'nameserver'

                class Detail < MessageBase
                  xml_namespaces NS
                  xml_namespace :extdom
                  xml_name 'detail'

                  xml_accessor :query_id, :from => '@queryId'
                  xml_accessor :text, :from => :content
                end

                xml_accessor :status, :from => '@status'
                xml_accessor :name, :from => '@name'
                xml_accessor :details, :from => 'extdom:detail', :as => [Detail]
              end

              xml_accessor :status, :from => '@status'
              xml_accessor :name, :from => '@name'
              xml_accessor :skipped, :from => '@skipped'
              xml_accessor :nameservers, :from => 'extdom:nameserver', :as => [Nameserver]
            end

            class Query < MessageBase
              xml_namespaces NS
              xml_namespace :extdom
              xml_name 'query'

              xml_accessor :query_id, :from => '@id'
              xml_accessor :query_for, :from => 'extdom:queryFor'
              xml_accessor :type, :from => 'extdom:type'
              xml_accessor :destination, :from => 'extdom:destination'
              xml_accessor :result, :from => 'extdom:result'
            end

            xml_accessor :version, :from => '@version'

            xml_accessor :domain, :from => 'extdom:domain'
            xml_accessor :status, :from => 'extdom:status'
            xml_accessor :validation_id, :from => 'extdom:validationId'
            xml_accessor :validation_date, :from => 'extdom:validationDate', :as => Time
            xml_accessor :nameservers, :as => [Nameserver]
            xml_accessor :tests, :as => [Test]
            xml_accessor :queries, :as => [Query]
          end

          xml_accessor :chg_status_msg_data, :as => ChgStatusMsgData, :from => 'extdom:chgStatusMsgData'
          xml_accessor :dns_warning_data, :as => DnsWarningData, :from => 'extdom:dnsWarningData'
        end

        class SimpleMsgData < MessageBase
          xml_name 'simpleMsgData'
          xml_namespace :extdom
          xml_namespaces NS

          xml_accessor :name
        end

        class RgpInfData < MessageBase
          xml_name 'infData'
          xml_namespace :rgp
          xml_namespaces NS

          class RgpStatus < MessageBase
            xml_name 'rgpStatus'
            xml_namespace :rgp
            xml_accessor :s, :from => '@s'
            xml_accessor :lang, :from => '@lang'
          end

          xml_accessor :rgp_status, :as => [RgpStatus], :from => 'rgpStatus'
        end

        class ExtconInfData < MessageBase
          xml_name 'infData'
          xml_namespace :extcon
          xml_namespaces NS

          class Registrant < MessageBase
            xml_name 'registrant'
            xml_namespace :extcon
            xml_namespaces NS

            xml_accessor :nationality_code, :from => 'extcon:nationalityCode'
            xml_accessor :entity_type, :from => 'extcon:entityType', :as => Integer
            xml_accessor :reg_code, :from => 'extcon:regCode'
          end

          xml_accessor(:consent_for_publishing, :from => 'extcon:consentForPublishing') { |val| val == 'true' }
          xml_accessor :registrant, :from => 'extcon:registrant', :as => Registrant
        end

        class ExtdomInfData < MessageBase
          xml_name 'infData'
          xml_namespace :extdom
          xml_namespaces NS

          class OwnStatus < MessageBase
            xml_name 'ownStatus'
            xml_namespace :extdom
            xml_accessor :s, :from => '@s'
            xml_accessor :lang, :from => '@lang'
          end

          xml_accessor :own_statuses, :as => [OwnStatus], :from => 'ownStatus'
        end

        class InfNsToValidateData < MessageBase
          xml_name 'infNsToValidateData'
          xml_namespace :extdom
          xml_namespaces NS

          xml_accessor :ns_to_validate, :as => [HostAttr], :from => 'domain:hostAttr', :in => 'nsToValidate'
        end

        class CreditMsgData < MessageBase
          xml_name 'creditMsgData'
          xml_namespace :extepp
          xml_namespaces NS

          xml_accessor :credit, :as => BigDecimal
        end

        class WrongNamespaceInfo < MessageBase
          xml_name 'wrongNamespaceInfo'
          xml_namespace :extepp
          xml_namespaces NS

          xml_accessor :wrong_namespace, :from => 'extepp:wrongNamespace'
          xml_accessor :right_namespace, :from => 'extepp:rightNamespace'
        end

        class WrongNamespaceReminder < MessageBase
          xml_name 'wrongNamespaceReminder'
          xml_namespace :extepp
          xml_namespaces NS

          xml_accessor :wrong_namespace_info, :as => [WrongNamespaceInfo]
        end

        class DelayedDebitAndRefundMsgData < MessageBase
          xml_name 'delayedDebitAndRefundMsgData'
          xml_namespace :extdom
          xml_namespaces NS

          xml_accessor :name
          xml_accessor :debit_date, :from => 'debitDate', :as => Time
          xml_accessor :amount, :as => BigDecimal
        end

        xml_accessor :passwd_reminder, :as => PasswdReminder, :from => 'extepp:passwdReminder'
        xml_accessor :dns_error_msg_data, :from => 'extdom:dnsErrorMsgData', :as => DnsErrorMsgData
        xml_accessor :dns_warning_msg_data, :from => 'extdom:dnsWarningMsgData', :as => DnsWarningMsgData
        xml_accessor :chg_status_msg_data, :from => 'extdom:chgStatusMsgData', :as => ChgStatusMsgData
        xml_accessor :simple_msg_data, :as => SimpleMsgData, :from => 'extdom:simpleMsgData'
        xml_accessor :extcon_inf_data, :as => ExtconInfData, :from => 'extcon:infData'
        xml_accessor :extdom_inf_data, :as => ExtdomInfData, :from => 'extdom:infData'
        xml_accessor :rgp_inf_data, :as => RgpInfData, :from => 'rgp:infData'
        xml_accessor :inf_ns_to_validate_data, :as => InfNsToValidateData, :from => 'extdom:infNsToValidateData'
        xml_accessor :credit_msg_data, :as => CreditMsgData, :from => 'extepp:creditMsgData'
        xml_accessor :wrong_namespace_reminder, :as => WrongNamespaceReminder, :from => 'extepp:wrongNamespaceReminder'
        xml_accessor :delayed_debit_and_refund_msg_data, :as => DelayedDebitAndRefundMsgData, :from => 'extdom:delayedDebitAndRefundMsgData'
      end

      class Result < MessageBase

        class Msg < MessageBase
          xml_name 'msg'
          xml_accessor :lang, :from => '@lang'
          xml_accessor :text, :from => :content
        end

        class ExtValue < MessageBase
          xml_name 'extValue'

          xml_accessor :reasons, :as => { :key => '@lang', :value => :content }, :from => 'reason'
          xml_accessor :reason_code, :from => 'extepp:reasonCode', :as => Integer, :in => 'value'
        end

        xml_name 'result'
        xml_accessor :code, :from => '@code', :as => Integer
        xml_accessor :msges, :as => { :key => '@lang', :value => :content }, :from => 'msg'
        xml_accessor :ext_value, :as => ExtValue
      end

      class ResData < MessageBase
        xml_name 'resData'
        xml_namespaces NS

        class ContactChkData < MessageBase
          xml_name 'chkData'
          xml_namespace :contact
          xml_namespaces NS

          class ContactCD < MessageBase
            xml_name 'cd'
            xml_namespace :contact
            xml_namespaces NS

            xml_accessor :id
            xml_accessor(:avail, :from => '@avail', :in => 'id') { |val| val == 'true' }
#            xml_accessor :reasons, :as => { :key => '@lang', :value => :content }, :from => 'reason'
          end

          xml_accessor :cds, :from => 'cd', :as => [ContactCD]
        end

        class ContactInfData < MessageBase

          class Status < MessageBase
            xml_namespaces NS
            xml_namespace :contact
            xml_name 'status'

            xml_accessor :lang, :from => '@lang'
            xml_accessor :s, :from => '@s'
            xml_accessor :namespace, :from => :namespace
          end

          class PostalInfo < Eppit::Message::PostalInfo ; end

          xml_namespaces NS
          xml_namespace :contact
          xml_name 'infData'

          xml_accessor :id
          xml_accessor :roid
          xml_accessor :statuses, :from => 'contact:status', :as => [Status]
          xml_accessor :postal_info, :from => 'contact:postalInfo', :as => Eppit::Message::PostalInfo
          xml_accessor :voice, :from => 'contact:voice'
          xml_accessor :voice_x, :from => '@x', :in => 'contact:voice'
          xml_accessor :fax, :from => 'contact:fax'
          xml_accessor :email, :from => 'contact:email'
          xml_accessor :cl_id, :from => 'contact:clID'
          xml_accessor :cr_id, :from => 'contact:crID'
          xml_accessor :cr_date, :from => 'contact:crDate', :as => Time
          xml_accessor :up_id, :from => 'contact:upID'
          xml_accessor :up_date, :from => 'contact:upDate', :as => Time

#          xml_accessor :auth_info, :from => 'authInfo', :as => DomainAuthInfo
        end


        class DomainChkData < MessageBase
          xml_name 'chkData'
          xml_namespace :domain
          xml_namespaces NS

          class DomainCD < MessageBase
            xml_name 'cd'
            xml_namespace :domain
            xml_namespaces NS

            xml_accessor :name
            xml_accessor(:avail, :from => '@avail', :in => 'name') { |val| val == 'true' }
            xml_accessor :reasons, :as => { :key => '@lang', :value => :content }, :from => 'reason'
          end

          xml_accessor :cds, :from => 'cd', :as => [DomainCD]
        end

        class DomainInfData < MessageBase

          class Status < MessageBase
            xml_namespaces NS
            xml_namespace :domain
            xml_name 'status'

            xml_accessor :lang, :from => '@lang'
            xml_accessor :status, :from => '@s'
            xml_accessor :namespace, :from => :namespace
          end

          class Contact < Eppit::Message::Contact ; end

          xml_namespaces NS
          xml_namespace :domain
          xml_name 'infData'

          xml_accessor :name
          xml_accessor :roid
          xml_accessor :statuses, :as => [Status]
          xml_accessor :registrant
          xml_accessor :contacts, :as => [Contact]
          xml_accessor :ns, :as => [HostAttr], :in => 'ns'
          xml_accessor :cl_id, :from => 'clID'
          xml_accessor :cr_id, :from => 'crID'
          xml_accessor :cr_date, :from => 'crDate', :as => Time
          xml_accessor :up_id, :from => 'upID'
          xml_accessor :up_date, :from => 'upDate', :as => Time
          xml_accessor :ex_date, :from => 'exDate', :as => Time
          xml_accessor :tr_date, :from => 'trDate', :as => Time
          xml_accessor :auth_info, :from => 'authInfo', :as => DomainAuthInfo
        end

        class DomainTrnData < MessageBase
          xml_namespaces NS
          xml_namespace :domain
          xml_name 'trnData'

          xml_accessor :name
          xml_accessor :tr_status, :from => 'trStatus'
          xml_accessor :re_id, :from => 'reID'
          xml_accessor :re_date, :from => 'reDate', :as => Time
          xml_accessor :ac_id, :from => 'acID'
          xml_accessor :ac_date, :from => 'acDate', :as => Time
        end

        class ContactCreData < MessageBase
          xml_name 'creData'
          xml_namespaces NS
          xml_namespace :contact

          xml_accessor :id, :from => 'contact:id'
          xml_accessor :cr_date, :from => 'contact:crDate', :as => Time
        end

        class DomainCreData < MessageBase
          xml_name 'creData'
          xml_namespaces NS
          xml_namespace :domain

          xml_accessor :name, :from => 'domain:name'
          xml_accessor :cr_date, :from => 'domain:crDate', :as => Time
          xml_accessor :ex_date, :from => 'domain:exDate', :as => Time
        end

        xml_accessor :contact_chk_data, :as => ContactChkData, :from => 'contact:chkData'
        xml_accessor :contact_cre_data, :as => ContactCreData, :from => 'contact:creData'
        xml_accessor :contact_inf_data, :as => ContactInfData, :from => 'contact:infData'
        xml_accessor :domain_chk_data, :as => DomainChkData, :from => 'domain:chkData'
        xml_accessor :domain_inf_data, :as => DomainInfData, :from => 'domain:infData'
        xml_accessor :domain_trn_data, :as => DomainTrnData, :from => 'domain:trnData'
        xml_accessor :domain_cre_data, :as => DomainCreData, :from => 'domain:creData'
      end

      class MsgQ < MessageBase
        xml_name 'msgq'
        xml_accessor :id, :from => '@id'
        xml_accessor :count, :from => '@count', :as => Integer
        xml_accessor :qdate, :from => 'qDate', :as => Time
        xml_accessor :msges, :as => { :key => '@lang', :value => :content }, :from => 'msg'
      end

      xml_accessor :res_data, :as => ResData, :from => 'resData'
      xml_accessor :result, :as => Result
      xml_accessor :msgq, :as => MsgQ, :from => 'msgQ'
      xml_accessor :extension, :as => Extension
      xml_accessor :cl_tr_id, :from => 'clTRID', :in => 'trID'
      xml_accessor :sv_tr_id, :from => 'svTRID', :in => 'trID'
    end

    xml_accessor :response, :as => Response

    class Command < MessageBase
      class Login < MessageBase

        class Options < MessageBase
          xml_name 'options'
          xml_accessor :version
          xml_accessor :lang
        end

        class Svcs < MessageBase
          xml_name 'svcs'
          xml_accessor :obj_uris, :as => [], :from => 'objURI'
          xml_accessor :ext_uris, :as => [], :from => 'extURI', :in => 'svcExtension'
        end

        xml_name 'login'
        xml_accessor :cl_id, :from => 'clID'
        xml_accessor :pw
        xml_accessor :new_pw, :from => 'newPW'
        xml_accessor :options, :as => Options
        xml_accessor :svcs, :as => Svcs
      end

      class Logout < MessageBase
        xml_name 'logout'
      end

      class Poll < MessageBase
        xml_name 'poll'
        xml_accessor :op, :from => '@op'
        xml_accessor :msg_id, :from => '@msgID'
      end

      class Check < MessageBase
        xml_name 'check'
        xml_namespaces NS

        class ContactCheck < MessageBase
          xml_name 'check'
          xml_namespace :contact
          xml_accessor :ids, :as => [], :from => 'contact:id'
        end

        class DomainCheck < MessageBase
          xml_name 'check'
          xml_namespace :domain
          xml_accessor :names, :as => [], :from => 'domain:name'
        end

        xml_accessor :contact_check, :as => ContactCheck, :from => 'contact:check'
        xml_accessor :domain_check, :as => DomainCheck, :from => 'domain:check'
      end

      class Info < MessageBase
        xml_name 'info'
        xml_namespaces NS

        class ContactInfo < MessageBase
          xml_name 'info'
          xml_namespace :contact
          xml_accessor :id, :from => 'contact:id'
          xml_accessor :auth_info, :from => 'contact:authInfo', :as => ContactAuthInfo
        end

        class DomainInfo < MessageBase
          xml_name 'info'
          xml_namespace :domain
          xml_accessor :name, :from => 'domain:name'
          xml_accessor :hosts, :from => '@hosts', :in => 'domain:name'
          xml_accessor :auth_info, :from => 'domain:authInfo', :as => DomainAuthInfo
        end

        xml_accessor :contact_info, :as => ContactInfo, :from => 'contact:info'
        xml_accessor :domain_info, :as => DomainInfo, :from => 'domain:info'
      end

      class Create < MessageBase
        xml_name 'create'
        xml_namespaces NS

        class ContactCreate < MessageBase
          xml_name 'create'
          xml_namespace :contact

          PostalInfo = Eppit::Message::PostalInfo

          xml_accessor :id, :from => 'contact:id'
          xml_accessor :postal_info, :from => 'contact:postalInfo', :as => PostalInfo
          xml_accessor :voice, :from => 'contact:voice'
          xml_accessor :voice_x, :from => '@x', :in => 'contact:voice'
          xml_accessor :fax, :from => 'contact:fax'
          xml_accessor :email, :from => 'contact:email'
          xml_accessor :auth_info, :from => 'contact:authInfo', :as => ContactAuthInfo
        end

        class DomainCreate < MessageBase
          xml_name 'create'
          xml_namespace :domain

          class Contact < Eppit::Message::Contact ; end

          def initialize
            super

            @period_unit = 'y'
          end

          xml_accessor :name, :from => 'domain:name'
          xml_accessor :period, :from => 'domain:period', :as => Integer
          xml_accessor :period_unit, :from => '@unit', :in => 'domain:period'
          xml_accessor :ns, :from => 'domain:hostAttr', :in => 'domain:ns', :as => [HostAttr]
          xml_accessor :registrant, :from => 'domain:registrant'
          xml_accessor :contacts, :from => 'domain:contact', :as => [Contact]
          xml_accessor :auth_info, :from => 'domain:authInfo', :as => DomainAuthInfo
        end

        xml_accessor :contact_create, :as => ContactCreate, :from => 'contact:create'
        xml_accessor :domain_create, :as => DomainCreate, :from => 'domain:create'
      end

      class Update < MessageBase
        xml_name 'update'
        xml_namespaces NS

        class ContactUpdate < MessageBase
          xml_name 'update'
          xml_namespace :contact

          class Status < MessageBase
            xml_namespaces NS
            xml_name 'status'
            xml_accessor :lang, :from => '@lang'
            xml_accessor :s, :from => '@s'
          end

          class Add < MessageBase
            xml_name 'add'
            xml_namespace :contact

            xml_accessor :statuses, :from => 'contact:status', :as => [Status]
          end

          class Chg < MessageBase
            xml_name 'add'
            xml_namespace :contact
            xml_namespaces NS

            PostalInfo = Eppit::Message::PostalInfo

            xml_accessor :postal_info, :from => 'contact:postalInfo', :as => PostalInfo
            xml_accessor :voice, :from => 'contact:voice'
            xml_accessor :voice_x, :from => '@x', :in => 'contact:voice'
            xml_accessor :fax, :from => 'contact:fax'
            xml_accessor :email, :from => 'contact:email'
          end

          class Rem < MessageBase
            xml_name 'rem'
            xml_namespace :contact

            xml_accessor :statuses, :from => 'contact:status', :as => [Status]
          end

          xml_accessor :id, :from => 'contact:id'
          xml_accessor :add, :from => 'contact:add', :as => Add
          xml_accessor :rem, :from => 'contact:rem', :as => Rem
          xml_accessor :chg, :from => 'contact:chg', :as => Chg
        end

        class DomainUpdate < MessageBase
          xml_name 'update'
          xml_namespace :domain

          Contact = Eppit::Message::Contact

          class Status < MessageBase
            xml_namespaces NS
            xml_name 'status'
            xml_accessor :lang, :from => '@lang'
            xml_accessor :s, :from => '@s'
            xml_accessor :msg, :from => :content
          end

          class Add < MessageBase
            xml_name 'add'
            xml_namespace :contact

            xml_accessor :ns, :from => 'domain:hostAttr', :in => 'domain:ns', :as => [HostAttr]
            xml_accessor :contacts, :from => 'domain:contact', :as => [Contact]
            xml_accessor :statuses, :from => 'domain:status', :as => [Status]
          end

          class Chg < MessageBase
            xml_name 'add'
            xml_namespace :contact
            xml_namespaces NS

            xml_accessor :registrant, :from => 'domain:registrant'
            xml_accessor :auth_info, :from => 'domain:authInfo', :as => DomainAuthInfo
          end

          class Rem < MessageBase
            xml_name 'rem'
            xml_namespace :contact

            xml_accessor :ns, :from => 'domain:hostAttr', :in => 'domain:ns', :as => [HostAttr]
            xml_accessor :contacts, :from => 'domain:contact', :as => [Contact]
            xml_accessor :statuses, :from => 'domain:status', :as => [Status]
          end

          def initialize
            super

            @period_unit = 'y'
          end

          xml_accessor :name, :from => 'domain:name'
          xml_accessor :add, :from => 'domain:add', :as => Add
          xml_accessor :rem, :from => 'domain:rem', :as => Rem
          xml_accessor :chg, :from => 'domain:chg', :as => Chg
        end

        xml_accessor :contact_update, :as => ContactUpdate, :from => 'contact:update'
        xml_accessor :domain_update, :as => DomainUpdate, :from => 'domain:update'
      end

      class Delete < MessageBase
        xml_name 'delete'
        xml_namespaces NS

        class ContactDelete < MessageBase
          xml_name 'delete'
          xml_namespace :contact
          xml_namespaces NS

          xml_accessor :id, :from => 'contact:id'
        end

        class DomainDelete < MessageBase
          xml_name 'delete'
          xml_namespace :domain
          xml_namespaces NS

          xml_accessor :name, :from => 'domain:name'
        end

        xml_accessor :contact_delete, :as => ContactDelete, :from => 'contact:delete'
        xml_accessor :domain_delete, :as => DomainDelete, :from => 'domain:delete'
      end

      class Transfer < MessageBase
        xml_name 'transfer'
        xml_namespaces NS

        class DomainTransfer < MessageBase
          xml_name 'transfer'
          xml_namespace :domain
          xml_namespaces NS

          xml_accessor :name, :from => 'domain:name'
          xml_accessor :auth_info, :from => 'domain:authInfo', :as => DomainAuthInfo
        end

        xml_accessor :domain_transfer, :as => DomainTransfer, :from => 'domain:transfer'
        xml_accessor :op, :from => '@op'
      end

      class Extension < MessageBase
        xml_name 'extension'

        class ExtconCreate < MessageBase
          xml_name 'create'
          xml_namespace :extcon
          xml_namespaces NS

          class Registrant < MessageBase
            xml_name 'registrant'
            xml_namespace :extcon
            xml_namespaces NS

            xml_accessor :nationality_code, :from => 'extcon:nationalityCode'
            xml_accessor :entity_type, :from => 'extcon:entityType', :as => Integer
            xml_accessor :reg_code, :from => 'extcon:regCode'
          end

          xml_accessor(:consent_for_publishing, :from => 'extcon:consentForPublishing') { |val| val == 'true' }
          xml_accessor :registrant, :from => 'extcon:registrant', :as => Registrant
        end

        class ExtconUpdate < MessageBase
          xml_name 'update'
          xml_namespace :extcon
          xml_namespaces NS

          class Registrant < MessageBase
            xml_name 'registrant'
            xml_namespace :extcon
            xml_namespaces NS

            xml_accessor :nationality_code, :from => 'extcon:nationalityCode'
            xml_accessor :entity_type, :from => 'extcon:entityType', :as => Integer
            xml_accessor :reg_code, :from => 'extcon:regCode'
          end

          xml_accessor(:consent_for_publishing, :from => 'extcon:consentForPublishing') { |val| val == 'true' }
          xml_accessor :registrant, :from => 'extcon:registrant', :as => Registrant
        end

        class ExtdomTrade < MessageBase
          xml_name 'trade'
          xml_namespace :extdom
          xml_namespaces NS

          class NewAuthInfo < MessageBase
            xml_name 'newAuthInfo'
            xml_namespace :extdom
            xml_namespaces NS

            xml_accessor :pw, :from => 'extdom:pw'
          end

          xml_accessor :new_registrant, :from => 'extdom:newRegistrant', :in => 'extdom:transferTrade'
          xml_accessor :new_auth_info, :from => 'extdom:newAuthInfo', :as => NewAuthInfo, :in => 'extdom:transferTrade'
        end

        class RgpUpdate < MessageBase
          xml_name 'update'
          xml_namespace :rgp
          xml_namespaces NS

          xml_accessor :restore_op, :from => '@op', :in => 'rgp:restore'
        end

        xml_accessor :extcon_create, :as => ExtconCreate, :from => 'extcon:create'
        xml_accessor :extcon_update, :as => ExtconUpdate, :from => 'extcon:update'
        xml_accessor :extdom_trade, :as => ExtdomTrade, :from => 'extdom:trade'
        xml_accessor :rgp_update, :as => RgpUpdate, :from => 'rgp:update'
      end

      xml_name 'command'
      xml_accessor :login, :from => 'login', :as => Login
      xml_accessor :logout, :from => 'logout', :as => Logout
      xml_accessor :poll, :from => 'poll', :as => Poll
      xml_accessor :info, :from => 'info', :as => Info
      xml_accessor :check, :from => 'check', :as => Check
      xml_accessor :create, :from => 'create' , :as => Create
      xml_accessor :update, :from => 'update' , :as => Update
      xml_accessor :delete, :from => 'delete' , :as => Delete
      xml_accessor :transfer, :from => 'transfer', :as => Transfer

      xml_accessor :extension, :as => Extension

      xml_accessor :cl_tr_id, :from => 'clTRID'
    end

    xml_accessor :hello, :as => Hello, :from => 'hello'
    xml_accessor :command, :as => Command, :from => 'command'

  end
end
