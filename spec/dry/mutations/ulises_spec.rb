require 'spec_helper'

describe Dry::Mutations::Command do
  class Profile
  end

  class User
  end

  let(:mutation) do
    Class.new(::Mutations::Command) do
      prepend ::Dry::Mutations::Command
      required do
        model :company, class: 'Profile'
        model :user, class: 'User'
        hash  :maturity_set do
          string :maturity_choice, in: %w(spot forward_days fixed_date)
          optional do
            hash :maturity_days_set do
              integer :days # For spot or forward_days options
            end
            hash :maturity_date_set do
              date :date # When passing a fixed date
            end
          end
        end
        hash :expiration_date_set do
          date :date
        end
        hash :bank_set do
          with_options empty: true do |empty|
            empty.string :bank_reference, nils: true
            empty.array  :invoice_files,  nils: true
          end
        end
        hash :currency_set do
          string  :currency
          string  :counter_currency
          float   :amount
          boolean :sell
        end
      end

      optional do
        with_options empty: true do |empty|
          empty.string :external_ref # external_order_ref (not considered in V1, but possible)
          empty.string :notes # comments
          empty.string :payment_purpose
        end
      end

      def execute
        @inputs
      end
    end
  end

  let(:input) do
    {
      company: Profile.new,
      user: User.new,
      maturity_set: {
        maturity_choice: 'spot',
        maturity_days_set: { days: 3 },
        maturity_date_set: { date: Date.today }
      },
      expiration_date_set: { date: Date.today },
      bank_set: {
        bank_reference: '',
        invoice_files: []
      },
      currency_set: {
        currency: 'USD',
        counter_currency: 'JPY',
        amount: 123.456,
        sell: true
      },
      external_ref: 'O-XXXXXXXXX',
      notes: '',
      payment_purpose: 'supplier'
    }
  end

  let(:output) { mutation.new(input) }
  let(:expected) { ::Dry::Mutations::Utils.Hash(input) }

  context 'Ulises’ most tremendous mutation' do
    it 'just works' do
      expect(output).to be_is_a(::Mutations::Command)
      expect(output.run).to be_success
      expect(output.run.result).to eq(expected)
    end
  end
end
