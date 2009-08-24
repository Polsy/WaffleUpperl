#!/usr/bin/perl

# Linux WaffleImages uploader client
# Requires that the perl LWP module be installed.

use LWP;
use HTTP::Request::Common;

$ua = LWP::UserAgent->new;

for(@ARGV) {
  $sz = (-s);
  if($sz > 1048576) {
    print "Images have a maximum allowable size of 1024KB\n";
    exit;
  }

  # Check file can be opened ok
  open(F, "<$_") || die "Couldn't open $_: $!";
  close(F);

  # Create HTTP request for file
  $req = POST("http://waffleimages.com/upload",
          "Content-Type" => "form-data",
          "Content"      => [ "mode" => "file",
                              "client" => "WaffleLinuxUpload (Polsy) 0.9",
                              "file" => ["$_"],
                            ]);
  # Use XML upload mode
  $req->header("Accept" => "text/xml");

  # Make request
  $resp = $ua->request($req);

  print " $_\n";

  # Failed?
  if(! $resp->is_success) {
    print "Upload failed, error: ", $resp->status_line, "\n";
  } else {
    # Pick the interesting bits out of the XML
    @rLines = split(/\n/, $resp->as_string);

    $iURL = ""; $tURL = ""; $upErr = "";
    for (@rLines) {
      if(/<err/) { ($upErr) = m#<err type="([^"]+)"/>#; }
      if(/<imageurl/) { ($iURL) = m#<imageurl>([^<]+)</imageurl>#; }
      if(/<thumburl/) { ($tURL) = m#<thumburl>([^<]+)</thumburl>#; }
    }
  }

  if($upErr) { print "  Uploading error: $upErr\n"; }
  print "[img]$iURL", "[/img]\n";
  if($tURL) { print "[timg]$tURL", "[/timg]\n"; }
}