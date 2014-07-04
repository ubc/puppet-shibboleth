require 'spec_helper'
describe 'shibboleth::idp' do
  let (:pre_condition) {
    'Exec { path => "/foo" }'
  }

  context 'when passing no parameters' do
    it 'should fail' do
      expect { should compile }.to raise_error(Puppet::Error, /Must pass/)
    end
  end

  context 'when passing shibidp_version and shibidp_keepass' do
    let (:params) { {
      :shibidp_version => '1.2.3',
      :shibidp_keypass => 'abcd',
    } }

    it { should compile.with_all_deps }
  end
end

