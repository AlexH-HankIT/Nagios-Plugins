#!/usr/bin/perl
use strict;
use warnings;
use Net::SNMP;
use Getopt::Std;

my $version = "0.01";

sub check_oid {
        my $host = "$_[0]";
        my $community = "$_[1]";
        my $desc = "$_[2]";
        my ($session, $error) = Net::SNMP->session(
                                Hostname => "$host",
                                Community => "$community");
        die "session error: $error" unless ($session);
        my $result = $session->get_request("$desc");
        die "request error: ".$session->error unless (defined $result);
        $session->close;
        return $result->{"$desc"};
}

sub print_port_status {
        my $result = "$_[0]";
        my $port = "$_[1]";
        if ($result eq 1) {
                print "OK - Port $port is up\n"
                exit 0
        } elsif ($result eq 2) {
                print "Critical - Port $port is down\n"
                exit 2
        } else {
                print "Unknown - Can't get status of port $port\n"
                exit 3
        }
}

my $usage = " ./check_hp_2530_port.pl -h <host|ip> -c <community> -p <port>";
my %opts;
getopts("h:c:p:", \%opts) or die "$usage\n";
die "$usage\n" unless $opts{h};
die "$usage\n" unless $opts{c};
die "$usage\n" unless $opts{p};

my $host = $opts{h};
my $community = $opts{c};
my $port = $opts{p};
my $result = check_oid("$host", "$community", ".1.3.6.1.2.1.2.2.1.8.$port");
print_port_status("$result", "$port");
