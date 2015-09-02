require 'spec_helper'
describe 'swap' do

  context 'with defaults for all parameters' do
    it { should contain_class('swap') }
    it { should compile.with_all_deps }

    it {
      should contain_exec('dd_swapfile').with({
        'command' => 'dd if=/dev/zero of=/swapfile bs=1M count=1024',
        'path'    => '/bin:/sbin',
        'creates' => '/swapfile',
      })
    }

    it {
      should contain_exec('mkswap').with({
        'command' => 'mkswap /swapfile',
        'path'    => '/bin:/sbin',
        'unless'  => 'grep ^/swapfile /proc/swaps',
      })
    }

    it {
      should contain_exec('swapon').with({
        'command'     => 'swapon /swapfile',
        'path'        => '/bin:/sbin',
        'refreshonly' => 'true',
      })
    }

    it {
      should contain_file('swapfile').with({
        'ensure' => 'present',
        'path'   => '/swapfile',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0600',
        'backup' => false,
      })
    }

    it {
      should contain_mount('swapfile').with({
        'ensure'  => 'present',
        'name'    => 'swap',
        'fstype'  => 'swap',
        'device'  => '/swapfile',
        'options' => 'defaults',
        'require' => 'File[swapfile]',
      })
    }

  end

  context 'with ensure = absent' do
    let(:params) { { :ensure => 'absent' } }

    it { should contain_class('swap') }
    it { should compile.with_all_deps }

    it {
      should contain_exec('swapoff').with({
        'command' => 'swapoff /swapfile',
        'path'    => '/bin:/sbin',
        'onlyif'  => 'grep ^/swapfile /proc/swaps',
      })
    }

    it { should contain_file('swapfile').with({'ensure' => 'absent'}) }
    it { should contain_mount('swapfile').with({'ensure' => 'absent'}) }
  end

  context 'with parameter size_m set' do
    let (:params) { { :size_m => '8192' } }

    it { should contain_class('swap') }
    it { should compile.with_all_deps }

    it {
      should contain_exec('dd_swapfile').with({
        'command' => 'dd if=/dev/zero of=/swapfile bs=1M count=8192',
        'path'    => '/bin:/sbin',
        'creates' => '/swapfile',
      })
    }
  end

  context 'with parameter swapfile_path set' do
    let (:params) { { :swapfile_path => '/var/swapf' } }

    it { should contain_class('swap') }
    it { should compile.with_all_deps }

    it {
      should contain_exec('dd_swapfile').with({
        'command' => 'dd if=/dev/zero of=/var/swapf bs=1M count=1024',
        'path'    => '/bin:/sbin',
        'creates' => '/var/swapf',
      })
    }

    it {
      should contain_exec('mkswap').with({
        'command' => 'mkswap /var/swapf',
        'path'    => '/bin:/sbin',
        'unless'  => 'grep ^/var/swapf /proc/swaps',
      })
    }

    it {
      should contain_exec('swapon').with({
        'command'     => 'swapon /var/swapf',
        'path'        => '/bin:/sbin',
        'refreshonly' => 'true',
      })
    }

    it {
      should contain_file('swapfile').with({
        'ensure' => 'present',
        'path'   => '/var/swapf',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0600',
        'backup' => false,
      })
    }

    it {
      should contain_mount('swapfile').with({
        'ensure'  => 'present',
        'name'    => 'swap',
        'fstype'  => 'swap',
        'device'  => '/var/swapf',
        'options' => 'defaults',
        'require' => 'File[swapfile]',
      })
    }
  end

  context 'with invalid ensure parameter' do
    let (:params) { { :ensure => 'installed' } }

    it 'should fail' do
      expect {
        should contain_class('swap')
      }.to raise_error(Puppet::Error,/Valid values for ensure is present or absent/)
    end
  end

  context 'with invalid size_m parameter' do
    let (:params) { { :size_m => '100m' } }

    it 'should fail' do
      expect {
        should contain_class('swap')
      }.to raise_error(Puppet::Error,/Parameter size_m must be numeric/)
    end
  end

  context 'with swapfile_path not an absolute path' do
    let (:params) { { :swapfile_path => './swapfile' } }

    it 'should fail' do
      expect {
        should contain_class('swap')
      }.to raise_error(Puppet::Error,/is not an absolute path/)
    end
  end
end
