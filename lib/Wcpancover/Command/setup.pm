package Wcpancover::Command::setup;
use Mojo::Base 'Mojolicious::Command';

use Term::Prompt qw/prompt/;

has description => "Create the database for your Cpancover application.\n";
has usage       => "usage: $0 setup\n";

sub run {
  my ($self) = @_;


  $self->inject_sample_data();

  print "Database created! Run 'cpancover daemon' to start the server.\n";
}

sub inject_sample_data {
  my $self = shift;
  my $schema = eval { $_[-1]->isa('Wcpancover::DB::Schema') } ? pop() : $self->app->schema;

  $schema->deploy({ add_drop_table => 1});

  my $samples = [
    {author => 'WOLLMERS', name => 'AproJo-0.014'},
    {author => 'WOLLMERS', name => 'Text-Undiacritic-0.07'},
  ];

  my $samples1 = [
    {author => 'WOLLMERS', cname => 'AproJo-0.014'},
    {author => 'WOLLMERS', cname => 'Text-Undiacritic-0.07'},
  ];

  for my $sample (@$samples) {
    $schema->resultset('Package')->create($sample);
  }

  for my $sample (@$samples) {
    $schema->resultset('Cover')->create($sample);
  }

  return $schema;
}

1;
