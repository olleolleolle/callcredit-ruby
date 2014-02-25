require 'spec_helper'

describe Callcredit::Validations do
  let(:check_data) do
    { personal_data: {
        first_name: "Grey",
        last_name: "Baker",
        date_of_birth: date_of_birth,
        postcode: "EC2A 1DX",
        building_number: "22-25"
      }
    }
  end
  let(:date_of_birth) { "01/01/2000" }

  describe '#clean_date_of_birth' do
    subject { Callcredit::Validations.clean_date_of_birth(date_of_birth) }

    context "without a date of birth" do
      let(:date_of_birth) { nil }
      it { should == nil }
    end

    context "with a date object" do
      let(:date_of_birth) { Date.parse("01/01/2000") }
      it { should == date_of_birth.strftime("%d/%m/%Y") }
    end

    context "with a parseable string" do
      let(:date_of_birth) { "01-01-2000" }
      it { should == "01/01/2000" }
    end

    context "with a load of rubbish" do
      let(:date_of_birth) { "A couple of weeks ago" }
      it "raises an error" do
        expect { subject }.to raise_error Callcredit::InvalidRequestError
      end
    end
  end

  describe '#clean_name' do
    subject { Callcredit::Validations.clean_name(name, :first_name) }

    context "without a name" do
      let(:name) { nil }
      it { should == nil }
    end

    context "with a simple name" do
      let(:name) { "Grey" }
      it { should == name }
    end

    context "with a name with non-ASCII characters" do
      let(:name) { "Gréy" }
      it { should == "Grey" }
    end

    context "with a very long name" do
      let(:name) { "A" * 31 }
      it "raises an error" do
        expect { subject }.to raise_error Callcredit::InvalidRequestError
      end
    end

    context "with a name with numbers in it" do
      let(:name) { "David the 3rd" }
      it "raises an error" do
        expect { subject }.to raise_error Callcredit::InvalidRequestError
      end
    end
  end

  describe '#clean_postcode' do
    subject { Callcredit::Validations.clean_postcode(postcode, :postcode) }

    context "without a postcode" do
      let(:postcode) { nil }
      it { should == nil }
    end

    context "with a correct postcode" do
      let(:postcode) { "EC2A 1DX" }
      it { should == postcode }
    end

    context "with a padded postcode" do
      let(:postcode) { "EC2A 1DX    " }
      it { should == "EC2A 1DX" }
    end

    context "with a postcode that is too short" do
      let(:postcode) { "N1" }
      it "raises an error" do
        expect { subject }.to raise_error Callcredit::InvalidRequestError
      end
    end
  end
end