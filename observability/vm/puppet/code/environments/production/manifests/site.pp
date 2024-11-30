node default {
  class { "::${facts['profile']}": }
}
