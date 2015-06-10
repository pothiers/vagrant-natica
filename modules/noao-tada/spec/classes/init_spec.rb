require 'spec_helper'
describe 'tada' do

  context 'with defaults for all parameters' do
    it { should contain_class('tada') }
  end
end
