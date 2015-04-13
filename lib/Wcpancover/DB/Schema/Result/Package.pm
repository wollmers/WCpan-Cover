package Wcpancover::DB::Schema::Result::Package;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('packages');

__PACKAGE__->add_columns(
  'package_id',
  {data_type => 'integer', is_auto_increment => 1, is_nullable => 0},
  'name',
  {data_type => 'varchar', default_value => '', is_nullable => 0, size => 255},
);

__PACKAGE__->set_primary_key('package_id');

1;
