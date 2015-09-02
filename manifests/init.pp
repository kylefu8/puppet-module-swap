# == Class: swap
#
class swap(
  $ensure                = 'absent',
  $threshold_m           = '2048',
  $swapfile_path         = '/swapfile',
  $swapfile_size_m       = '1024',
) {

  $swapfile_path_dirname = dirname($swapfile_path)
  $free_space_integer    = $threshold_m + $swapfile_size_m

  case $::kernel {
    'Linux': {
      $command_dir     = "test -d $swapfile_path_dirname"
      $command_compare = "test \$(df -mP $swapfile_path_dirname | grep -v Avail | awk '{print \$4}') -gt $free_space_integer"
    }
    default: {
      $command_dir     = undef
      $command_df_m    = undef
      $command_compare = undef
    }
  }

  validate_re($ensure, '^present|^absent', 'Valid values for ensure is present or absent')
  validate_re($threshold_m, '^[0-9]*$', 'Parameter threshold_m must be numeric')
  validate_absolute_path($swapfile_path)
  validate_re($swapfile_size_m, '^[0-9]*$', 'Parameter swapfile_size_m must be numeric')


#  if ( $root_avail_m_value - $swapfile_size_m < $root_reserve_m ) {
#      notify {"$root_avail_m_value - $swapfile_size_m":}
#      notify {"$root_reserve_m":}
#      notify {"swapfile_size_m is too large.":}
#  }
#  else {
#      notify {"$root_avail_m_value - $swapfile_size_m":}
#      notify {"$root_reserve_m":}
#      notify {"swapfile_size_m is reasonable.":}
#  }

  notify {"Swapfile_Path_Dirname:": message => $swapfile_path_dirname, }
  notify {"DIR:": message => $command_dir, }
  notify {"COMPARE:": message => $command_compare, }

  if ( $::kernel == 'Linux' ) {
    if $ensure == 'present' {
      exec { 'dd_swapfile':
        command => "dd if=/dev/zero of=${swapfile_path} bs=1M count=${swapfile_size_m}",
        path    => '/bin:/sbin:/usr/bin',
        creates => $swapfile_path,
        #onlyif  => [ $command_dir, $command_df ]
        onlyif  => $command_compare
#        onlyif  => "test -f `dirname $swapfile_path`"
#        onlyif  => "`df -P $swapfile_path | grep -v Filesystem | cut -d\' \' -f1` - $swapfile_size_m > $root_reserve_m "
      }

      exec { 'mkswap':
        command => "mkswap ${swapfile_path}",
        path    => '/bin:/sbin',
        unless  => "grep ^${swapfile_path} /proc/swaps",
        notify  => Exec['swapon'],
        require => Exec['dd_swapfile'],
      }

      exec { 'swapon':
        command     => "swapon ${swapfile_path}",
        path        => '/bin:/sbin',
        refreshonly => true,
      }
    }
    else {
      exec { 'swapoff':
        command => "swapoff ${swapfile_path}",
        path    => '/bin:/sbin',
        onlyif  => "grep ^${swapfile_path} /proc/swaps",
        notify  => File['swapfile'],
      }
    }

    file { 'swapfile':
      ensure  => $ensure,
      path    => $swapfile_path,
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      backup  => false,
    }

    mount { 'swapfile':
      ensure  => $ensure,
      name    => 'swap',
      fstype  => 'swap',
      device  => $swapfile_path,
      options => 'defaults',
      require => File['swapfile'],
    }
  }
  else {
    notify {"Sorry, swap module only support Linux.":}
  }

}
