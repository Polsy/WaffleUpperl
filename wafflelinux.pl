#!/usr/bin/env perl
use strict;
use warnings;

# Linux WaffleImages uploader client
# Requires that the perl LWP module be installed.

use LWP;
use HTTP::Request::Common;

my $ua = LWP::UserAgent->new;

for my $image (@ARGV) {
  my $sz = (-s $image);
  if($sz > 1024*1024) {
    die "Images have a maximum allowable size of 1024KB\n";
  }

  # Check file can be opened ok
  -r $image || die "Couldn't open $image: $!";

  # Create HTTP request for file
  my $req = POST("http://waffleimages.com/upload",
          "Content-Type" => "form-data",
          "Content"      => [ "mode" => "file",
                              "client" => "WaffleLinuxUpload (Polsy) 0.9",
                              "file" => [$image],
                            ]);
  # Use XML upload mode
  $req->header("Accept" => "text/xml");

  # Make request
  my $resp = $ua->request($req);

  print " $image\n";

  # Failed?
  if(! $resp->is_success) {
    warn "Upload failed, error: ", $resp->status_line, "\n";
    next;
  }

  # Pick the interesting bits out of the XML
  for (split /\n/, $resp->as_string) {
    if (m#<err type="([^"]+)"/>#) {
      warn "  Uploading error: $1\n";
    }

    if (m#<imageurl>([^<]+)</imageurl>#) {
      print "[img]$1", "[/img]\n";
    }

    if (m#<thumburl>([^<]+)</thumburl>#) {
      print "[timg]$tURL", "[/timg]\n";
    }
  }
}
