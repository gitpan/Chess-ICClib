package Chess::ICClib;

use 5.008003;
use strict;
use warnings;

use Exporter;
use Net::Telnet;
use Carp;
use Chess::FIDE;
our @ISA = qw(Net::Telnet Exporter);

our $FICS = 'fics%';
our $ICC  = 'aics%';
our $USCHESSLIVE = 'fics%';
our $CHESSANYTIME = 'gics%';
our $CHESSNET = 'chess%';
our $DNCS = 'dncs%';
our $AUSTRALIANCS = 'zics%';
our $BRAZILIANCS = 'cex%';
our @EXPORT = qw(
		 $FICS $ICC $USCHESSLIVE $CHESSANYTIME
		 $CHESSNET $DNCS $AUSTRALIANCS $BRAZILIANCS
		 $ICSHOST $ICSPORT
		);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Chess::ICClib ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

our $VERSION = '1.00';
our $ICSHOST = '204.178.125.65';
our $ICSPORT = '5000';

# Preloaded methods go here.

sub new {

    my $self = shift;
    my $class = ref($self) || $self;
    my %param = @_;
    my $icc = {};
    my $icsrc = $param{-icsrc} || $ENV{HOME} . '/.icsrc';
    $icc->{prompt} = 'ics%';

    print "Using ICClib.pm v$VERSION, icsrc $icsrc\n";
    bless $icc,$class;
    $icc->{host} = $param{-host} || $ICSHOST;
    $icc->{port} = $param{-port} || $ICSPORT;
    $icc->{prompt} = $param{-prompt} if defined $param{-prompt};
    if ($param{-user} && $param{-pass}) {
	$icc->{user} = $param{-user};
	$icc->{pass} = $param{-pass};
    }
    elsif (open(ICS,$icsrc)) {
	$icc->{user} = <ICS>; chomp $icc->{user};
	$icc->{pass} = <ICS>; chomp $icc->{pass};
	close ICS;
    }
    else {
	carp "Missing user and password!\n";
	return $icc;
    }
    $icc->iccConnect($icc,$class);
    return $icc;
}
sub iccConnect {

    my $icc = shift;

    $icc->{SOCKET} = Net::Telnet->new(Telnetmode=>1);

    $icc->{SOCKET}->open(Host=>$icc->{host},
			 Port=>$icc->{port});
    my $welcome;
    $icc->{SOCKET}->waitfor('/login:/');
    $icc->{SOCKET}->print($icc->{user});
    unless ($icc->{user} eq 'guest') {
	$icc->{SOCKET}->waitfor(-match => '/password:.*/i');
	my $ok = $icc->{SOCKET}->print($icc->{pass});
    }
    $icc->{SOCKET}->waitfor('/'.$icc->{prompt}.'/');
}
sub ICCCommand {

    my $icc = shift;
    my $command = shift;

    $icc->{SOCKET}->print($command);
    my($response,$match) =  $icc->{SOCKET}->waitfor('/'.$icc->{prompt}.'/');
    my $page = 0;
    while (($response =~ /type \"more\" to see more/i ||
	    $response =~ /type \"next\" to see next page/i) &&
	   $response !~ /There is no more/i) {
	$page++;
	print "Page $page\n";
	$icc->{SOCKET}->print('more');
	my($response2,$match) = $icc->{SOCKET}->waitfor('/'.$icc->{prompt}.'/');
	$response .= $response2;
    }
    return $response;
}
1;
__END__

=head1 NAME

Chess::ICClib - Perl interface to Internet Chess Server commands

=head1 SYNOPSIS

  use Chess::ICClib;
  my $icc = Chess::ICClib->new([-prompt=>$ICC],
                               [-host=>$host,-port=>$port]
                               [-user=>$user,-pass=>$password]);
  $icc->ICCCommand("finger romm");

=head1 DESCRIPTION

Chess::ICClib - Perl interface to Internet Chess Server commands.
Provides a tool able to connect, login and send commands to an
Internet Chess Server as well as return responses from the server.
Can be used as a basis for information retrieval tool as well as
for a player or a chess program interface.

Since ICS [Internet Chess Server] (any, commercial and free alike)
are built upon the telnet protocol, this module is built upon the
Net::Telnet module where the telnet connection serves as the
read/write socket.

This module has been tested against ICC (Internet Chess Club,
http://www.chessclub.com, telnet king.chessclub.com 5000) but it
should work fine against other chess servers unless they propose
another "more" preprompt. More about prompts see in C<ICCCommand>
method section.

The following methods are available:

=over

=item C<Constructor>

$icc = Chess::ICClib->new([-prompt=>$ICC],
                          [-host=>$host,-port=>$port]
                          [-user=>$user,-pass=>$password]);

Creates an ICC object, then connects and logins into the ICS.
All parameters are optional.

=over

=item C<-prompt>

The ICS prompt. The default is the ICC prompt 'aics%'. Several
other popular servers' prompt are provided - see the C<EXPORT>
section.

=item C<-host>,C<-port>

The ICS host and port. The defaults are the ICC host 204.178.125.65
and the ICC port 5000. In later versions hosts and ports for most
popular ICS will be added for export.

=item C<-user>,C<-pass>

The ICS user name and password. There are no defaults. 'guest' login
is sufficient on most of the servers (USChessLive and FreeICS are
not supporting guest logins!) The module tries to look up the file
'~/.icsrc' to read the username and password from it.

=back

=item C<ICCCommand>

my $response = $icc->ICCCommand($icccommand)

This method performs an ICC Command $icccommand and sets the output
into $response. The interface of ICC (and supposedly of other ICS)
pages the output automatically with preprompt 'Type "more" to see more'
and the output unpages it scrolling with issuing the "more" command
consecutively until the preprompt disappears. Please note that ICS
is case-insensitive while Perl is.

=back

=head2 EXPORT

=over

=item C<VARIOUS ICS PROMPTS>
		 $FICS $ICC $USCHESSLIVE $CHESSANYTIME
		 $CHESSNET $DNCS $AUSTRALIANCS $BRAZILIANCS

=item C<Default host and port for ICC>

		 $ICSHOST $ICSPORT
=back

=head1 CAVEATS

This module does not implement the timeseal feature which avoids the
effect of network lag on the chess clock therefore in its current
condition the modules is not weel suitable to playing. But, it seems
that various ICS use different timeseal protocols so implementing them
would take time.

=head1 SEE ALSO

Chess::FIDE      Net::Telnet     and various Chess-Server related sites.

=head1 FILES

~/.icsrc

=head1 AUTHOR

Roman M. Parparov, E<lt>romm@empire.tau.ac.ilE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Roman M. Parparov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

The Internet Chess Servers are copyrighted separately by their
owners.

=cut
