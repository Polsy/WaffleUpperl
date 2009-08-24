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
  if($sz > 1048576) {
    die "Images have a maximum allowable size of 1024KB\n";
  }

  # Check file can be opened ok
  -r $image || die "Couldn't open $image: $!";

  # Create HTTP request for file
  my $req = POST("http://waffleimages.com/upload",
          "Content-Type" => "form-data",
          "Content"      => [ "mode" => "file",
                              "client" => "WaffleLinuxUpload (Polsy) 0.9",
                              "file" => ["$image"],
                            ]);
  # Use XML upload mode
  $req->header("Accept" => "text/xml");

  # Make request
  my $resp = $ua->request($req);

  print " $image\n";

  my $iURL = "";
  my $tURL = "";
  my $upErr = "";

  # Failed?
  if(! $resp->is_success) {
    print "Upload failed, error: ", $resp->status_line, "\n";
  } else {
    # Pick the interesting bits out of the XML
    my @rLines = split(/\n/, $resp->as_string);

    for (@rLines) {
      if (m#<err type="([^"]+)"/>#)        { $upErr = $1 }
      if (m#<imageurl>([^<]+)</imageurl>#) { $iURL  = $1 }
      if (m#<thumburl>([^<]+)</thumburl>#) { $tURL  = $1 }
    }
  }

  if($upErr) { print "  Uploading error: $upErr\n"; }
  print "[img]$iURL", "[/img]\n";
  if($tURL) { print "[timg]$tURL", "[/timg]\n"; }
}
