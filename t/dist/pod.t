# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author:        rmp
# Last Modified: $Date: 2011-09-27 10:25:21 +0100 (Tue, 27 Sep 2011) $
# Id:            $Id: 00-pod.t 102 2011-09-27 09:25:21Z rmp $
# $HeadURL: svn+ssh://psyphi.net/repository/svn/5mhzpp/trunk/t/00-pod.t $
#
use strict;
use warnings;
use Test::More;
eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();
