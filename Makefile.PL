use inc::Module::Install;

name 'Catalyst-Controller-REST-DBIC-Item';
all_from 'lib/Catalyst/Controller/REST/DBIC/Item.pm';

requires 'Catalyst::Runtime' => '5.7011';
requires 'Catalyst::Action::REST' => '0.60';
requires 'Catalyst::Action::RenderView';

requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::View::TT';

requires 'DBIx::Class';
requires 'SQL::Translator';

requires 'JSON::DWIW';
requires 'JSON::Syck';
requires 'YAML::Syck' => '1.00';

requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;

