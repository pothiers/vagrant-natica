require 'spec_helper'
describe 'irods' do

  context 'with defaults for all parameters' do
    it { should contain_class('irods') }
  end
end
