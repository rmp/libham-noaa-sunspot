# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author: rmp@psyphi.net
# Created: 2016-12-31
#
package Ham::NOAA::Sunspot;
use strict;
use warnings;
use LWP::UserAgent;

our $DEFAULT_URL = q[http://services.swpc.noaa.gov/text/predicted-sunspot-radio-flux.txt];
our $VERSION = q[0.0.1];
sub new {
  my ($class, $ref) = @_;
  if(!ref $ref) {
    $ref = {};
  }

  bless $ref, $class;
  return $ref;
}

sub url {
  my ($self) = @_;
  return $self->{url} || $DEFAULT_URL;
}

sub _data {
  my ($self) = @_;
  if($self->{_data}) {
    return $self->{_data};
  }

  my $ua = LWP::UserAgent->new();
  $ua->agent(qq[Ham::NOAA::Sunspot $VERSION]);
  $ua->env_proxy();

  my $res = $ua->get($self->url);
  if(!$res->is_success) {
    return;
  }

  my $content = $res->decoded_content;
  my $lines   = [split /[\r\n]+/smx, $content];
  my $data    = [];

  for my $line (@{$lines}) {
    if($line =~ m{^\s*[#:]}smx) {
      next;
    }

    my ($year, $month, $sunspot_predicted, $sunspot_high, $sunspot_low, $flux_predicted, $flux_high, $flux_low) = $line =~ m{(\S+)}smxg;
    push @{$data}, {
		    year    => 0+$year,
		    month   => 0+$month,
		    sunspot => {
				predicted => $sunspot_predicted,
				high      => $sunspot_high,
				low       => $sunspot_low,
			       },
		    flux    => {
				predicted => $flux_predicted,
				high      => $flux_high,
				low       => $flux_low,
			       },
		   };
  }

  $self->{_data} = $data;
  return $data;
}

sub _by_year_month {
  my $self = shift;
  if($self->{_year_month}) {
    return $self->{_year_month};
  }

  my $data = $self->_data;
  for my $i (@{$data}) {
    $self->{_year_month}->{$i->{year}}->{$i->{month}} = {
							 sunspot => $i->{sunspot},
							 flux    => $i->{flux},
							};
  }

  return $self->{_year_month};
}

sub sunspot_by_year_month {
  my ($self, $year, $month) = @_;

  return $self->_by_year_month->{0+$year}->{0+$month}->{sunspot};
}

sub flux_by_year_month {
  my ($self, $year, $month) = @_;

  return $self->_by_year_month->{0+$year}->{0+$month}->{flux};
}
1;
