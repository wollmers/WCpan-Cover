#!perl 

use strict;
use warnings;


use lib qw(../lib);

my $job_entries = {};

my $CPANFILE = './cpanfile.txt';

my $PIDFILE = 'cpanfile.pid';

my $url = 'http://www.cpan.org/modules/01modules.index.html';

my $entries = {};

create_pid($PIDFILE);

remove_file($CPANFILE);

fetch_file($url, $CPANFILE);

my $config = {
  'db_connect' => [
    'DBI:mysql:database=wcpancover;host=127.0.0.1;port=3306',
    '',
    '',
    {
      PrintError        => 1,
      AutoCommit        => 1,
      RaiseError        => 1,
      mysql_enable_utf8 => 1,
    }
  ],
  'db_schema' => 'Wcpancover::DB::Schema',
  'secret'    => 'app_secret'
};

########################################
my $schema_class = $config->{db_schema};
eval "require $schema_class"
  or die "Could not load Schema Class ($schema_class), $@";
my $db_connect = $config->{db_connect}
  or die "No DBI connection string provided";
my @db_connect = ref $db_connect ? @$db_connect : ($db_connect);

my $schema = $schema_class->connect(@db_connect)
  or die "Could not connect to $schema_class using $db_connect[0]";

open (my $fh, '<', $file) or die "couldn't open $file, $@";

while (my $line=<$fh>) {
  chomp $line;
  # href="../authors/id/P/PB/PBLAIR/ACL-Regex-0.0002.tar.gz">ACL-Regex-0.0002.tar.gz</a>
  if ($line = ~ m/href=.+\/([^\/]+)\/[^\/]+>(\w[\w-]*)-(v?[0-9.]+)\.tar\.gz</) {
    my $author = $1;
    my $dist = $2;
    my $version = $3;
  }
}


my $rs = $schema->resultset('Package');
my $result =
  $schema->resultset('Package')->search(undef, {order_by => {-asc => 'id'}});
  
  
while (my $record = $result->next) {
  if (!exists $entries->{$record->id}) {
    ###print STDERR 'would delete record id: ',$record->id,"\n";
    $record->delete;
  }
}

remove_pid($PIDFILE);




sub entry {
  my ($t, $entry) = @_;

  my @fields = $entry->children();

  my $o_entry = {};

  for my $field (@fields) {
    my $name = lc $field->name;

    $o_entry->{$name} = $field->text();
    $o_entry->{$name} //= '';
  }
  
  if (exists $o_entry->{id}) {

    $o_entry->{id} = $o_entry->{id} + 0;
    #$job_entries->{$job_entry->{jobid}} = $job_entry;
    $entries->{$o_entry->{id}}++;

    my $rs = $schema->resultset('Package');
    $rs->update_or_create($o_entry,{ key => 'id_UNIQUE' });
  }
}



sub create_pid {
  my $pidfile = shift;
  if (-f $pidfile) {
    open(LF, "<$pidfile") or die "unable to open $pidfile: $!";
    my $pid = <LF>;
    chomp $pid;

    close(LF);
    my @tmp = `ps --no-headers -p $pid | grep $pid`;

    if ($#tmp < 0) {
      print STDERR
        "PIDFILE exists, foreign pid not running $pid, removing PIDFILE", "\n";
      unlink($PIDFILE);

      print STDERR "Creating PID " . $$ . " (" . $PIDFILE . ")", "\n";
      open(L, ">$pidfile") or die "unable to create pidfile: $!";
      print L $$;
      close(L);

      return;
    }

    print STDERR "Allready running ($pid) ... exit", "\n";
    exit;
  }

  open(L, ">$pidfile") or die "unable to create pidfile: $!";
  print L $$;
  close(L);
}

sub remove_pid {
  my $pidfile = shift;
  print STDERR "Remove Pidfile (" . $pidfile . ")", "\n";
  unless (-f $pidfile) {
    return;
  }
  unlink($pidfile) or die "unable to delete pidfile: $!";
}

sub remove_file {
  my $xmlfile = shift;
  print STDERR "Remove xmlfile (" . $xmlfile . ")", "\n";
  unless (-f $xmlfile) {
    return;
  }
  unlink($xmlfile) or die "unable to delete $xmlfile: $!";
}

sub fetch_file {
  my ($url, $file) = @_;

  #my $command = '/usr/bin/wget';
  #my $outfile = "--output-document=$file";
  
  my $command = '/usr/bin/curl';
  my $outfile = "> $file";  
  
  my @command = ($command, $url, $outfile);

  #print STDERR join(' ',@command),"\n";

  my $command_string = join(' ', @command);
  print STDERR $command_string, "\n";
  system($command_string);

  if ($? == -1) {
    #print STDERR "wget command failed: $!\n";
    #return 0;
    die "fetch file failed: $!";
  }
}

exit;

__END__


