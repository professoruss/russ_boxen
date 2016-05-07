require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  #include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  #nodejs::version { '0.8': }
  #nodejs::version { '0.10': }
  #nodejs::version { '0.12': }

  # default ruby versions
  #ruby::version { '1.9.3': }
  #ruby::version { '2.0.0': }
  #ruby::version { '2.1.8': }
  #ruby::version { '2.2.4': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # add my stuff
  include thunderbird
  class { 'virtualbox':
    version     => '5.0.20',
    patch_level => '106931',
  }
  include python
  include vagrant
  include firefox
  include dropbox
  include evernote
  include skype
  #include keepassx
  #class { 'quicksilver':
  #  version => '1.4.1',
  #}
  class { 'alfred':
    version => '2.8.4_437',
  }
  include chrome
  include spotify
  include nmap
  include adium
  include gimp
  include vlc
  include wget
  include sublime_text_2

  # OSX stuff
  osx::recovery_message { 'If this Mac is found, please call 415-xxx-xxxx': }
  include osx::global::enable_keyboard_control_access
  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog
  include osx::global::disable_remote_control_ir_receiver
  include osx::dock::clear_dock
  include osx::finder::unhide_library
  include osx::finder::enable_quicklook_text_selection
  include osx::finder::show_all_filename_extensions
  include osx::safari::enable_developer_mode
  include osx::no_network_dsstores
  class { 'osx::global::natural_mouse_scrolling':
    enabled => false
  }
  class { 'osx::dock::icon_size':
    size => 36
  }
  class { 'osx::dock::hot_corners':
    top_right => "Start Screen Saver",
  }
  include osx::dock::magnification

  # VIM stuff
  include vim
  vim::bundle { [
  #'pangloss/vim-javascript',
  #'scrooloose/nerdtree',
  #'timcharper/textile.vim',
  #'tpope/vim-fugitive',
  #'tpope/vim-git',
  #'tpope/vim-haml',
  #'tpope/vim-markdown',
  #'tpope/vim-repeat',
  #'tpope/vim-surround',
  #'tpope/vim-vividchalk',
  #'tsaleh/taskpaper.vim',
  #'tsaleh/vim-matchit',
  #'tsaleh/vim-shoulda',
  #'tsaleh/vim-tcomment',
  #'tsaleh/vim-tmux',
  #'vim-scripts/Gist.vim',
  #'rodjek/vim-puppet',
  'astashov/vim-ruby-debugger',
  'godlygeek/tabular',
  'hallison/vim-rdoc',
  'msanders/snipmate.vim',
  'elzr/vim-json',
  'tpope/vim-cucumber',
  'tpope/vim-rails',
  'vim-ruby/vim-ruby',
  'scrooloose/syntastic',
  'mv/mv-vim-puppet.git',
  'sjl/gundo.vim'
]: }

  file { "${vim::vimrc}":
    content => 'call pathogen#infect()
syntax on
" set default comment color to cyan instead of darkblue
" which is not very legible on a black background
highlight comment ctermfg=cyan

set tabstop=2
set expandtab
set softtabstop=2
set shiftwidth=2

highlight LiteralTabs ctermbg=darkgreen guibg=darkgreen
match LiteralTabs /\s\  /
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$/

filetype plugin indent on'
  }

  boxen::osx_defaults { 'set terminal startup to pro':
    ensure => present,
    domain => 'com.apple.Terminal',
    key    => 'Startup Window Settings',
    type   => 'string',
    value  => 'Pro',
    user   => $::boxen_user,
  }

  boxen::osx_defaults { 'set terminal default to pro':
    ensure => present,
    domain => 'com.apple.Terminal',
    key    => 'Default Window Settings',
    type   => 'string',
    value  => 'Pro',
    user   => $::boxen_user,
  }

  boxen::osx_defaults { 'Show Full URL':
    ensure => present,
    domain => 'com.apple.Safari',
    key    => 'ShowFullURLInSmartSearchField',
    type   => 'string',
    value  => '1',
    user   => $::boxen_user,
  }

  boxen::osx_defaults { 'Show Overlay Status Bar':
    ensure => present,
    domain => 'com.apple.Safari',
    key    => 'ShowOverlayStatusBar',
    type   => 'string',
    value  => '1',
    user   => $::boxen_user,
  }

}

